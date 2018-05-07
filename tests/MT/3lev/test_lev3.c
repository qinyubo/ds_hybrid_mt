/*
 * Copyright (c) 2009, NSF Cloud and Autonomic Computing Center, Rutgers University
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided
 * that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions and
 * the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
 * the following disclaimer in the documentation and/or other materials provided with the distribution.
 * - Neither the name of the NSF Cloud and Autonomic Computing Center, Rutgers University, nor the names of its
 * contributors may be used to endorse or promote products derived from this software without specific prior
 * written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

/*
*  Fan Zhang (2013)  TASSL Rutgers University
*  zhangfan@cac.rutgers.edu
*  Qian Sun (2014)  TASSL Rutgers University
*  qiansun@cac.rutgers.edu
*  Yubo Qin (2018) RDI2 Rutgers University
*  yubo.qin@rutgers.edu
*/
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "debug.h"
#include "common.h"
#include "mpi.h"

	int err;
	int nprocs, rank;
	MPI_Comm gcomm;

    // Usage: ./test_writer type npapp dims np[0] ... np[dims-1] sp[0] ... sp[dims-1] timestep appid elem_size num_vars
    // Command line arguments
    enum transport_type type; // DATASPACES or DIMES
    int npapp; // number of application processes
    int np[10] = {0};	//number of processes in each dimension
    uint64_t sp[10] = {0}; //block size per process in each dimesion
    int timestep; // number of iterations
    int appid; // application id
    int dims; // number of dimensions
    size_t elem_size; // Optional: size of one element in the global array. Default value is 8 (bytes).
    int num_vars; // Optional: number of variables to be shared in the testing. Default value is 1.
    //Yubo
    int vars_name[16] = {0}; //variable names, enable multiple variables
    int lock_num = 1; //locker number

//# of processors in fortran direction
static int np[10] = {0};
//block size per processor per direction
static uint64_t sp[10] = {0};
//# of interations
static int timesteps_;
//# of processors in the application
static int npapp_;

static int rank_, nproc_;

static uint64_t off[10] = {0};

static struct timer timer_;

static MPI_Comm gcomm_;

static size_t elem_size_;

static char transport_type_str_[256];

static int variable_names[16] = {0}; //Yubo


static double* allocate_nd(int dims)
{
        double* tmp = NULL;
        int i = 0;
        uint64_t size = 1;
        for(i = 0; i < dims; i++){
                size *= sp[i];
        }
        tmp = (double*)malloc(elem_size_ * size);
        return tmp;
}

static void set_offset_nd(int rank, int dims)
{
	int i = 0, j = 0;
	for(i = 0; i < dims; i++){
		int tmp = rank;
		for(j = 0; j < i; j++)
			tmp /= np[j];
		off[i] = tmp % np[i] * sp[i];
	}
}


static int generate_nd(double *mnd, unsigned int ts, int dims)
{
    //double value = 1.0*(rank_) + 0.0001*ts;
	double value = ts;
    int i;
	uint64_t mnd_size = 1;
    for(i = 0; i < dims; i++)
        mnd_size *= sp[i];
	mnd_size = mnd_size * elem_size_ / sizeof(double);
    for(i = 0; i < mnd_size; i++)
        *(mnd+i) = value;
    return 0;
}

static int couple_write_nd(unsigned int ts, int num_vars, enum transport_type type, int dims, int lock_num)
{
	double **data_tab = (double **)malloc(sizeof(double *) * num_vars);
	char var_name[128];
	char lock_name[128]; //Yubo

	sprintf(lock_name, "mnd_lock_%d", lock_num);

	int i;
	for(i = 0; i < num_vars; i++)
		data_tab[i] = NULL;

	//common_lock_on_write("mnd_lock", &gcomm_);
	//uloga("Debug #1\n");
	common_lock_on_write(lock_name, &gcomm);
	//uloga("Debug #2\n");

	if (type == USE_DIMES) {
		common_put_sync(type);
	}

	set_offset_nd(rank_, dims);
	int elem_size = elem_size_;
	uint64_t lb[10] = {0}, ub[10] = {0};
	for(i = 0; i < dims; i++){
		lb[i] = off[i];
		ub[i] = off[i] + sp[i] - 1;
	}
	double tm_st, tm_end, tm_max, tm_diff;
	int root = 0;

#ifdef DEBUG
	char str_lb[100]="", str_ub[100]="";
	for(i = 0; i < dims; i++){
		sprintf(str_lb+strlen(str_lb), "%llu,", lb[i]);
		sprintf(str_ub+strlen(str_ub), "%llu,", ub[i]);
	}
    uloga("Timestep=%u, %d write mnd (%s),(%s) into space\n", ts, rank_, str_lb, str_ub);
#endif

	//allocate data
	double *data = NULL;
	for(i = 0; i < num_vars; i++){
		data = allocate_nd(dims);
		if(data == NULL){
			uloga("%s(): allocate_nd() failed.\n", __func__);
            return -1; // TODO: free buffers
		}
		
		generate_nd(data, ts, dims);
		data_tab[i] = data;
	}

	MPI_Barrier(gcomm);
    tm_st = timer_read(&timer_);

	for(i = 0; i < num_vars; i++){
		sprintf(var_name, "mnd_%d", variable_names[i]);  //Yubo, customize the variable names
		printf("wrter put var %d with lock #%d at time %f\n", variable_names[i],lock_num, timer_read(&timer_) );
		common_put(var_name, ts, elem_size, dims, lb, ub,
			data_tab[i], type);
		if(type == USE_DSPACES){
			common_put_sync(type);
		}
	}
	tm_end = timer_read(&timer_);

	sleep(3);
	//common_unlock_on_write("mnd_lock", &gcomm_);lock_name
	common_unlock_on_write(lock_name, &gcomm);
	//common_unlock_on_write("mnd_lock", NULL);	//Test dspaces_barrier

	tm_diff = tm_end-tm_st;
	MPI_Reduce(&tm_diff, &tm_max, 1, MPI_DOUBLE, MPI_MAX, root, gcomm);

#ifdef TIMING_PERF
	uloga("TIMING_PERF put_data ts %u peer %d time %lf\n",
            ts, common_rank(), tm_diff);
#endif
    if (rank_ == root) {
        uloga("TS= %u #%d TRANSPORT_TYPE= %s write MAX time= %lf\n",
                ts, lock_num, transport_type_str_, tm_max);
    }

	for (i = 0; i < num_vars; i++) {
        if (data_tab[i]) {
            free(data_tab[i]);
        }
    }
    free(data_tab);

    return 0;
}

static int couple_read_nd(unsigned int ts, int num_vars, enum transport_type type, int dims, int lock_num)
{
	double **data_tab = (double **)malloc(sizeof(double*) * num_vars);
	char var_name[128];
	char lock_name[128]; //Yubo
	int i;

	for(i = 0; i < num_vars; i++){
		data_tab[i] = NULL;
	}	

	sprintf(lock_name, "mnd_lock_%d", lock_num);

	//common_lock_on_read("mnd_lock", &gcomm_);	//Test dspaces_barrier
	//common_lock_on_read("mnd_lock", NULL);
	common_lock_on_read(lock_name, &gcomm);

	set_offset_nd(rank_, dims);
	uint64_t dims_size = 1;
	int elem_size = elem_size_;
	uint64_t lb[10] = {0}, ub[10] = {0};
	for(i = 0; i < dims; i++){
		lb[i] = off[i];
		ub[i] = off[i] + sp[i] - 1;
		dims_size *= sp[i];
	}
	double tm_st, tm_end, tm_max, tm_diff;
	int root = 0;

#ifdef DEBUG
	char str_lb[100]="", str_ub[100]="";
    for(i = 0; i < dims; i++){
        sprintf(str_lb+strlen(str_lb), "%llu,", lb[i]);
        sprintf(str_ub+strlen(str_ub), "%llu,", ub[i]);
    }
    uloga("Timestep=%u, %d read mnd (%s),(%s) from space\n", ts, rank_, str_lb, str_ub);
#endif

	//allocate data
	double *data = NULL;
	for(i = 0; i < num_vars; i++){
		data = allocate_nd(dims);
		if(data == NULL){
			uloga("%s(): allocate_2d() failed.\n", __func__);
            		return -1; // TODO: free buffers
		}
		memset(data, 0, elem_size_ * dims_size);
		data_tab[i] = data;
	}

	MPI_Barrier(gcomm_);
    tm_st = timer_read(&timer_);

	for(i = 0; i < num_vars; i++){
		sprintf(var_name, "mnd_%d", variable_names[i]);  //Yubo, customize the variable names
		printf("reader get var %d with lock #%d at time %f\n", variable_names[i],lock_num, timer_read(&timer_) );
		common_get(var_name, ts, elem_size, dims, lb, ub,
			data_tab[i], type);
	}
	tm_end = timer_read(&timer_);
	//common_unlock_on_read("mnd_lock", &gcomm_); 
	common_unlock_on_read(lock_name, &gcomm);
	//common_unlock_on_read("mnd_lock", NULL);	//Test dspaces_barrier
		
	tm_diff = tm_end-tm_st;
	MPI_Reduce(&tm_diff, &tm_max, 1, MPI_DOUBLE, MPI_MAX, root, gcomm);

#ifdef TIMING_PERF
	uloga("TIMING_PERF get_data ts %u peer %d time %lf\n",
            ts, common_rank(), tm_diff);
#endif
    if (rank_ == root) {
        uloga("TS= %u #%d TRANSPORT_TYPE= %s read MAX time= %lf\n",
                ts, lock_num, transport_type_str_, tm_max);
    }

	for (i = 0; i < num_vars; i++) {
		sprintf(var_name, "mnd_%d", variable_names[i]);  //Yubo, customize the variable names

		check_data(var_name, data_tab[i],dims_size*elem_size_/sizeof(double),
			rank, ts);
        if (data_tab[i]) {
            free(data_tab[i]);
        }
    }
    free(data_tab);

    return 0;
}


int test_put_run(enum transport_type type, int npapp, int ndims, int* npdim, 
	uint64_t *spdim, int timestep, int appid, size_t elem_size, int num_vars, int* vars_name,
	MPI_Comm gcomm, int lock_num)
{
	gcomm_ = gcomm;
	elem_size_ = elem_size;
	timesteps_ = timestep;
	npapp_ = npapp;

	int i;
	for(i = 0; i < ndims; i++){
        np[i] = npdim[i];
        sp[i] = spdim[i];
	}

	for (i = 0; i < num_vars; i++){
		variable_names[i] = vars_name[i];
	}
/*
	timer_init(&timer_, 1);
        timer_start(&timer_);

	int app_id = appid;
	double tm_st, tm_end;
	tm_st = timer_read(&timer_);
	common_init(npapp_, app_id, &gcomm_, NULL);
	tm_end = timer_read(&timer_);
	common_get_transport_type_str(type, transport_type_str_);

	MPI_Comm_rank(gcomm_, &rank_);
    MPI_Comm_size(gcomm_, &nproc_);
*/
#ifdef TIMING_PERF
	uloga("TIMING_PERF init_dspaces peer %d time %lf\n", common_rank(), tm_end-tm_st);
#endif

	unsigned int ts;
	for(ts = 1; ts <= timesteps_; ts++){
		couple_write_nd(ts, num_vars, type, ndims, lock_num); 
	}
/*
	if(type == USE_DIMES){
		common_lock_on_write("mnd_lock", &gcomm_);
		common_put_sync(type);
		common_unlock_on_write("mnd_lock", &gcomm_);
	}
*/
	if(rank == 0){
		uloga("%s(): done\n", __func__);
	}
/*
	MPI_Barrier(gcomm_);

	int ds_rank = common_rank();
	tm_st = timer_read(&timer_);
	common_finalize();
	tm_end = timer_read(&timer_);
*/
#ifdef TIMING_PERF
	uloga("TIMING_PERF fini_dspaces peer %d time= %lf\n", ds_rank, tm_end-tm_st);
#endif

        return 0;
}

int test_get_run(enum transport_type type, int npapp, int ndims, int* npdim, uint64_t* spdim, int timestep, int appid, size_t elem_size, int num_vars, int* vars_name,
 MPI_Comm gcomm, int lock_num)
{
	gcomm_ = gcomm;
	elem_size_ = elem_size;
	timesteps_ = timestep;
	npapp_ = npapp;
	
	int i;
	for(i = 0; i < ndims; i++){
        np[i] = npdim[i];
		sp[i] = spdim[i];
	}

	for (i = 0; i < num_vars; i++){
		variable_names[i] = vars_name[i];
	}
/*
	timer_init(&timer_, 1);
    timer_start(&timer_);

	int app_id = appid;
	double tm_st, tm_end;
	tm_st = timer_read(&timer_);
	common_init(npapp_, app_id, &gcomm_, NULL);
	tm_end = timer_read(&timer_);
	common_get_transport_type_str(type, transport_type_str_);

	MPI_Comm_rank(gcomm_, &rank_);
    MPI_Comm_size(gcomm_, &nproc_);
*/
#ifdef TIMING_PERF
	uloga("TIMING_PERF init_dspaces peer %d time %lf\n", common_rank(), tm_end-tm_st);
#endif
	unsigned int ts;
	for(ts = 1; ts <= timesteps_; ts++){
		couple_read_nd(ts, num_vars, type, ndims, lock_num);
	}

	if(rank_ == 0){
		uloga("%s(): done\n", __func__);
	}
/*
	MPI_Barrier(gcomm_);

	int ds_rank = common_rank();
	tm_st = timer_read(&timer_);
	common_finalize();
	tm_end = timer_read(&timer_);
*/
#ifdef TIMING_PERF
	uloga("TIMING_PERF fini_dspaces peer %d time= %lf\n", ds_rank, tm_end-tm_st);
#endif

    return 0;
}



int main(int argc, char **argv)
{


    //Yubo
	if (parse_args(argc, argv, &type, &npapp, &dims, np, sp,
    		&timestep, &appid, &elem_size, &num_vars, vars_name) != 0) {
		goto err_out;
	}

	// Using SPMD style programming
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Barrier(MPI_COMM_WORLD);
	gcomm = MPI_COMM_WORLD;

	timer_init(&timer_, 1);
    timer_start(&timer_);

	common_init(npapp, appid, &gcomm, NULL);
	common_get_transport_type_str(type, transport_type_str_);



	//int color = 3;
	//MPI_Comm_split(MPI_COMM_WORLD, color, rank, &gcomm);

	num_vars = 1;
	vars_name[0] = 1;
	lock_num = 1;

	// Run as data reader
	test_get_run(type, npapp, dims, np,
		sp, timestep, appid, elem_size, num_vars, vars_name, gcomm, lock_num);

	num_vars = 1;
	vars_name[0] = 3;
	lock_num = 3;

	// Run as data reader
	test_get_run(type, npapp, dims, np,
		sp, timestep, appid, elem_size, num_vars, vars_name, gcomm, lock_num);
	
	MPI_Barrier(gcomm);
	uloga("test_lev2 DONE\n");
	MPI_Finalize();

	return 0;	
err_out:
	uloga("error out!\n");
	return -1;	
}


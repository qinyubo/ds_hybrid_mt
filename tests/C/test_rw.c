#include <stdio.h>
#include <stdint.h>

#include "debug.h"
#include "common.h"

#include "mpi.h"

extern int test_put_run(enum transport_type, int npapp, int dims, 
	int* npdim, uint64_t *spdim, int timestep, int appid, 
	size_t elem_size, int num_vars, MPI_Comm gcomm);

extern int test_get_run(enum transport_type, int npapp, int dims,
	int *npdim, uint64_t *spdim, int timestep, int appid, 
	size_t elem_size, int num_vars, MPI_Comm gcomm);

int main(int argc, char **argv)
{
	int err;
	int nprocs, rank;
	MPI_Comm gcomm_w;
	MPI_Comm gcomm_r;

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

	if (parse_args(argc, argv, &type, &npapp, &dims, np, sp,
    		&timestep, &appid, &elem_size, &num_vars) != 0) {
		goto err_out;
	}

	// Using SPMD style programming
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Barrier(MPI_COMM_WORLD);
	gcomm_w = MPI_COMM_WORLD;
	gcomm_r = MPI_COMM_WORLD;


	int color_w = 1;
	MPI_Comm_split(MPI_COMM_WORLD, color_w, 1, &gcomm_w);

	// Run as data writer
	test_put_run(type, npapp, dims, np,
		sp, timestep, appid, elem_size, num_vars, gcomm_w);

	printf("Debug #1\n");

	//int color_r = 2;
	//MPI_Comm_split(MPI_COMM_WORLD, color_r, 2, &gcomm_r);
        printf("Debug #2\n");
	sleep(3);
        printf("Debug #3\n");
	test_get_run(type, npapp, dims, np,
		sp, timestep, appid, elem_size, num_vars, gcomm_w);
        printf("Debug #4\n");
	MPI_Barrier(gcomm_w);
	//MPI_Barrier(gcomm_r);

	MPI_Finalize();

	return 0;	
err_out:
	uloga("error out!\n");
	return -1;	
}

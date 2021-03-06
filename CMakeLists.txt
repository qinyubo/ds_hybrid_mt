cmake_minimum_required(VERSION 3.10)
project(ds_hybrid_mt)

set(CMAKE_CXX_STANDARD 11)

include_directories(.)
include_directories(dart)
include_directories(dart/dcmf)
include_directories(dart/gni)
include_directories(dart/ib)
include_directories(dart/ib_cpp/include)
include_directories(dart/pami)
include_directories(dart/portals)
include_directories(dart/tcp)
include_directories(examples/mandelbrot)
include_directories(include)
include_directories(tcp_bak)
include_directories(tests/C)

add_executable(ds_hybrid_mt
        dart/dcmf/dart_rdma_dcmf.c
        dart/dcmf/dart_rdma_dcmf.h
        dart/dcmf/dart_rpc_dcmf.c
        dart/dcmf/dart_rpc_dcmf.h
        dart/dcmf/dc_base_dcmf.c
        dart/dcmf/dc_base_dcmf.h
        dart/dcmf/ds_base_dcmf.c
        dart/dcmf/ds_base_dcmf.h
        dart/gni/dart_rdma_gni.c
        dart/gni/dart_rdma_gni.h
        dart/gni/dart_rpc_gni.c
        dart/gni/dart_rpc_gni.h
        dart/gni/dc_base_gni.c
        dart/gni/dc_base_gni.h
        dart/gni/ds_base_gni.c
        dart/gni/ds_base_gni.h
        dart/gni/utility_functions.h
        dart/ib/dart_rdma_ib.c
        dart/ib/dart_rdma_ib.h
        dart/ib/dart_rpc_ib.c
        dart/ib/dart_rpc_ib.h
        dart/ib/dc_base_ib.c
        dart/ib/dc_base_ib.h
        dart/ib/ds_base_ib.c
        dart/ib/ds_base_ib.h
        dart/ib_cpp/include/dart_rdma_ib.h
        dart/ib_cpp/include/dart_rpc_ib.h
        dart/ib_cpp/include/dc_base_ib.h
        dart/ib_cpp/include/ds_base_ib.h
        dart/ib_cpp/include/patch_ib.h
        dart/ib_cpp/include/patch_ib_cpp.h
        dart/ib_cpp/dart_rdma_ib_.cpp
        dart/ib_cpp/dart_rpc_ib_.cpp
        dart/ib_cpp/dc_base_ib_.cpp
        dart/ib_cpp/ds_base_ib_.cpp
        dart/ib_cpp/exp.cpp
        dart/ib_cpp/patch_ib_cpp.cpp
        dart/pami/dart_rdma_pami.c
        dart/pami/dart_rdma_pami.h
        dart/pami/dart_rpc_pami.c
        dart/pami/dart_rpc_pami.h
        dart/pami/dc_base_pami.c
        dart/pami/dc_base_pami.h
        dart/pami/ds_base_pami.c
        dart/pami/ds_base_pami.h
        dart/portals/dart_rpc_portals.c
        dart/portals/dart_rpc_portals.h
        dart/portals/dc_base_portals.c
        dart/portals/dc_base_portals.h
        dart/portals/ds_base_portals.c
        dart/portals/ds_base_portals.h
        dart/tcp/dart_rpc_tcp.c
        dart/tcp/dart_rpc_tcp.h
        dart/tcp/dc_base_tcp.c
        dart/tcp/dc_base_tcp.h
        dart/tcp/ds_base_tcp.c
        dart/tcp/ds_base_tcp.h
        dart/dart.h
        dart/debug.h
        dart/list.h
        examples/ex1_putget/get.c
        examples/ex1_putget/put.c
        examples/ex2_boundingBox/get.c
        examples/ex2_boundingBox/put.c
        examples/ex3_minmax/minmaxavg_reader.c
        examples/ex3_minmax/minmaxavg_writer.c
        examples/ex4_2d_array/dynamic2d/get_2d.c
        examples/ex4_2d_array/dynamic2d/put_2d.c
        examples/ex4_2d_array/static2d/get_2d.c
        examples/ex4_2d_array/static2d/put_2d.c
        examples/ex5_matrix_mult/get_2d.c
        examples/ex5_matrix_mult/put.c
        examples/mandelbrot/bitmap.c
        examples/mandelbrot/bitmap.h
        examples/mandelbrot/master.c
        examples/mandelbrot/worker.c
        include/bbox.h
        include/common_dataspaces.h
        include/dataspaces.h
        include/dc_gspace.h
        include/dimes_client.h
        include/dimes_data.h
        include/dimes_interface.h
        include/dimes_server.h
        include/ds_gspace.h
        include/merge.h
        include/queue.h
        include/rexec.h
        include/sfc.h
        include/ss_data.h
        include/timer.h
        include/util.h
        src/bbox.c
        src/common_dataspaces.c
        src/dataspaces.c
        src/dataspaces_fortran.c
        src/dc_gspace.c
        src/dimes_client.c
        src/dimes_data.c
        src/dimes_server.c
        src/ds_gspace.c
        src/ss_data.c
        src/timer.c
        src/util.c
        tcp_bak/dart_rpc_tcp.c
        tcp_bak/dart_rpc_tcp.h
        tcp_bak/dc_base_tcp.c
        tcp_bak/dc_base_tcp.h
        tcp_bak/ds_base_tcp.c
        tcp_bak/ds_base_tcp.h
        tests/C/common.c
        tests/C/common.h
        tests/C/dataspaces_server.c
        tests/C/test_get_run.c
        tests/C/test_put_run.c
        tests/C/test_reader.c
        tests/C/test_writer.c
        config.h)

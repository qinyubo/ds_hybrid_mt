#!/bin/bash

cd /home1/yq47/code/dataspace/ds_hybrid_mt
make clean
make
cd /home1/yq47/code/dataspace/ds_hybrid_mt/tests/C
echo "Recompile done!"
bash /home1/yq47/code/dataspace/ds_hybrid_mt/tests/C/cleanall.sh
#echo "Submit job"
#sh /home1/yq47/code/dataspace/dataspaces_mt/test/C/cleanall.sh
#sbatch /home1/yq47/code/dataspace/dataspaces_mt/test/C/run_job.sh
#echo "Done, wait!"

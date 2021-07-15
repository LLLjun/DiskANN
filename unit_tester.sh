#!/bin/sh

# Performs build and search test on disk and memory indices (parameters are tuned for 100K-1M sized datasets)
# All indices and logs will be stored in working_folder after run is complete
# To run, create a catalog text file consisting of the following entries
# For each dataset, specify the following 5 lines, in a line by line format, and then move on to next dataset
# dataset_name[used for save file names]
# /path/to/base.bin
# /path/to/query.bin
# data_type[float/uint8/int8]
# metric[l2/mips]


if [ "$#" -ne "3" ]; then
  echo "usage: ./unit_test.sh [build_folder_path] [catalog] [working_folder]"
else

BUILD_FOLDER=${1}
CATALOG1=${2}
WORK_FOLDER=${3}
mkdir ${WORK_FOLDER}
CATALOG="${WORK_FOLDER}/catalog_formatted.txt"
sed -e '/^$/d' ${CATALOG1} > ${CATALOG}

echo Running unit testing on various files, with build folder as ${BUILD_FOLDER} and working folder as ${WORK_FOLDER}
# download all unit test files

#iterate over them and run the corresponding test


while IFS= read -r line; do
  DATASET=${line}
  read -r BASE
  read -r QUERY
  read -r TYPE
  read -r METRIC
  GT="${WORK_FOLDER}/${DATASET}_gt30_${METRIC}"
  MEM="${WORK_FOLDER}/${DATASET}_mem"
  DISK="${WORK_FOLDER}/${DATASET}_disk"
  MBLOG="${WORK_FOLDER}/${DATASET}_mb.log"
  DBLOG="${WORK_FOLDER}/${DATASET}_db.log"
  MSLOG="${WORK_FOLDER}/${DATASET}_ms.log"
  DSLOG="${WORK_FOLDER}/${DATASET}_ds.log"
  echo "Going to run test on ${BASE} base, ${QUERY} query, ${TYPE} datatype, ${METRIC} metric, saving gt at ${GT}"
  echo "Computing Groundtruth"
  ${BUILD_FOLDER}/tests/utils/compute_groundtruth ${TYPE} ${BASE} ${QUERY} 30 ${GT} ${METRIC} > /dev/null
  echo "Building Mem Index"
  ${BUILD_FOLDER}/tests/build_memory_index ${TYPE} ${METRIC} ${BASE} ${MEM}  32  50  1.2 0 > ${MBLOG}
  awk '/^Degree/' ${MBLOG}
  awk '/^Indexing/' ${MBLOG}
  echo "Building Disk Index"
  ${BUILD_FOLDER}/tests/build_disk_index  ${TYPE} ${METRIC} ${BASE} ${DISK} 32 50 0.03 0.03 32 0 > ${DBLOG}
  awk '/^Compressing/' ${DBLOG}
  echo "#shards in disk index"
  awk '/^bin:/' ${DBLOG}
  awk '/^Indexing/' ${DBLOG}
  echo "Searching Mem Index"
  ${BUILD_FOLDER}/tests/search_memory_index ${TYPE} ${METRIC} ${BASE} ${MEM} 16 ${QUERY} ${GT} 10 /tmp/res 10 20 30 40 50 60 70 80 90 100 > ${MSLOG}
  awk '/===/{x=NR+10}(NR<=x){print}' ${MSLOG}
  echo "Searching Disk Index"
  ${BUILD_FOLDER}/tests/search_disk_index ${TYPE} ${METRIC} ${DISK} 10000 10 4 ${QUERY} ${GT} 10 /tmp/res 10 20 30 40 50 60 70 80 90 100 > ${DSLOG}
  awk '/===/{x=NR+10}(NR<=x){print}' ${DSLOG}
done < "${CATALOG}"
fi

#!/bin/bash
# Sets up and runs full pipeline for BCL files downloaded from cellranger
#   Reference - https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/mkfastq
# RUN:
#   $ IMAGE=nf-fastq-plus-playground
#   $ docker image build -t ${IMAGE} .
#   $ docker run -m=4g -it --entrypoint /bin/bash -v $(pwd)/../../nf-fastq-plus:/nf-fastq-plus
#   [root@1080a8b84933 /]$ /nf-fastq-plus/testPipeline/e2e/cellranger_demux_stats.sh

LOCATION=$(realpath $(dirname "$0"))
RUN=200514_ROSALIND_0001_FLOWCELL
TEST_OUTPUT=${LOCATION}/main_test

FASTQ_DIR=${TEST_OUTPUT}/FASTQ
STATS_DIR=${TEST_OUTPUT}/STATS_DIR
SEQUENCER_DIR=${TEST_OUTPUT}/sequencers
LAB_SAMPLE_SHEET_DIR=${TEST_OUTPUT}/LIMS_SampleSheets
PROCESSED_SAMPLE_SHEET_DIR="${TEST_OUTPUT}/DividedSampleSheets"
COPIED_SAMPLE_SHEET_DIR="${TEST_OUTPUT}/SampleSheetCopies"
STATSDONEDIR="${STATS_DIR}/DONE"

mkdir -p ${FASTQ_DIR}
mkdir -p ${STATS_DIR}
mkdir -p ${SEQUENCER_DIR}
mkdir -p ${LAB_SAMPLE_SHEET_DIR}
mkdir -p ${PROCESSED_SAMPLE_SHEET_DIR}
mkdir -p ${COPIED_SAMPLE_SHEET_DIR}
mkdir -p ${STATSDONEDIR}

LOG_DIR=${TEST_OUTPUT}/logs
mkdir -p ${LOG_DIR}
LOG_FILE="${LOG_DIR}/nf_fastq_run.log"
CMD_FILE="${LOG_DIR}/commands.log"
DEMUX_LOG_FILE="${LOG_DIR}/bcl2fastq.log"

TEST_NEXTFLOW_CONFIG=${LOCATION}/nextflow.config

# Create a basic samplesheet
SAMPLE_SHEET=${LAB_SAMPLE_SHEET_DIR}/SampleSheet_${RUN}.csv
echo "[Header],,,,,,,," > ${SAMPLE_SHEET}
echo "IEMFileVersion,4,,,,,,," >> ${SAMPLE_SHEET}
echo "Date,5/10/2021,,,,,,," >> ${SAMPLE_SHEET}
echo "Workflow,GenerateFASTQ,,,,,,," >> ${SAMPLE_SHEET}
echo "Application,MICHELLE,,,,,,," >> ${SAMPLE_SHEET}
echo "Assay,,,,,,,," >> ${SAMPLE_SHEET}
echo "Description,,,,,,,," >> ${SAMPLE_SHEET}
echo "Chemistry,Default,,,,,,," >> ${SAMPLE_SHEET}
echo ",,,,,,,," >> ${SAMPLE_SHEET}
echo "[Reads],,,,,,,," >> ${SAMPLE_SHEET}
echo "27,,,,,,,," >> ${SAMPLE_SHEET}
echo "91,,,,,,,," >> ${SAMPLE_SHEET}
echo ",,,,,,,," >> ${SAMPLE_SHEET}
echo "[Settings],,,,,,,," >> ${SAMPLE_SHEET}
echo "Adapter,,,,,,,," >> ${SAMPLE_SHEET}
echo ",,,,,,,," >> ${SAMPLE_SHEET}
echo "[Data],,,,,,,," >> ${SAMPLE_SHEET}
echo "Lane,Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,Sample_Project,Description" >> ${SAMPLE_SHEET}
echo "1,Sample_IGO_10001_1,IGO_10001_1_test_sample,Human,10X_Genomics_GeneExpression,SI-GA-A3,SI-GA-A3,Project_10001,Investigator_1" >> ${SAMPLE_SHEET}

# Create nextflow config that 1) runs locally, 2) Has relative directory paths, 3) Has Docker images
echo "executor {" > ${TEST_NEXTFLOW_CONFIG}
echo "  name = 'local'" >> ${TEST_NEXTFLOW_CONFIG}
echo "  scratch = true" >> ${TEST_NEXTFLOW_CONFIG}
echo "  TMPDIR = '/scratch'" >> ${TEST_NEXTFLOW_CONFIG}
echo "}" >> ${TEST_NEXTFLOW_CONFIG}
cat ${LOCATION}/../../nextflow.config | sed -n '/env {/,$p' \
  | sed -E "s#BWA=.*#BWA=\"/usr/bin/bwa\"#" \
  | sed -E "s#PICARD=.*#PICARD=\"java -jar /usr/local/bioinformatics/picard.jar\"#" \
  | sed -E "s#CELL_RANGER=.*#CELL_RANGER=\"/usr/local/bioinformatics/cellranger-6.0.0/bin/cellranger\"#" \
  | sed -E "s#SAMTOOLS=.*#SAMTOOLS=\"/usr/bin/samtools\"#" \
  | sed -E "s#FASTQ_DIR=.*#FASTQ_DIR=\"${FASTQ_DIR}\"#" \
  | sed -E "s#STATS_DIR=.*#STATS_DIR=\"${STATS_DIR}\"#" \
  | sed -E "s#SEQUENCER_DIR=.*#SEQUENCER_DIR=\"${SEQUENCER_DIR}\"#" \
  | sed -E "s#LAB_SAMPLE_SHEET_DIR=.*#LAB_SAMPLE_SHEET_DIR=\"${LAB_SAMPLE_SHEET_DIR}\"#" \
  | sed -E "s#PROCESSED_SAMPLE_SHEET_DIR=.*#PROCESSED_SAMPLE_SHEET_DIR=\"${PROCESSED_SAMPLE_SHEET_DIR}\"#" \
  | sed -E "s#COPIED_SAMPLE_SHEET_DIR=.*#COPIED_SAMPLE_SHEET_DIR=\"${COPIED_SAMPLE_SHEET_DIR}\"#" \
  | sed -E "s#STATSDONEDIR=.*#STATSDONEDIR=\"${STATSDONEDIR}\"#" \
  | sed -E "s#LOG_FILE=.*#LOG_FILE=\"${LOG_FILE}\"#" \
  | sed -E "s#CMD_FILE=.*#CMD_FILE=\"${CMD_FILE}\"#" \
  | sed -E "s#DEMUX_LOG_FILE=.*#DEMUX_LOG_FILE=\"${DEMUX_LOG_FILE}\"#" \
  | sed -E "s#CELLRANGER_WAIT_TIME=.*#CELLRANGER_WAIT_TIME=1#" \
  >> ${TEST_NEXTFLOW_CONFIG}
  # | sed -E "s#=.*#=\"${}\"#" \

REFERENCE_10X="/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa"
REQUIRED_DIR=$(dirname ${REFERENCE_10X})
if [[ ! -d ${REQUIRED_DIR} ]]; then
  echo "Please run on cluster w/ ${REQUIRED_DIR}"
  exit 0
fi

# Unpack the files
TEST_MACHINE_DIR=${SEQUENCER_DIR}/rosalind
TEST_BCL_DIR=${TEST_MACHINE_DIR}/${RUN}

if [[ -d ${TEST_BCL_DIR} ]]; then
  echo "${TEST_BCL_DIR} already exists. Skipping cellranger download"
else
  echo "Downloading cellranger BCL files"
  # Download raw cellranger BCL files
  curl https://cf.10xgenomics.com/supp/cell-exp/cellranger-tiny-bcl-1.2.0.tar.gz -o cellranger-tiny-bcl-1.2.0.tar.gz 2> /dev/null
  mkdir -p ${TEST_MACHINE_DIR}
  tar -zxvf cellranger-tiny-bcl-1.2.0.tar.gz -C ${TEST_MACHINE_DIR} 2> /dev/null
  rm cellranger-tiny-bcl-1.2.0.tar.gz
  mv ${TEST_MACHINE_DIR}/cellranger-tiny-bcl-1.2.0 ${TEST_BCL_DIR}
  # Simulate the rsync from sequencer (Needed to properly detect the run)
  touch ${TEST_BCL_DIR}/CopyComplete.txt
fi

RUN_OUT=${RUN}.out

# Go to directory where all other outputs will be written to
echo "Running nextflow form ${TEST_OUTPUT}"
cd ${TEST_OUTPUT}

CMD_LOG="nextflow_out"
touch ${CMD_LOG}

# Run nextflow in ${CMD}, but while processing, get memory stats. This is helpful in GitHub actions if there are any
#   out-of-memory errors because it lets users see the most memory-intensive tasks prior to SIGKILL
# CMD: nextflow -C /nf-fastq-plus/testPipeline/e2e/nextflow.config run /nf-fastq-plus/testPipeline/e2e/../../main.nf --run ${RUN}
DONE_FILE="nextflow_done"
CMD="nextflow -C ${TEST_NEXTFLOW_CONFIG} run ${LOCATION}/../../main.nf --run ${RUN}; touch ${DONE_FILE}"
echo $CMD
set +e
eval $CMD >> ${CMD_LOG} &
set -e
SLEEP_TIME=10
echo "Getting memory usage every ${SLEEP_TIME} seconds"
top -bn1 -o %MEM | head -20
while [[ ! -f ${DONE_FILE} ]]; do
  top -bn1 -o %MEM | head -12
  sleep ${SLEEP_TIME}
done
rm ${DONE_FILE}

tail -100 ${CMD_LOG}

# VERIFICATIONS OF OUTPUT
FILE_SUFFIXES=( ___MD.txt ___AM.txt ___gc_bias_metrics.txt )
ERRORS=""
echo "TEST 1: Checking for bam"
FOUND_BAM=$(find ${STATS_DIR} -type f -name "*.bam")
if [ -z ${FOUND_BAM} ]; then
  ERROR="\tERROR: Pipeline didn't create MarkDuplicate BAM files\n"
  ERRORS="${ERRORS}${ERROR}"
  printf "$ERROR"
else
  printf "\tFound BAM: ${FOUND_BAM}\n"
fi

echo "TEST 2: Checking for following output stat files - ${FILE_SUFFIXES[@]}"
for fs in "${FILE_SUFFIXES[@]}"; do
  FOUND_FILES=$(find ${STATSDONEDIR} -type f -name "*${fs}")
  if [ -z ${FOUND_FILES} ]; then
    ERROR="\tERROR: Pipeline didn't create ${fs} files\n"
    printf "$ERROR"
    ERRORS="${ERRORS}${ERROR}"
  else
    printf "\tFound ${FOUND_FILES}\n"
  fi
done

echo "TEST 3: Checking for cellranger stat output"
CELLRANGER_OUTPUT=$(find ${STATS_DIR} -maxdepth 2 -type d -name cellranger)
if [ -z ${CELLRANGER_OUTPUT} ]; then
  ERROR="\tERROR: Pipeline didn't create cellranger output\n"
  ERRORS="${ERRORS}${ERROR}"
  printf "$ERROR"
else
  printf "\tFound CELLRANGER_OUTPUT=${CELLRANGER_OUTPUT}\n"
  # Note - can't currently test for the cellranger output (e.g. web_summary.html & .cloupe files). The required
  # reference files are at least 20-30 GB of space
fi

echo "TEST 4: Checking that redoing the pipeline fails because the BCLs were already demultiplexed"
cd ${TEST_OUTPUT}
OUT_FILE="$(pwd)/demux_redo_fail.out"
CMD="nextflow -C ${TEST_NEXTFLOW_CONFIG} run ${LOCATION}/../../main.nf --force false --run ${RUN} >> ${OUT_FILE}"
echo "Running Nextflow Pipeline: main.nf (ignoring errors)"
echo ${CMD}
echo ""
set +e
eval ${CMD}
set -e
cd -

echo "Pipeline finished. Running check..."
grep "Has Been Demuxed (Skip)" ${OUT_FILE}
found_success=$?
if [[ ${found_success} -eq 0 ]]; then
  echo "Expected fail from trying to run on an already demuxed run"
else
  ERROR="\tERROR: Did not fail because of already demuxed run\n"
  cat ${OUT_FILE}
  printf "\n\n\n\n"
  printf "$ERROR"
  ERRORS="${ERRORS}${ERROR}"
fi

echo "TEST 5: Demux is skipped w/ --force true option"
cd ${TEST_OUTPUT}
OUT_FILE="$(pwd)/demux_redo_success.out"
CMD="nextflow -C ${TEST_NEXTFLOW_CONFIG} run ${LOCATION}/../../main.nf --force true --run ${RUN} >> ${OUT_FILE}"
echo "Running Nextflow Pipeline: main.nf (ignoring errors)"
echo ${CMD}
echo ""
set +e
eval ${CMD}
cd -

echo "Pipeline finished. Running check..."
grep "Has Been Demuxed (Skip)" ${OUT_FILE}
found_success=$?
set -e      # We put this AFTER the grep b/c we want the grep to fail
if [[ ${found_success} -eq 1 ]]; then
  echo "[SUCCESS] Did not fail because of already demuxed run"
else
  ERROR="\tERROR: Did not skip demultiplex\n"
  cat ${OUT_FILE}
  printf "\n\n\n\n"
  printf "$ERROR"
  ERRORS="${ERRORS}${ERROR}"
fi

if [ -z "${ERRORS}" ]; then
  echo "All tests successful - removing ${TEST_OUTPUT}"
  rm -rf ${TEST_OUTPUT}
else
  cat ${OUT_FILE}
  printf "ERRORS were found - \n${ERRORS}"
  exit 1
fi

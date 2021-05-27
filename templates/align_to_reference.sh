#!/bin/bash
# Submits an alignment to the reference
# Nextflow Inputs:
#   RUN_PARAMS_FILE, env - The suffix of the files we care about
#   FASTQ_CH, FASTQ files to be aligned
#   CMD_FILE, path - where to log all commands to
# Nextflow Outputs:
#   RUN_PARAMS_FILE, file - Output all individual param files
#   SAM_CH, Outputs SAM w/ Readgroups (*.sam)

# TODO 
# Make run directory in /igo/stats/, e.g. /igo/stats/DIANA_0239_AHL5G5DSXY - All alignment and stat files will go here

JOB_ID_LIST_FILE=submitted_jobs.txt  # Saves job IDs submitted to LSF (populated in bwa_mem function). We will wait for them to complete
#########################################
# Runs BWA-MEM on input FASTQs
# SIDE-EFFECTS:
#   Populates writes to JOB_ID_LIST_FILE
# Arguments:
#   Lane - Sequencer Lane, e.g. L001
#   REFERENCE - FASTQ reference genome
#   TYPE - Nucleotide (e.g. DNA/RNA)
#   DUAL - Numeric value for dual 
#   RUN_TAG - Tag for Run-Project-Sample
#   FASTQ* - absolute path to FASTQ
# Global:
#   EXECUTOR - lsf, local
#########################################
bwa_mem () {
  LANE=$1
  REFERENCE=$2
  TYPE=$3
  DUAL=$4
  RUN_TAG=$5
  PROJECT_TAG=$6
  RGID=$7
  FASTQ1_INPUT=$8
  FASTQ2_INPUT=$9
  FASTQ1=$(realpath ${FASTQ1_INPUT})
  FASTQ2=$(realpath ${FASTQ2_INPUT})

  LOG="LANE=${LANE} REFERENCE=${REFERENCE} TYPE=${TYPE} DUAL=${DUAL} RUN_TAG=${RUN_TAG} FASTQ1=${FASTQ1}"
  ENDEDNESS="Paired End"
  if [[ -z $FASTQ2 ]]; then
    # todo - test
    # Single end runs won't have a second FASTQ
    ENDEDNESS="Single End"
    LOG="${LOG} FASTQ2=${FASTQ2}"
  fi
  
  # TODO - "______" is the delimiter that will be used to merge all SAMS from the same lane
  # TODO - This should be set in the config
  SAM_SMP="${RUN_TAG}______${LANE}"
  BWA_SAM="${SAM_SMP}___BWA.sam"
  RGP_SAM=${BWA_SAM/BWA/RGP}    # "${SAM_SMP}___BWA.sam" -> "${SAM_SMP}___RGP.sam"

  # Submit the job locally and then add the JOB ID
  JOB_NAME="BWA_MEM:${SAM_SMP}"

  BWA_MEM_CMD="${BWA} mem -M -t 40 ${REFERENCE} ${FASTQ1} ${FASTQ2} > ${BWA_SAM}"
  ADD_RGP_CMD="${PICARD} AddOrReplaceReadGroups SO=coordinate CREATE_INDEX=true I=${BWA_SAM} O=${RGP_SAM} ID=${RGID} LB=Illumina PU=${PROJECT_TAG} SM=${SAMPLE_TAG} PL=illumina CN=IGO@MSKCC"

  BSUB_SCRIPT=${SAMPLE_TAG}___${RGID}___${LANE}.sh
  echo ${BWA_MEM_CMD} >> ${BSUB_SCRIPT}
  echo ${ADD_RGP_CMD} >> ${BSUB_SCRIPT}
  cat ${BSUB_SCRIPT} >> ${CMD_FILE}
  chmod 755 ${BSUB_SCRIPT}

  # "-t {NUM_THREADS}": # threads should equal # tasks sent to LSF (-n)
  if [[ ${EXECUTOR} == "local" ]]; then
    LOG="RUNNING LOCAL - ${LOG}"
    ./${BSUB_SCRIPT}
  else
    BWA_CMD="bsub -J ${JOB_NAME} -e ${JOB_NAME}_error.log -o ${JOB_NAME}.log -n 40 -M 5 ./${BSUB_SCRIPT}"
    SUBMIT=$(${BWA_CMD})                          # Submits and saves output
    JOB_ID=$(echo $SUBMIT | egrep -o '[0-9]{5,}') # Parses out job id from output
    echo ${JOB_ID} >> ${JOB_ID_LIST_FILE}         # Save job id to wait on later
    LOG="${LOG} OUT=${BWA_SAM} JOB_ID=${JOB_ID}"
  fi
  echo $LOG
}

#########################################
# Reads input file and outputs param value
# Globals:
#   FILE - file of format "P1=V1 P2=V2 ..."
#   PARAM_NAME - name of parameter
# Arguments:
#   Lane - Sequencer Lane, e.g. L001
#   FASTQ* - absolute path to FASTQ
#########################################
parse_param() {
  FILE=$1
  PARAM_NAME=$2

  cat ${FILE}  | tr ' ' '\n' | grep -e "^${PARAM_NAME}=" | cut -d '=' -f2
}

FIRST_FILE=$(find -L . -xtype l -name *${RUN_PARAMS_FILE} | head)
SPECIES_PARAM=$(parse_param ${FIRST_FILE} SPECIES)
TYPE_PARAM=$(parse_param ${FIRST_FILE} TYPE)
JOB_ID_LIST=()      # Saves job IDs submitted to LSF (populated in bwa_mem function). We will wait for them to complete

if [[ ${SPECIES_PARAM} == "Human" && ${TYPE_PARAM} == "RNA" ]]; then
  echo "Will run DRAGEN"
  
  echo "Creating fastq_list.csv DRAGEN input file with the list of all sample fastq.gz files"
  echo "RGID,RGSM,RGLB,Lane,Read1File,Read2File" > fastq_list.csv
  # Write one line per fastq like this example line from DRAGEN documentation:
  # CACACTGA.1,RDSR181520,UnknownLibrary,1,/staging/RDSR181520_S1_L001_R1_001.fastq, /staging/RDSR181520_S1_L001_R2_001.fastq
  for LANE_PARAM_FILE in $(ls *${RUN_PARAMS_FILE}); do
    RGID=$(parse_param ${LANE_PARAM_FILE} RGID)
    RGSM=$(parse_param ${LANE_PARAM_FILE} SAMPLE_TAG)
    RGLB="UnknownLibrary"
    LANE_TAG_PARAM=$(parse_param ${LANE_PARAM_FILE} LANE_TAG)
    LANE=${LANE_TAG_PARAM: -1}  # take only last character of L001

    # TODO - to run this script alone, we need a way to pass in this manually, e.g. FASTQ_LINKS=$(find . -type l -name "*.fastq.gz")
    FASTQ_PARAMS=$(parse_param ${LANE_PARAM_FILE} FASTQ) # new-line separated list of FASTQs
    echo "FASTQ-PARAMS:$FASTQ_PARAMS"
    FASTQ_ARGS=$(echo $FASTQ_PARAMS | tr ' ' ',')      # If DUAL-Ended, then there will be a new line between the FASTQs
    echo "${RGID},${RGSM},${RGLB},${LANE},${FASTQ_ARGS}" >> fastq_list.csv
  done
  
  JOB_NAME="DRAGEN_BAM_${RGSM}"
  DRAGEN_CMD="dragen -r /staging/ref/GRCh38_rna --enable-rna true --enable-duplicate-marking true --output-file-prefix $RGID --output-directory . --fastq-list fastq_list.csv --annotation-file /igo/work/genomes/H.sapiens/gencode.v37.annotation.gtf"
  DRAGEN_BSUB_CMD="bsub -n48 -q dragen -J ${JOB_NAME} -e ${JOB_NAME}_error.log -o ${JOB_NAME}.log ${DRAGEN_CMD}"

  # TODO UNCOMMENT TO RUN COMMAND
  #SUBMIT=$(${DRAGEN_BSUB_CMD})                  # Submits and saves output
  echo "RUNNING DRAGEN CMD:"
  echo "$DRAGEN_BSUB_CMD"
  JOB_ID=$(echo $SUBMIT | egrep -o '[0-9]{5,}') # Parses out job id from output
  JOB_ID_LIST+=( $JOB_ID )                      # Save job id to wait on later

  LOG="JOB_ID=${JOB_ID}"
  echo $LOG

  # TODO - Add way to link BAM to next nextflow module
  # Option 1 - Write BAM to this directory
  # Option 2 - Write BAM elsewhere and provide symbolic link in this directory
else
  for LANE_PARAM_FILE in $(ls *${RUN_PARAMS_FILE}); do
    REFERENCE_PARAM=$(parse_param ${LANE_PARAM_FILE} REFERENCE)
    TYPE_PARAM=$(parse_param ${LANE_PARAM_FILE} TYPE)
    DUAL_PARAM=$(parse_param ${LANE_PARAM_FILE} DUAL)
    RUN_TAG_PARAM=$(parse_param ${LANE_PARAM_FILE} RUN_TAG)
    LANE_TAG_PARAM=$(parse_param ${LANE_PARAM_FILE} LANE_TAG)
    PROJECT_TAG_PARAM=$(parse_param ${LANE_PARAM_FILE} PROJECT_TAG)
    RGID_PARAM=$(parse_param ${LANE_PARAM_FILE} RGID)
    SAMPLE_TAG=$(parse_param ${LANE_PARAM_FILE} SAMPLE_TAG)  # Assign output ID for downstream task

    # TODO - to run this script alone, we need a way to pass in this manually, e.g. FASTQ_LINKS=$(find . -type l -name "*.fastq.gz")
    FASTQ_PARAMS=$(parse_param ${LANE_PARAM_FILE} FASTQ) # new-line separated list of FASTQs
    FASTQ_ARGS=$(echo $FASTQ_PARAMS | tr '\n' ' ')      # If DUAL-Ended, then there will be a new line between the FASTQs

    echo "BWA MEM ARGS: $LANE_TAG_PARAM $REFERENCE_PARAM $TYPE_PARAM $DUAL_PARAM $RUN_TAG_PARAM $PROJECT_TAG_PARAM $RGID_PARAM $FASTQ_ARGS"
    bwa_mem_out=$(bwa_mem $LANE_TAG_PARAM $REFERENCE_PARAM $TYPE_PARAM $DUAL_PARAM $RUN_TAG_PARAM $PROJECT_TAG_PARAM $RGID_PARAM $FASTQ_ARGS)
    echo "BWA JOB OUTPUT: ${bwa_mem_out}"
  done
fi

ALL_JOBS=$(cat ${JOB_ID_LIST_FILE} | tr '\n' ' ')
printf "Submitted Jobs (${EXECUTOR}): %s\n" "${ALL_JOBS}"
for job_id in ${ALL_JOBS}; do
  echo "Waiting for ${job_id} to finish"
  bwait -w "ended(${job_id})" &
done
echo "Waiting for all jobs: $(date +"%T")"
wait
echo "Finished waiting for alignment of $RUN_TAG_PARAM: $(date +"%T")"

for job_id in ${ALL_JOBS}; do
  # Fail pipeline if one alignment job failed - has an exit code that is non-zero
  has_exit_code=$(bjobs -l ${job_id} | grep "exit code")
  has_success_code=$(bjobs -l ${job_id} | grep "exit code 0")

  echo "has_exit_code: ${has_exit_code}"
  echo "has_success_code: ${has_success_code}"
  if [ ! -z "${has_exit_code}" ] && [ -z "${has_success_code}" ]; then
    echo "bwa mem failed (Job Id: ${job_id})"
    exit 1
  else
    echo "bwa mem success (Job Id: ${job_id})"
  fi
done

# Output only the shared key-value pairs of the input param files into a single new param file for the sample
cat *${RUN_PARAMS_FILE} | tr ' ' '\n' | sort | uniq | grep -v LANE_TAG | tr '\n' ' ' > ${RUN_PARAMS_FILE}

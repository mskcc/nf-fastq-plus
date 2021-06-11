#!/bin/bash
# Finds and merges all sample BAMs
# Nextflow Inputs:
#   TODO
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

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

# List of runs and samplesheets
RUN_SS_FILE="run_samplesheet.txt"
touch ${RUN_SS_FILE}

# File with all the run directories that need to have BAMs (output of process)
RUN_FOLDERS_UNIQUE_FILE="run_dirs_uniq.txt"

# Write all runs w/ that project to a file
RUN_FOLDERS_ALL_FILE="run_dirs_all.txt"
PROJECT_DIRS=$(find ${DEMUXED_DIR} -mindepth 1 -maxdepth 1 -type d -name "Project_*" -exec basename {} \;)
for prj in ${PROJECT_DIRS}; do
  find ${FASTQ_DIR} -mindepth 2 -maxdepth 2 -type d -name ${prj} -exec dirname {} \; >> ${RUN_FOLDERS_ALL_FILE}
done
# Filter only the unique runs
cat ${RUN_FOLDERS_ALL_FILE} | tr ' ' '\n' | sort | uniq >> ${RUN_FOLDERS_UNIQUE_FILE}

# Add only the runs that have been archived that aren't in ${FASTQ_DIR}
EXCLUDE_RUNS_FROM_ARCHIVED_REGEX=$(cat ${RUN_FOLDERS_ALL_FILE} | xargs basename  | tr '\n' '|') # "R1 R2..."=>"R1|R2..."
ARCHIVED_RUN_FOLDERS_ALL_FILE="archived_run_dirs_all.txt"
for prj in ${PROJECT_DIRS}; do
  find ${ARCHIVED_DIR} -mindepth 2 -maxdepth 2 -type d -name ${prj} -exec dirname {} \; | \
    grep -v ${EXCLUDE_RUNS_FROM_ARCHIVED_REGEX} \
    >> ${ARCHIVED_RUN_FOLDERS_ALL_FILE}
done
cat ${ARCHIVED_RUN_FOLDERS_ALL_FILE} | tr ' ' '\n' | sort | uniq >> ${RUN_FOLDERS_UNIQUE_FILE}

# TODO - Find the sample sheet
for run_dir in $(cat ${RUN_FOLDERS_UNIQUE_FILE}); do
  # We rely on the samplesheet being in the runs folder
  SS=$(find ${run_dir} -type f -name "SampleSheet*")

  # Quit if no samplesheet is found - can't demux
  if [[ -z ${SS} || ! -f ${SS} ]]; then
    # TODO - send an email?
    echo "Couldn't find a samplesheet"
    exit 0
  fi

  # Assign the BAM directory, unless one doesn't exist
  RUN_BASE=$(basename ${run_dir})
  BAM_DIR=${STATS_DIR}/${RUN_BASE}
  if [[ ! -d ${BAM_DIR} ]]; then
    BAM_DIR="NO_BAM_DIR"
  fi

  # TODO - create a new samplesheet just for this that just has the projects we care about?
  echo "${run_dir} ${SS} ${BAM_DIR}" >> ${RUN_SS_FILE}
done

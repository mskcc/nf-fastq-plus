#!/bin/bash
# Finds all FASTQ directories and samplesheets w/ requests in the input DEMUXED_DIR
# Nextflow Inputs:
#   DEMUXED_DIR, env - FASTQ output of Run
#
#   (config)
#   FASTQ_DIR, env - FASTQ file directories (in-review)
#   ARCHIVED_DIR, env - FASTQ file directories (archived)
#   PROCESSED_SAMPLE_SHEET, env - Directory where all SampleSheets processed by pipeline are written to
# Nextflow Outputs:
#   run_samplesheet.txt - Entries for each demux/bam per line:    RUN_DEMUX_DIR, RUN_SAMPLE_SHEET, BAM_DIR
# Run:
#   DEMUXED_DIR=/path/to/FASTQ/PRJ_ID FASTQ_DIR=/path/to/FASTQ ARCHIVED_DIR=/archived/path/to/FASTQ ./retrieve_all_sample_runs.sh

# NEXTFLOW OUTPUT FILE - Lists sequencing output folder, samplesheet, and BAM directory if it exists
RUN_SS_FILE="run_samplesheet.txt"

# File with all the run directories that need to have BAMs (output of process)
RUN_FOLDERS_UNIQUE_FILE="run_dirs_uniq.txt"

# We remove all the run folders that include the ${RUNNAME} because these should be processed in samplesheet_stats.nf
FILTERED_RUN_FOLDERS="run_dirs_filtered.txt"

# Write all runs w/ that project to a file
RUN_FOLDERS_ALL_FILE="run_dirs_all.txt"
PROJECT_DIRS=$(find ${DEMUXED_DIR} -mindepth 1 -maxdepth 1 -type d -name "Project_*" -exec basename {} \;)
echo "Searching for runs with FASTQs for Projects: $(echo ${PROJECT_DIRS} | tr '\n' ' ')"
for prj in ${PROJECT_DIRS}; do
  find ${FASTQ_DIR} -mindepth 2 -maxdepth 2 -type d -name ${prj} -exec dirname {} \; >> ${RUN_FOLDERS_ALL_FILE}
done

# Filter only the unique runs
cat ${RUN_FOLDERS_ALL_FILE} | tr ' ' '\n' | sort | uniq >> ${RUN_FOLDERS_UNIQUE_FILE}
echo "Found $(cat ${RUN_FOLDERS_UNIQUE_FILE} | wc -l) unique runs in ${FASTQ_DIR} - $(cat ${RUN_FOLDERS_UNIQUE_FILE} | tr '\n' ' ')" 

# Add only the runs that have been archived that aren't in ${FASTQ_DIR}
for run_fldr in $(cat ${RUN_FOLDERS_UNIQUE_FILE}); do
  EXCLUDE_RUNS_FROM_ARCHIVED_REGEX="${EXCLUDE_RUNS_FROM_ARCHIVED_REGEX}|$(basename ${run_fldr})" # "R1 R2..."=>"R1|R2..."
done
EXCLUDE_RUNS_FROM_ARCHIVED_REGEX=$(echo ${EXCLUDE_RUNS_FROM_ARCHIVED_REGEX} | sed 's/^|//g')

ARCHIVED_RUN_FOLDERS_ALL_FILE="archived_run_dirs_all.txt"
for prj in ${PROJECT_DIRS}; do
  find ${ARCHIVED_DIR} -mindepth 2 -maxdepth 2 -type d -name ${prj} -exec dirname {} \; | \
    grep -Ev "${EXCLUDE_RUNS_FROM_ARCHIVED_REGEX}" >> ${ARCHIVED_RUN_FOLDERS_ALL_FILE}
done
cat ${ARCHIVED_RUN_FOLDERS_ALL_FILE} | tr ' ' '\n' | sort | uniq >> ${RUN_FOLDERS_UNIQUE_FILE}

# Perform filtering - eliminate all ${RUNNAME} directories & any "_REFERENCE" folder
echo "ALL FASTQ Directories: $(cat ${RUN_FOLDERS_UNIQUE_FILE} | tr '\n' ' ')"
cat ${RUN_FOLDERS_UNIQUE_FILE} | grep -v ${RUNNAME} | grep -v "_REFERENCE" > "${FILTERED_RUN_FOLDERS}"
echo "Selected FASTQ Directories: $(cat ${FILTERED_RUN_FOLDERS} | tr '\n' ' ')"

# Locate the samplesheets for each run and output to
for run_dir in $(cat ${FILTERED_RUN_FOLDERS}); do
  # We rely on the samplesheet being in the runs folder
  RUN_SS=$(find ${run_dir} -type f -name "SampleSheet*")

  # SampleSheets should be present in the FASTQ directory. If not, try to find one and error if not present
  if [[ -z ${RUN_SS} || ! -f ${RUN_SS} ]]; then
    NO_SS_RUN=$(basename ${run_dir})
    REGEX="SampleSheet_*${NO_SS_RUN}.csv"
    PROCESSED_SAMPLE_SHEET=$(find ${PROCESSED_SAMPLE_SHEET_DIR} -type f -name "${REGEX}")
    if [[ -z ${PROCESSED_SAMPLE_SHEET} || ! -f ${PROCESSED_SAMPLE_SHEET} ]]; then
      fail_msg="[PARENT RUN: ${RUNNAME}] No SampleSheet found in ${PROCESSED_SAMPLE_SHEET_DIR} w/ ${REGEX}. Samples on this run will not be included in final sample BAM"
      echo ${fail_msg}
      echo "${fail_msg}" | mail -s "[SAMPLE BAM CREATION FATAL ERROR - Missing Samplesheet] ${NO_SS_RUN}" ${DATA_TEAM_EMAIL}
      continue # exit 1
    else
      RUN_SS=${PROCESSED_SAMPLE_SHEET}
      err_msg="Failed to find SampleSheet in ${run_dir}. Using ${RUN_SS}. This is needed to merge ${RUNNAME} with legacy runs"
      echo ${err_msg}
      echo "${err_msg}" | mail -s "[WARNING - FASTQ directory missing Samplesheet] ${NO_SS_RUN}" ${DATA_TEAM_EMAIL}
    fi
  fi

  # Assign the BAM directory, unless one doesn't exist. If non-existant, the BAM dir will be recreated
  RUN_BASE=$(basename ${run_dir})
  BAM_DIR=${STATS_DIR}/${RUN_BASE}
  if [[ ! -d ${BAM_DIR} ]]; then
    BAM_DIR="NO_BAM_DIR"
  fi

  # Create a new samplesheet with only the Projects in this run (To avoid redoing any work)
  TARGET_SAMPLESHEET="$(basename ${RUN_SS} | cut -d'.' -f1)___FOR_MERGE.csv"
  sed '/Lane,/q' ${RUN_SS} > ${TARGET_SAMPLESHEET}
  for prj in ${PROJECT_DIRS}; do
    cat ${RUN_SS} | grep ${prj} >> ${TARGET_SAMPLESHEET}
  done

  # Write entry - each line will be processed separately in nextflow
  echo "${run_dir} $(realpath ${TARGET_SAMPLESHEET})" >> ${RUN_SS_FILE}
done

if [[ ! -f ${RUN_SS_FILE} ]]; then
  echo "No legacy runs for requests in ${RUNNAME}"
  echo "NONE NONE" > ${RUN_SS_FILE} # We add a newline to trigger merging of legacy_bams_ch w/ run_bams_ch
fi

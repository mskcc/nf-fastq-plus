#!/bin/bash
# Given an input sample sheet, submit the DRAGEN demultiplexing job
# Nextflow Inputs:
#   SAMPLESHEET:      Absolute path to the sample sheet that will be used for demultiplexing
#   RUN_TO_DEMUX_DIR: Absolute path to bcl files
#   EXECUTOR:         Type of nextflow executor (e.g. local/lsf)
#
#   (config)
#   BCL2FASTQ:        Absolute path to bcl2fastq binary
#   CELL_RANGER_ATAC: Absolute path to cellranger binary
#   FASTQ_DIR:        Directory w/ FASTQ files
#   DEMUX_LOG_FILE:   Log file where demux output is written to
#   CMD_FILE:         Log file to write commands to
#   DATA_TEAM_EMAIL:  emails of data team members who should be notified
# Nextflow Outputs:
#   DEMUXED_DIR, env: path to where the run has been demuxed to
#   SAMPLE_SHEET,env: path to samplesheet used to demultiplex
# Run:
#   SAMPLESHEET=/path/to/SampleSheet...csv RUN_TO_DEMUX_DIR=/path/to/bcl_files BCL2FASTQ=/path/to/bcl2fastq/binary \
#     CELL_RANGER_ATAC=/path/to/cellranger/binary FASTQ_DIR=/path/to/write/FASTQs CMD_FILE=cmds.txt \
#     DEMUX_LOG_FILE=demux.txt dgn_demultiplex.sh

BCL_LOG="bcl2fastq.log"

# SampleSheet_201204_PITT_0527_BHK752BBXY_i7.csv   ->   "PITT_0527_BHK752BBXY_i7"
SAMPLESHEET=$(echo $SAMPLESHEET | tr -d " \t\n\r")	# Sometimes "\n" or "\t" characters can be appended
basename ${SAMPLESHEET}
# TODO - fix "perl-regexp" for portability
RUN_BASENAME=$(basename ${SAMPLESHEET} | grep -oP "(?<=[0-9]_)[A-Za-z_0-9-]+") # Capture after "[ANY NUM]_" (- ".csv")
echo "RUN_BASENAME: ${RUN_BASENAME}"
DEMUXED_DIR="${FASTQ_DIR}/${RUN_BASENAME}"

echo "Procesisng SampleSheet ${SAMPLESHEET} (DEMUX_ALL=${DEMUX_ALL})"

if [[ "${DEMUX_ALL}" == "true" && -d ${DEMUXED_DIR}  ]]; then
  LOG="Skipping demux (DEMUX_ALL=${DEMUX_ALL}) of already demuxed directory: ${DEMUXED_DIR}"
  echo "${LOG}"
  echo $LOG >> ${BCL_LOG}
else
  if [[ -d ${DEMUXED_DIR} ]]; then
    # This was added for demultiplexing task's re-try logic. Manually running the pipeline from start never reaches here
    ts=$(date +'%m_%d_%Y___%H:%M')
    BACKUP_DEMUX_DIR=${DEMUXED_DIR}_${ts}
    # bcl2fastq will merge new FASTQ data to existing FASTQ files, which would be inaccurate
    LOG="FASTQ files have been written to ${DEMUXED_DIR}. Moving to ${BACKUP_DEMUX_DIR}"
    echo ${LOG}
    mv ${DEMUXED_DIR} ${BACKUP_DEMUX_DIR}
  fi

  mkdir -p ${DEMUXED_DIR}
  chmod -R 775 $DEMUXED_DIR
  cp $SAMPLESHEET $DEMUXED_DIR
  echo "Writing FASTQ files to $DEMUXED_DIR"
  echo "SAMPLESHEET: ${SAMPLESHEET}"

  JOB_CMD="/opt/edico/bin/dragen --bcl-conversion-only true --bcl-input-directory ${RUN_TO_DEMUX_DIR} --sample-sheet ${SAMPLESHEET} --output-directory ${DEMUXED_DIR}"

  echo ${JOB_CMD} >> ${CMD_FILE}

  echo "Running demux"
  # Disable error - we want the output of ${BCL_LOG} logged somewhere. We want to alert on failed demux below
  set +e
  eval ${JOB_CMD}
  UNDETERMINED_SIZE=$(du -sh  ${DEMUXED_DIR}/Undet*);
  PROJECT_SIZE=$(du -sh ${DEMUXED_DIR}/Proj*/*);

  cat ${BCL_LOG} >> ${DEMUX_LOG_FILE}
  cat ${BCL_LOG}

  # TODO - Add a filtering process to determine which demux files are valid since it's possible for a job to have failed
  # NEXTFLOW ENVIRONMENT VARIABLES - These environment variables are passed to the next nextflow process
  echo "Demultiplexed DEMUXED_DIR: ${DEMUXED_DIR}, SAMPLESHEET: ${SAMPLESHEET}"
  FILE_OUTPUT_SIZE=$(printf "%s\n\n%s\n" "${UNDETERMINED_SIZE}" "$Proj_Size")
  REPORT="To view reports visit: ${DEMUXED_DIR}/Reports/html/index.html"
  FULL=$(printf "%s\n\n%s\n" "$FILE_OUTPUT_SIZE" "$REPORT")

  echo "DEMUX_UPDATE: ${FULL}"
  if [ -n "$FILE_OUTPUT_SIZE" ]; then
    echo "MAIL: Starting stats for run ${RUN_BASENAME} ${DATA_TEAM_EMAIL}"
    echo $FULL | mail -s "[SUCCESSFUL DEMUX] Starting stats for run ${RUN_BASENAME}" ${DATA_TEAM_EMAIL}
  else
    # Do not remove this noticiation because ...
    #   - FAILED SEQUENCER COPIES - Some sequencers (e.g. SCOTT) delete their old data w/ each new run,
    #     i.e. $30,000 run could be deleted just b/c the copy didn't work correctly
    #   - IGNORE ERROR STRATEGY - current nextflow error strategy for the demultiplex task is "ignore", meaning this
    #     will NOT exit the workflow and this task will fail quietly. Without this notification, there will be a delay
    #     to when this failed demux is caught
    echo "MAIL: Failed Demux Run ${RUN_TO_DEMUX} ${DATA_TEAM_EMAIL}"
    echo $FULL | mail -s "[FAILED DEMUX] ${RUN_TO_DEMUX}" ${DATA_TEAM_EMAIL}
    exit 1
  fi
fi

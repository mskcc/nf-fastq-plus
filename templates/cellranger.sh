#!/bin/bash
# Runs CellRanger analysis
# Nextflow Inputs:
#   RUN_PARAMS_FILE, path - file w/ k=v pairs of parameters
#   BAM_CH, path - BAM file to analyz
#   STATSDONEDIR, env - Where to write stats
#
#   (config)
#   PICARD,           picard command
#   CELL_RANGER_ATAC, cellranger binary
#   CELL_RANGER,      cellranger binary
#   CELL_RANGER_CNV,  cellranger binary
#   RUN_PARAMS_FILE,  cellranger binary
#   CMD_FILE          Absolute path to file that logs commands

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

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard CollectAlignmentSummaryMetrics ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD}  >> ${CMD_FILE}
  eval ${INPUT_CMD}
}

RUN_PARAMS_FILE=$(realpath ${RUN_PARAMS_FILE})           # Take absolute path since we navigate to the cellranger dir
RECIPE=$(parse_param ${RUN_PARAMS_FILE} RECIPE)          # Musts include a WGS genome to run CollectWgsMetrics
SAMPLE_TAG=$(parse_param ${RUN_PARAMS_FILE} SAMPLE_TAG)
PROJECT_TAG=$(parse_param ${RUN_PARAMS_FILE} PROJECT_TAG)
RUNNAME=$(parse_param ${RUN_PARAMS_FILE} RUNNAME)
SPECIES=$(parse_param ${RUN_PARAMS_FILE} SPECIES)

# File that will be populated w/ directory & stat files to upload
#   e.g.
#     /igo/staging/stats/RUN/cellranger/project/sample runname project sample web_summary.html metrics_summary.csv
launched_cellranger_dirs="$(pwd)/launched_cellranger_dirs.txt"
METRICS_FILE="metrics_summary.csv"
WEB_SUMMARY="web_summary.html"
touch ${launched_cellranger_dirs}

is_10X=$(echo $RECIPE | grep "10X_Genomics_")
if [[ -z ${is_10X} ]]; then
  echo "Non-10X Recipe: ${RECIPE}. Skipping"
else
  echo "Searching directory ${FASTQ_DIR} for Sample_${SAMPLE_TAG} directory"
  # Find All Sample Directories, e.g. /igo/work/FASTQ/SCOTT_0339_AH2VTWBGXJ_10X/Project_11926/Sample_ESC_IGO_11926_1
  SAMPLE_FASTQ_DIRS_ACROSS_RUNS=$(find ${FASTQ_DIR} -mindepth 3 -maxdepth 3 -type d -name "Sample_${SAMPLE_TAG}")
  if [[ -z ${SAMPLE_FASTQ_DIRS_ACROSS_RUNS} ]]; then
    echo "Unable to locate FASTQ DIRS"
    exit 1
  fi

  CELLRANGER_FASTQ_INPUT=$(echo ${SAMPLE_FASTQ_DIRS_ACROSS_RUNS} | tr ' ' ',') # cellranger input: comma-delimited list
  CELLRANGER_DIR=${STATS_DIR}/${RUNNAME}/cellranger/${PROJECT_TAG}             # Specific path to BAMs - will write sample folder
  SAMPLE_CELLRANGER_DIR=${CELLRANGER_DIR}/${SAMPLE_TAG}                        # Cellranger writes to this location a directory of the name passed to "--id=${SAMPLE_TAG}"

  mkdir -p ${CELLRANGER_DIR}
  cd ${CELLRANGER_DIR}
  echo "Detected 10X Recipe: ${RECIPE} (${SPECIES})"
  if [[ ! -z $(echo ${RECIPE} | grep "10X_Genomics.*Expression.*") ]]; then
    echo "Processing GeneExpression"
    CELLRANGER_TRANSCRIPTOME=$(parse_param ${RUN_PARAMS_FILE} CELLRANGER_COUNT)
    # 10X_Genomics_NextGEM-GeneExpression
    # 10X_Genomics_NextGem_GeneExpression-5
    # 10X_Genomics_NextGEM_GeneExpression-5
    # 10X_Genomics_GeneExpression
    # 10X_Genomics_GeneExpression-3
    # 10X_Genomics_GeneExpression-5
    CMD="${CELL_RANGER} count"
    CMD+=" --id=${SAMPLE_TAG}"
    CMD+=" --transcriptome=${CELLRANGER_TRANSCRIPTOME}"
    CMD+=" --fastqs=${CELLRANGER_FASTQ_INPUT}"
    CMD+=" --nopreflight"
    CMD+=" --jobmode=lsf"
    CMD+=" --mempercore=64"
    CMD+=" --disable-ui"
    CMD+=" --maxjobs=200"

    run_cmd $CMD
    if [[ 0 -eq $? ]]; then
      # Place after command - only if the above command fails, should we wait
      echo "${SAMPLE_CELLRANGER_DIR} count ${METRICS_FILE} ${WEB_SUMMARY}" >> ${launched_cellranger_dirs}
    fi
  fi
  if [[ ! -z $(echo ${RECIPE} | grep "${REGEX_10X_Genomics_VDJ}") ]]; then
    CELLRANGER_REFERENCE=$(parse_param ${RUN_PARAMS_FILE} CELLRANGER_VDJ)
    echo "Processing VDJ"
    # 10X_Genomics_NextGem_VDJ
    # 10X_Genomics_NextGEM_VDJ
    # 10X_Genomics_NextGEM-VDJ
    # 10X_Genomics_VDJ
    # 10X_Genomics-VDJ
    CMD="${CELL_RANGER} vdj"
    CMD+=" --id=${SAMPLE_TAG}"
    CMD+=" --reference=${CELLRANGER_REFERENCE}"
    CMD+=" --fastqs=${CELLRANGER_FASTQ_INPUT}"
    CMD+=" --sample=${SAMPLE_TAG}"
    CMD+=" --nopreflight"
    CMD+=" --jobmode=lsf"
    CMD+=" --mempercore=64"
    CMD+=" --disable-ui"
    CMD+=" --maxjobs=200"

    run_cmd $CMD
    if [[ 0 -eq $? ]]; then
      # Place after command - only if the above command fails, should we wait
      echo "${SAMPLE_CELLRANGER_DIR} vdj ${METRICS_FILE}" >> ${launched_cellranger_dirs}
    fi
  fi

  # Check if a command has been sent, if not, it is a more specialized recipe
  if [[ -z ${CMD} ]]; then
    if [[ ! -z $(echo ${RECIPE} | grep "10X_Genomics_Visium") ]]; then
      # TODO
      echo "Processing Visium"
      # 10X_Genomics_Visium
    elif [[ ! -z $(echo ${RECIPE} | grep "${REGEX_10X_Genomics_ATAC}") ]]; then
      echo "Processing ATAC count"
      CELLRANGER_REFERENCE=$(parse_param ${RUN_PARAMS_FILE} CELLRANGER_ATAC)
      # 10X_Genomics_ATAC
      CMD="${CELL_RANGER_ATAC} count"
      CMD+=" --id=${SAMPLE_TAG}"
      CMD+=" --fastqs=${CELLRANGER_FASTQ_INPUT}"
      CMD+=" --reference=${CELLRANGER_REFERENCE}"
      CMD+=" --nopreflight"
      CMD+=" --jobmode=lsf"
      CMD+=" --mempercore=64"
      CMD+=" --disable-ui"
      CMD+=" --maxjobs=200"

      run_cmd $CMD
      if [[ 0 -eq $? ]]; then
        # Place after command - only if the above command fails, should we wait
        echo "${SAMPLE_CELLRANGER_DIR} count ${METRICS_FILE}" >> ${launched_cellranger_dirs}
      fi
    elif [[ ! -z $(echo ${RECIPE} | grep "${REGEX_10X_Genomics_CNV}") ]]; then
      echo "Processing cnv count"
      # 10X_Genomics_CNV
      CELLRANGER_REFERENCE=$(parse_param ${RUN_PARAMS_FILE} CELLRANGER_CNV)
      CMD="${CELL_RANGER_CNV} cnv"
      CMD+=" --id=${SAMPLE_TAG}"
      CMD+=" --fastqs=${CELLRANGER_FASTQ_INPUT}"
      CMD+=" --reference=${CELLRANGER_REFERENCE}"
      CMD+=" --nopreflight"
      CMD+=" --jobmode=lsf"
      CMD+=" --mempercore=64"
      CMD+=" --disable-ui"
      CMD+=" --maxjobs=200"

      run_cmd $CMD
      if [[ 0 -eq $? ]]; then
        # Place after command - only if the above command fails, should we wait
        echo "${SAMPLE_CELLRANGER_DIR} count ${METRICS_FILE}" >> ${launched_cellranger_dirs}
      fi
    elif [[ ! -z $(echo ${RECIPE} | grep "${REGEX_10X_Genomics_ATAC_MULTIOME}") ]]; then
      echo "Processing Multiome"
      CELLRANGER_REFERENCE=$(parse_param ${RUN_PARAMS_FILE} CELLRANGER_ARC)
      CMD="${CELL_RANGER_ARC} count"
      CMD+=" --id=${SAMPLE_TAG}"
      CMD+=" --fastqs=${CELLRANGER_FASTQ_INPUT}"
      CMD+=" --reference=${CELLRANGER_REFERENCE}"
      CMD+=" --nopreflight"
      CMD+=" --jobmode=lsf"
      CMD+=" --mempercore=64"
      CMD+=" --disable-ui"
      CMD+=" --maxjobs=200"

      run_cmd $CMD
    else
      echo "ERROR - Did not recognize cellranger command"
      # TODO
      # 10X_Genomics-Expression+VDJ
      # 10X_Genomics-FeatureBarcoding
      # 10X_Genomics_NextGEM-FB
      # 10X_Genomics_NextGEM_FeatureBarcoding
    fi
  fi
  cd -
fi

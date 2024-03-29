#!/bin/bash
# Given an input sample sheet, submit the demultiplexing job. Each demux tool is or internally uses bcl2fastq.
#   NOTE - The output structure of bcl2fastq demultiplexing is different from DRAGEN. Therefore, the downstream
#          alignment tasks must be sent to the bwa-mem/picard alignment workflow (@bwa_picard_align_wkflw)
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
#     DEMUX_LOG_FILE=demux.txt demultiplex.sh

# We run mkfastq only if the "index" column, which always comes before the Project_* column, has an SI-* index name
MKFASTQ_REGEX="SI-[A-Z,0-9]{2}-[A-Z,0-9]{2},Project_"

#########################################
# Returns what the mask should be
# Params
#   RUN_INFO_NUMBER  Index number pulled from RunInfo.xml (Required)
#   MASK             Mask of index (Format i/n#)          (Optional)
#########################################
assign_index () {
  RUN_INFO_NUMBER=$1    # will always be defined
  MASK=$2               # won't always be defined

  INDEX_MASK=i${RUN_INFO_NUMBER}                  # Default - unmasked index unless mask is defined
  if [[ ! -z ${MASK} ]]; then
    mask=$(echo ${MASK} | grep -o "[n|i]")        # i6 -> i
    if [[ "${mask}" = "n" ]]; then
      INDEX_MASK="n${RUN_INFO_NUMBER}"            # Mask entire index
    elif [[ "${mask}" = "i" ]]; then
      num=$(echo ${MASK} | grep -oe [0-9])        # i6 -> 6
      if [[ -z ${num} ]]; then
        pass                                      # No nucleotide mask defined - return default
      else
        remaining="$((${RUN_INFO_NUMBER} - num))"
        if [[ ${remaining} -gt 0 ]]; then
          INDEX_MASK="i${num}n${remaining}"       # Need to add remaining amount after nucleotide mask
        else
          pass                                    # Nucleotide mask matches RunInfo.xml - return default
        fi
      fi
    fi
  fi

  echo $INDEX_MASK
}

#########################################
# Reads the RunInfo.xml of the RUN_TO_DEMUX_DIR to retrieve mask and assigns to MASK_OPT
# Params
#   i7_MASK - Mask of i7 index (Format i/n#)        i/n# <- "n" mask entire index, "i" don't mask & use # nucleotides
#   i5_MASK - Mask of i5 index (Format i/n#)            Valid: i, i6, n     Invalid: y1
#                                                       e.g. "i6": Don't mask, but use only 6 nucleotides for index
#                                                       e.g. "n": Mask entire index
# Globals:
#   RUN_TO_DEMUX_DIR - Absolute path of run to demux
#########################################
assign_MASK_OPT () {
  # Pass in index masks
  i7_MASK=$(echo $1 | grep -oe "^[n|i][0-9]*$")    # Verify index masks are of the format "i/n#"
  i5_MASK=$(echo $2 | grep -oe "^[n|i][0-9]*$")    # Optional, may not be a dual-indexed read

  #Deletes shortest match of $substring '/*Complet*' from back of $x
  RUNPATH=$(echo ${RUN_TO_DEMUX_DIR%/*Complet*})  # ../PATH/TO/sequencers/johnsawyers/201113_JOHNSAWYERS_0252_000000000-G6H72
  OLDIFS=$IFS
  IFS='/'
  array=($RUNPATH)					                      # ( PATH TO sequencers johnsawyers 201113_JOHNSAWYERS_0252_000000000-G6H72 )
  MACHINE="${array[-2]}"				                  # johnsawyers
  RUN_TO_DEMUX="${array[-1]}" 				            # 201113_JOHNSAWYERS_0252_000000000-G6H72
  IFS=${OLDIFS}

  RUN_INFO_PATH=${RUNPATH}/RunInfo.xml
  R1=$( cat $RUN_INFO_PATH | grep "Number=\"1\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')
  R2=$( cat $RUN_INFO_PATH | grep "Number=\"2\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')
  R3=$( cat $RUN_INFO_PATH | grep "Number=\"3\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')
  R4=$( cat $RUN_INFO_PATH | grep "Number=\"4\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')

  I7=$(assign_index ${R2} ${i7_MASK})

  # Calculate bleed - Number of actual bases is one less than the number of cycles Reads section of RunInfo.xml
  R1_bleed="$((R1 - 1))"

  MASK="y${R1_bleed}n,${I7}"
  if [[ ! -z "${R4}" && ${R4} -gt 0 ]]; then
    # DUAL-END: Wll have an R4 in the RunInfo.xml. Add the second index (i5) & the second read (R4)
    R4_bleed="$((R4 - 1))"
    I5=$(assign_index ${R3} ${i5_MASK})
    MASK="${MASK},${I5},y${R4_bleed}n"
  else
    # SINGLE-END: Wll only have one index and the R3 value is the actual read value
    R3_bleed="$((R3 - 1))"
    MASK="${MASK},y${R3_bleed}n"
  fi

  echo "1=$1 2=$2 i7_MASK=${i7_MASK} i5_MASK=${i5_MASK} MASK=${MASK} (R1=${R1} R2=${R2} R3=${R3} R4=${R4})"
  MASK_OPT="--use-bases-mask ${MASK}"
}

BCL_LOG="bcl2fastq.log"

SAMPLESHEET=$(echo $SAMPLESHEET | tr -d " \t\n\r")	# Sometimes "\n" or "\t" characters can be appended 

# DEFAULT JOB COMMANDS
BSUB_CMD="echo 'No work assigned'"
JOB_NAME="NO_JOB"
JOB_CMD="echo 'No command specified'"
echo "Procesisng SampleSheet ${SAMPLESHEET} (DEMUX_ALL=${DEMUX_ALL})"

# SampleSheet_201204_PITT_0527_BHK752BBXY_i7.csv   ->   "PITT_0527_BHK752BBXY_i7"
basename ${SAMPLESHEET}
# TODO - fix "perl-regexp" for portability
RUN_BASENAME=$(basename ${SAMPLESHEET} | grep -oP "(?<=[0-9]_)[A-Za-z_0-9-]+") # Capture after "[ANY NUM]_" (- ".csv")
echo "RUN_BASENAME: ${RUN_BASENAME}"
DEMUXED_DIR="${FASTQ_DIR}/${RUN_BASENAME}"

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
  JOB_CMD="echo NO_JOB_SPECIFIED"

  # bin/create_multiple_sample_sheets.py will create a separate samplesheet for each recipe
  if grep -E "${MKFASTQ_REGEX}" $SAMPLESHEET; then
    export LD_LIBRARY_PATH=/opt/common/CentOS_6/gcc/gcc-4.9.2/lib64:$LD_LIBRARY_PATH
    export PATH=$(dirname ${BCL2FASTQ}):$PATH

    if grep -q "${REGEX_10X_Genomics_ATAC}" ${SAMPLESHEET}; then
      echo "DEMUX CMD (${RUN_BASENAME}): cellranger-atac mkfastq"
      JOB_CMD="${CELL_RANGER_ATAC} mkfastq --input-dir ${RUN_TO_DEMUX_DIR} --sample-sheet ${SAMPLESHEET} --output-dir ${DEMUXED_DIR}"
      JOB_CMD+=" --mempercore=32 --maxjobs=200 --barcode-mismatches 1 >> ${BCL_LOG}"
    elif grep -q "${REGEX_10X_Genomics_ATAC_MULTIOME}" ${SAMPLESHEET}; then
      echo "DEMUX CMD (${RUN_BASENAME}): cellranger-arc mkfastq"
      JOB_CMD="${CELL_RANGER_ARC} mkfastq --run=${RUN_TO_DEMUX_DIR} --samplesheet=${SAMPLESHEET} --output-dir=${DEMUXED_DIR}"
      JOB_CMD+=" --jobmode=${EXECUTOR} --disable-ui --barcode-mismatches=1 >> ${BCL_LOG}"
    else
      echo "DEMUX CMD (${RUN_BASENAME}): cellranger mkfastq"
      JOB_CMD="${CELL_RANGER} mkfastq --input-dir $RUN_TO_DEMUX_DIR/ --sample-sheet ${SAMPLESHEET} --output-dir ${DEMUXED_DIR}"
      echo "EXECUTOR=${EXECUTOR} localmem=${LOCAL_MEM}"
      if [[ ${EXECUTOR} = "local" ]]; then
        JOB_CMD+=" --localmem=${LOCAL_MEM}"
      fi
      JOB_CMD+=" --disable-ui  --barcode-mismatches 1 --jobmode=${EXECUTOR} >> ${BCL_LOG}"
    fi
  else
    export LD_LIBRARY_PATH=/opt/common/CentOS_6/gcc/gcc-4.9.2/lib64:$LD_LIBRARY_PATH
    echo "DEMUX CMD (${RUN_BASENAME}): bcl2fastq"

    # Add options depending on whether bin/create_multiple_sample_sheets.py created special sample sheets
    MASK_OPT=""         # Option for use-bases-mask, default to no mask (will take from RunInfo.xml)
    LANE_SPLIT_OPT=""   # Option for lane-splitting, default to lane-splitting
    has_i7=$(echo ${SAMPLESHEET} | grep _i7.csv)
    has_6nt=$(echo ${SAMPLESHEET} | grep _6nt.csv)
    no_lane_split=$(echo ${SAMPLESHEET} | grep -e _PPG.csv -e _DLP.csv)
    if [[ ! -z $has_i7 ]]; then
      echo "Detected an _i7.csv SampleSheet. Will keep i7 index of RunInfo.xml, but add mask to remove i5 index"
      I7_MASK="i"     # "i" = Take the index defined in the RunInfo.xml
      I5_MASK="n"     # "n" = Mask out the i5 index
      assign_MASK_OPT ${I7_MASK} ${I5_MASK}
    elif [[ ! -z $has_6nt ]]; then
      echo "Detected a _6nt.csv SampleSheet. Will add mask of six-nucleotide i7 index (keeps i5 if present)"
      I7_MASK="i6"    # "i6" = Take ONLY THE FIRST 6 NUCLEOTIDES of the index defined in RunInfo.xml
      I5_MASK="n"     # "n" = Mask out the i5 index
      assign_MASK_OPT ${I7_MASK} ${I5_MASK}
    elif [[ ! -z $no_lane_split ]]; then
      echo "Detected a _PPG.csv or _DLP.csv SampleSheet. Using --no-lane-splitting option"
      LANE_SPLIT_OPT="--no-lane-splitting"
    fi

    # detect_barcode_collision.py should be in bin dir of root of project
    BARCODE_MISMATCH=1
    CMD="detect_barcode_collision.py -s ${SAMPLESHEET} -m ${BARCODE_MISMATCH}"
    echo $CMD
    eval $CMD
    if [ $? -ne 0 ]; then
      BARCODE_MISMATCH=0
    fi

    echo "Running bcl2fastq w/ mismatches=${BARCODE_MISMATCH}"
    JOB_CMD="${BCL2FASTQ} ${MASK_OPT} ${LANE_SPLIT_OPT} --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0 --ignore-missing-bcl --runfolder-dir  $RUN_TO_DEMUX_DIR --sample-sheet ${SAMPLESHEET} --output-dir ${DEMUXED_DIR} --ignore-missing-filter --ignore-missing-positions --ignore-missing-control --barcode-mismatches ${BARCODE_MISMATCH}"
    # Important to balance threads - https://www.biostars.org/p/9489458/#9489499
    JOB_CMD+=" --loading-threads 12 --processing-threads 24 --writing-threads 24"
    JOB_CMD+=" >> ${BCL_LOG} 2>&1"
  fi
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

  # Add DLP metadata.yaml script
  is_dlp=$(echo ${SAMPLESHEET} | grep _DLP.csv)
  if [[ ! -z $is_dlp && ! -z ${SHARED_SINGLE_CELL_DIR} && -d ${SHARED_SINGLE_CELL_DIR} ]]; then
    echo "Detected an _DLP.csv SampleSheet. Creating metadata.yaml"
    cd ${SHARED_SINGLE_CELL_DIR}
    project_dirs=$(find ${DEMUXED_DIR} -maxdepth 1 -type d -name "Project_*")
    for project_path in $project_dirs; do
      prj=$(basename ${project_path})
      CMD="make create-metadata-yaml ss=${SAMPLESHEET} prj=${prj} project_path=${project_path}"
      echo ${CMD}
      eval ${CMD}
    done
    cd - # Come back to work directory
  fi
fi

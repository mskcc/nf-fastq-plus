#!/bin/bash
# Given an input sample sheet, submit the demultiplexing job
# Nextflow Inputs:
#   SAMPLESHEET:      Absolute path to the sample sheet that will be used for demultiplexing
#   RUN_TO_DEMUX_DIR: Absolute path to bcl files
#
#   FASTQ_DIR:        Directory w/ FASTQ files
#   DEMUX_LOG_FILE:   Log file where demux output is written to
#   DATA_TEAM_EMAIL: emails of data team members who should be notified
# Nextflow Outputs:
#   DEMUXED_DIR, env: path to where the run has been demuxed to
#   SAMPLE_SHEET,env: path to samplesheet used to demultiplex
# Run:
#   RUN_TO_DEMUX_DIR=/igo/sequencers/michelle/200814_MICHELLE_0249_AHMNCJDRXX ./demultiplex.sh

#########################################
# Reads the RunInfo.xml of the RUN_TO_DEMUX_DIR to retrieve mask and assigns to MASK_OPT
# Params
#   R2_MASK - Number of nucleotides of the i7 index to include, all others are masked
# Globals:
#   RUN_TO_DEMUX_DIR - Absolute path of run to demux
#########################################
assign_MASK_OPT () {
  R2_MASK=$1

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

  # Number of actual bases is one less than the number of cycles Reads section of RunInfo.xml
  R1_bleed="$((R1 - 1))"

  # Mask all but the first ${R2_MASK} nucleotides of the i7 index if specified
  if [[ ! -z ${R2_MASK} ]]; then
    nR2="$((R2 - ${R2_MASK}))"
    R2="${R2_MASK}n${nR2}"
  fi
  R4_bleed="$((R4 - 1))"

  MASK="y${R1_bleed}n,i${R2},n${R3},y${R4_bleed}n"
 
  echo "R1=${R1} R2=${R2} R3=${R3} R4=${R4} MASK: ${MASK}"
  MASK_OPT="--use-bases-mask ${MASK}"
}
SAMPLESHEET=$(echo $SAMPLESHEET | tr -d " \t\n\r")	# Sometimes "\n" or "\t" characters can be appended 

# DEFAULT JOB COMMANDS
BSUB_CMD="echo 'No work assigned'"
JOB_NAME="NO_JOB"
JOB_CMD="echo 'No command specified'"
JOB_OUT="${OUTPUT}/not_assigned.txt"
echo "Procesisng SampleSheet ${SAMPLESHEET} (DEMUX_ALL=${DEMUX_ALL})"
samplesheet_file=$(basename ${SAMPLESHEET})

# SampleSheet_201204_PITT_0527_BHK752BBXY_i7.csv   ->   "PITT_0527_BHK752BBXY_i7"
basename ${SAMPLESHEET}
RUN_BASENAME=$(basename ${SAMPLESHEET} | grep -oP "(?<=[0-9]_)[A-Za-z_0-9-]+") # Capture after "[ANY NUM]_" (- ".csv")
echo "RUN_BASENAME: ${RUN_BASENAME}"
DEMUXED_DIR="${FASTQ_DIR}/${RUN_BASENAME}"

mkdir -p $DEMUXED_DIR
chmod -R 775 $DEMUXED_DIR
cp $SAMPLESHEET $DEMUXED_DIR
echo "Writing FASTQ files to $DEMUXED_DIR"
echo "SAMPLESHEET: ${SAMPLESHEET}"

JOB_CMD="echo NO_JOB_SPECIFIED"

BCL_LOG="bcl2fastq.log"

if grep -q "10X_Genomics" $SAMPLESHEET; then
  export LD_LIBRARY_PATH=/opt/common/CentOS_6/gcc/gcc-4.9.2/lib64:$LD_LIBRARY_PATH
  export PATH=$(dirname ${BCL2FASTQ}):$PATH
  if grep -q "10X_Genomics_ATAC" $SAMPLESHEET; then
    echo "DEMUX CMD (${RUN_BASENAME}): cellranger-atac mkfastq"
    JOB_CMD="${CELL_RANGER_ATAC} mkfastq --input-dir ${RUN_TO_DEMUX_DIR} --sample-sheet ${SAMPLESHEET} --output-dir ${DEMUXED_DIR} --nopreflight --jobmode=lsf --mempercore=32 --disable-ui --maxjobs=200 --barcode-mismatches 1 >> ${BCL_LOG}"
  else
    echo "DEMUX CMD (${RUN_BASENAME}): cellranger mkfastq"
    JOB_CMD="/igo/work/bin/cellranger-4.0.0/cellranger mkfastq --input-dir $RUN_TO_DEMUX_DIR/ --sample-sheet ${SAMPLESHEET} --output-dir ${DEMUXED_DIR} --nopreflight --jobmode=local --localmem=216 --localcores=36  --barcode-mismatches 1 >> ${BCL_LOG}"
  fi
else
  export LD_LIBRARY_PATH=/opt/common/CentOS_6/gcc/gcc-4.9.2/lib64:$LD_LIBRARY_PATH
  echo "DEMUX CMD (${RUN_BASENAME}): bcl2fastq"

  # Add options depending on whether bin/create_multiple_sample_sheets.py created special sample sheets
  MASK_OPT=""         # Option for use-bases-mask, default to no mask (will take from RunInfo.xml)
  LANE_SPLIT_OPT=""   # Option for lane-splitting, default to lane-splitting
  has_i7=$(echo ${SAMPLESHEET} | grep _i7.csv)
  has_6nt=$(echo ${SAMPLESHEET} | grep _6nt.csv)
  no_lane_split=$(echo ${SAMPLESHEET} | grep -E '_PPG.csv|_DLP.csv')
  if [[ ! -z $has_i7 ]]; then
    echo "Detected an _i7.csv SampleSheet. Will add mask to remove i5 index"
    assign_MASK_OPT
  elif [[ ! -z $has_6nt ]]; then
    echo "Detected a _6nt.csv SampleSheet. Will add mask of six-nucleotide i7 index and to remove i5 index"
    assign_MASK_OPT 6
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
  JOB_CMD="${BCL2FASTQ} ${MASK_OPT} ${LANE_SPLIT_OPT} --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0 --ignore-missing-bcl  --runfolder-dir  $RUN_TO_DEMUX_DIR --sample-sheet ${SAMPLESHEET} --output-dir ${DEMUXED_DIR} --ignore-missing-filter --ignore-missing-positions --ignore-missing-control --barcode-mismatches ${BARCODE_MISMATCH} --loading-threads 12 --processing-threads 24 >> ${BCL_LOG} 2>&1"
fi

echo ${JOB_CMD} >> ${CMD_FILE}

DEMUXED_FASTQS=$(find ${DEMUXED_DIR} -type f -name "*.fastq.gz")

# Disable error - we want the output of ${BCL_LOG} logged somewhere. We want to alert on failed demux below
set +e
if [[ "${DEMUX_ALL}" == "true" && ! -z $DEMUXED_FASTQS  ]]; then
  LOG="Skipping demux (DEMUX_ALL=${DEMUX_ALL}) of already demuxed directory: ${DEMUXED_DIR}"
  echo $LOG >> ${BCL_LOG}
else
  echo "Running demux"
  eval ${JOB_CMD}
fi
UNDETERMINED_SIZE=$(du -sh  ${DEMUXED_DIR}/Undet*);
PROJECT_SIZE=$(du -sh ${DEMUXED_DIR}/Proj*/*);
set -e

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
  # Important Notification - Some sequencers (e.g. SCOTT) delete their old data w/ each new run, i.e. $30,000 run could be deleted just b/c the copy didn't work correctly
  echo "MAIL: Failed Demux Run ${RUN_TO_DEMUX} ${DATA_TEAM_EMAIL}"
  echo $FULL | mail -s "[FAILED DEMUX] ${RUN_TO_DEMUX}" ${DATA_TEAM_EMAIL}
  exit 1
fi

#!/bin/bash
# Submits demultiplexing jobs
# Nextflow Inputs:
#   RUN_TO_DEMUX_DIR:     Absolute path to directory of the Run to demux (Defined as input in nextflow process)
#
#   LAB_SAMPLE_SHEET_DIR: Absolute path to directory of the mounted filesystem the lab writes the original sample sheets
# Nextflow Outputs:
#   DEMUXED_RUN, env: Name of run to demux, given by the name of @RUN_TO_DEMUX_DIR
# Run: 
#   RUN_TO_DEMUX_DIR=/igo/sequencers/michelle/200814_MICHELLE_0249_AHMNCJDRXX ./demultiplex.sh

#Deletes shortest match of $substring '/*Complet*' from back of $x
RUNPATH=$(echo ${RUN_TO_DEMUX_DIR%/*Complet*})
IFS='/'
array=($RUNPATH)
MACHINE="${array[3]}"
RUN_TO_DEMUX="${array[4]}" # EXPORT TO NEXT NEXTFLOW PROCESS
IFS=','

# TODO - uncomment
# echo $RUN_TO_DEMUX | mail -s "IGO Cluster New Run Sent for Demuxing" mcmanamd@mskcc.org naborsd@mskcc.org streidd@mskcc.org

RUN_INFO_PATH=${RUNPATH}/RunInfo.xml

HI_SEQ="jax momo pitt kim"
NOVA_SEQ="diana michelle"
MI_SEQ="vic johnsawyers toms ayaan"
NEXT_SEQ="scott"

IsR2Index=$(cat $FULLPATH | grep "Read Number=\"2\"" | awk '{IsIt=match($0,"=\"N\""); if (IsIt>0) print "NOTINDEX"; else print "ISINDEX" }')
R1=$( cat $FULLPATH | grep "Number=\"1\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')
R2=$( cat $FULLPATH | grep "Number=\"2\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')
R3=$( cat $FULLPATH | grep "Number=\"3\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')
R4=$( cat $FULLPATH | grep "Number=\"4\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')

ADD_N=""      # NovaSeqs & MiSeqs do NOT add an "n" in their mask
if [[ "${HI_SEQ} ${NEXT_SEQ}" == *"${MACHINE}"* ]]; then
  ADD_N="n"   # NextSeqs & HiSeqs add an "n" in their mask
fi

#DEALING WITH "NO INDEX" PE CASES
if [ "$R3" != '' ] ; then
  MASK="Y${R1}${ADD_N},I${R2},Y${R3}${ADD_N}"
else
  if [ "$IsR2IndexMiSeq" == "ISINDEX" ]; then
    MASK="Y${R1}${ADD_N},I${R2}${ADD_N}"
  else
    MASK="Y${R1}${ADD_N},Y${R2}${ADD_N}"
  fi
fi

if [ "$R2" == '' ] ; then
  MASK="Y${R1}${ADD_N}"
fi

if [ "$R4" != '' ]; then
  MASK="Y${R1}${ADD_N},I${R2}${ADD_N},I${R3}${ADD_N},Y${R4}${ADD_N}"
fi

echo "RUN_TO_DEMUX_DIR=${RUN_TO_DEMUX_DIR} RUNPATH=${RUNPATH} MACHINE=${MACHINE} RUN_TO_DEMUX=${RUN_TO_DEMUX} MASK=${MASK}"

SAMPLESHEET="!{LAB_SAMPLE_SHEET_DIR}/SampleShee*"$RUN"*.csv"
echo "Set samplesheet path to ${SAMPLESHEET}"

OUTPUT="/igo/work/FASTQ/${RUN_TO_DEMUX}"
echo "Set OUTPUT folder to ${OUTPUT}"

mkdir -p $OUTPUT

# PLACE SAMPLE SHEET IN A FOLDER WHERE IT CAN BE REACHED WHEN JOB IS RUNNING ON NYX
echo "Copying sampleSheet from /pskis34 share: $SAMPLESHEET ,to:/home/igo/SampleSheetCopies/"
cp $SAMPLESHEET /home/igo/SampleSheetCopies
NYXSAMPLESHEET="/home/igo/SampleSheetCopies/SampleShee*"$RUN_TO_DEMUX"*.csv"

python create_multiple_sample_sheets.py \
  --sample-sheet ${NYXSAMPLESHEET} \
  --source-dir !{SAMPLE_SHEET_DIR} \
  --processed-dir !{PROCESSED_SAMPLE_SHEET_DIR} \
  --output-file !{PROCESSED_SAMPLE_SHEETS_FILE}

# TODO - READ THE CONTENTS OF !{PROCESSED_SAMPLE_SHEETS_FILE} and for each submit a job
# TODO - when the demux is complete, output the sample sheet of each successful as this will inform the stats parameters
# DEFAULT JOB COMMANDS
BSUB_CMD="echo 'No work assigned'"
JOB_NAME="NO_JOB"
JOB_CMD="echo 'No command specified'"
JOB_OUT="${OUTPUT}/not_assigned.txt"

for SAMPLESHEET in $PROCESSED_SAMPLESHEETS; do
  if /bin/grep -q "10X_Genomics" $SAMPLESHEET; then
    export LD_LIBRARY_PATH=/opt/common/CentOS_6/gcc/gcc-4.9.2/lib64:$LD_LIBRARY_PATH
    export PATH=/opt/common/CentOS_6/bcl2fastq/bcl2fastq2-v2.20.0.422/bin:$PATH
    if /bin/grep -q "10X_Genomics_ATAC" $SAMPLESHEET; then
      echo "Running cellranger-atac mkfastq"
      JOB_NAME="mkfastq__${RUN_TO_DEMUX}"
      JOB_OUT="mkfastq__${RUN_TO_DEMUX}.log"
      JOB_CMD="/home/nabors/cellranger-atac-1.1.0/cellranger-atac mkfastq --input-dir ${RUNPATH} --sample-sheet ${NYXSAMPLESHEET} --output-dir ${OUTPUT} --nopreflight --jobmode=lsf --mempercore=32 --disable-ui --maxjobs=200 --barcode-mismatches 1"
    else
      echo "Running cellranger-atac mkfastq"
      JOB_NAME="atac_mkfastq__${RUN_TO_DEMUX}"
      JOB_OUT="atac_mkfastq__${RUN_TO_DEMUX}.log"
      JOB_CMD="/igo/work/bin/cellranger-4.0.0/cellranger mkfastq --input-dir $RUNPATH/ --sample-sheet $NYXSAMPLESHEET --output-dir $OUTPUT --nopreflight --jobmode=local --localmem=216 --localcores=36  --barcode-mismatches 1"
    fi
  else
    echo "Running bcl2fastq with 1 mismatch RUN=$RUN_TO_DEMUX RUNPATH=$RUNPATH OUTPUT=$OUTPUT SAMPLESHEET=$NYXSAMPLESHEET"
    export LD_LIBRARY_PATH=/opt/common/CentOS_6/gcc/gcc-4.9.2/lib64:$LD_LIBRARY_PATH
    JOB_NAME="bcl2fastq__${RUN_TO_DEMUX}"
    JOB_OUT="bcl2fastq__${RUN_TO_DEMUX}.log"
    JOB_CMD="/opt/common/CentOS_6/bcl2fastq/bcl2fastq2-v2.20.0.422/bin/bcl2fastq --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0 --ignore-missing-bcl  --runfolder-dir  $RUNPATH/ --sample-sheet $NYXSAMPLESHEET --output-dir $OUTPUT --ignore-missing-filter --ignore-missing-positions --ignore-missing-control --barcode-mismatches 1 --no-lane-splitting  --loading-threads 12 --processing-threads 24 2>&1 >> /home/igo/log/bcl2fastq.log"
  fi

  # Fire off all demultiplexing jobs and then save the JOB ID to wait on
  BSUB_CMD="bsub -J ${JOB_NAME} -o ${JOB_OUT} -n 36 -M 6 ${JOB_CMD}"
  echo "Submitting: ${BSUB_CMD}"
  SUBMIT=$(${BSUB_CMD})  # Submits and saves output
  JOB_ID=$(echo $SUBMIT | egrep -o '[0-9]{5,}')                           # Parses out job id from output
done

echo "Demultiplex complete for Run: ${RUN_TO_DEMUX} (JOB ID: ${JOB_ID})"
DEMUXED_RUN=$RUN_TO_DEMUX    # Re-assigning this parameter here makes it available for the following nextflow process

# change permissions on the Fastq output folder
chmod -R 775 $OUTPUT

UNDETERMINED_SIZE=$(du -sh  ${OUTPUT}/Undet*);
PROJECT_SIZE=$(du -sh Proj*/*);
FILE_OUTPUT_SIZE=$(printf "%s\n\n%s\n" "${UNDETERMINED_SIZE}" "$Proj_Size")
REPORT="To view reports visit: ${OUTPUT}/Reports/html/index.html"
FULL=$(printf "%s\n\n%s\n" "$FILE_OUTPUT_SIZE" "$REPORT")

# TODO - Uncomment
# echo $FULL | mail -s "IGO Cluster Done Demuxing ${DEMUXED_RUN} mcmanamd@mskcc.org naborsd@mskcc.org streidd@mskcc.org"




if [ -n "$FILE_OUTPUT_SIZE" ]; then
  # TODO - Uncomment
  # mail -s "Starting stats for run ${DEMUXED_RUN} naborsd@mskcc.org mcmanamd@mskcc.org streidd@mskcc.org"
else
  # TODO - Uncomment
  # mail -s "Failed Demux Run ${RUN_TO_DEMUX}" naborsd@mskcc.org streidd@mskcc.org
fi


# TODO - Add detect stats completion


# TODO - Demultiplexing
# SAMPLE_SHEET=$(find /path/to/SampleSheet/*${RUN_TO_DEMUX_DIR})
# python split_sample_sheet_code.py $SAMPLE_SHEET

# TODO
#   - If lane is a single-ended library (all i5s are the same), then MAYBE separate out
#   - If an entire run is a single-ended library, then run w/ i5 only
#   - Don't separate out runs b/c it messes up the undetermined

# TODO - Update: Add a notification for when a DEMUX fails. VERY IMPORTANT - Some sequencers (e.g. SCOTT) delete their old data w/ each new run, i.e. $30,000 run could be deleted just b/c the copy didn't work correctly












#!/bin/bash
# Given an input sample sheet, submit the demultiplexing job
# Nextflow Inputs:
#   SAMPLESHEET:      Absolute path to the sample sheet that will be used for demultiplexing
#   RUN_TO_DEMUX_DIR: Absolute path to bcl files
#
#   LAB_SAMPLE_SHEET_DIR: Absolute path to directory of the mounted filesystem the lab writes the original sample sheets
# Nextflow Outputs:
#   DEMUXED_RUN, env: Name of run to demux, given by the name of @RUN_TO_DEMUX_DIR
# Run: 
#   RUN_TO_DEMUX_DIR=/igo/sequencers/michelle/200814_MICHELLE_0249_AHMNCJDRXX ./demultiplex.sh

SAMPLESHEET=$(echo $SAMPLESHEET | tr -d " \t\n\r")	# Sometimes "\n" or "\t" characters can be appended 

# DEFAULT JOB COMMANDS
BSUB_CMD="echo 'No work assigned'"
JOB_NAME="NO_JOB"
JOB_CMD="echo 'No command specified'"
JOB_OUT="${OUTPUT}/not_assigned.txt"
echo "Procesisng SampleSheet: ${SAMPLESHEET}"
samplesheet_file=$(basename ${SAMPLESHEET})

# SampleSheet_201204_PITT_0527_BHK752BBXY_i7.csv   ->   "PITT_0527_BHK752BBXY_i7"
basename ${SAMPLESHEET}
RUN_BASENAME=$(basename ${SAMPLESHEET} | grep -oP "(?<=\d)[A-Za-z_0-9-]+")
echo "RUN_BASENAME: ${RUN_BASENAME}"
DEMUXED_DIR="!{FASTQ_DIR}/${RUN_BASENAME}"

mkdir -p $DEMUXED_DIR
chmod -R 775 $DEMUXED_DIR
cp $SAMPLESHEET $DEMUXED_DIR
echo "Writing FASTQ files to $DEMUXED_DIR"
echo "SAMPLESHEET: ${SAMPLESHEET}"

JOB_CMD="echo NO_JOB_SPECIFIED"
if /bin/grep -q "10X_Genomics" $SAMPLESHEET; then
  export LD_LIBRARY_PATH=/opt/common/CentOS_6/gcc/gcc-4.9.2/lib64:$LD_LIBRARY_PATH
  export PATH=/opt/common/CentOS_6/bcl2fastq/bcl2fastq2-v2.20.0.422/bin:$PATH
  if /bin/grep -q "10X_Genomics_ATAC" $SAMPLESHEET; then
    echo "DEMUX CMD (${RUN_BASENAME}): cellranger-atac mkfastq"
    JOB_CMD="/home/nabors/cellranger-atac-1.1.0/cellranger-atac mkfastq --input-dir ${RUN_TO_DEMUX_DIR} --sample-sheet ${SAMPLESHEET} --output-dir ${DEMUXED_DIR} --nopreflight --jobmode=lsf --mempercore=32 --disable-ui --maxjobs=200 --barcode-mismatches 1"
  else
    echo "DEMUX CMD (${RUN_BASENAME}): cellranger mkfastq"
    JOB_CMD="/igo/work/bin/cellranger-4.0.0/cellranger mkfastq --input-dir $RUN_TO_DEMUX_DIR/ --sample-sheet ${SAMPLESHEET} --output-dir ${DEMUXED_DIR} --nopreflight --jobmode=local --localmem=216 --localcores=36  --barcode-mismatches 1"
  fi
else
  export LD_LIBRARY_PATH=/opt/common/CentOS_6/gcc/gcc-4.9.2/lib64:$LD_LIBRARY_PATH
  echo "DEMUX CMD (${RUN_BASENAME}): bcl2fastq"
  JOB_CMD="/opt/common/CentOS_6/bcl2fastq/bcl2fastq2-v2.20.0.422/bin/bcl2fastq --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0 --ignore-missing-bcl  --runfolder-dir  $RUN_TO_DEMUX_DIR --sample-sheet ${SAMPLESHEET} --output-dir ${DEMUXED_DIR} --ignore-missing-filter --ignore-missing-positions --ignore-missing-control --barcode-mismatches 1 --no-lane-splitting  --loading-threads 12 --processing-threads 24 >> !{DEMUX_LOG_FILE} 2>&1"
fi

echo ${JOB_CMD}
eval ${JOB_CMD}

# TODO - Add a filtering process to determine which demux files are valid since it's possible for a job to have failed
# NEXTFLOW ENVIRONMENT VARIABLES - These environment variables are passed to the next nextflow process
echo "Demultiplexed DEMUXED_DIR: ${DEMUXED_DIR}, SAMPLESHEET: ${SAMPLESHEET}"


UNDETERMINED_SIZE=$(du -sh  ${DEMUXED_DIR}/Undet*);
PROJECT_SIZE=$(du -sh ${DEMUXED_DIR}/Proj*/*);
FILE_OUTPUT_SIZE=$(printf "%s\n\n%s\n" "${UNDETERMINED_SIZE}" "$Proj_Size")
REPORT="To view reports visit: ${DEMUXED_DIR}/Reports/html/index.html"
FULL=$(printf "%s\n\n%s\n" "$FILE_OUTPUT_SIZE" "$REPORT")

echo "DEMUX_UPDATE: ${FULL}"

# TODO - Uncomment
# echo $FULL | mail -s "IGO Cluster Done Demuxing ${DEMUXED_RUN} mcmanamd@mskcc.org naborsd@mskcc.org streidd@mskcc.org"

if [ -n "$FILE_OUTPUT_SIZE" ]; then
  # TODO - Uncomment
  # mail -s "Starting stats for run ${DEMUXED_RUN} naborsd@mskcc.org mcmanamd@mskcc.org streidd@mskcc.org"
  echo "MAIL: Starting stats for run ${DEMUXED_RUN} naborsd@mskcc.org mcmanamd@mskcc.org streidd@mskcc.org"
else
  # TODO - Uncomment
  # mail -s "Failed Demux Run ${RUN_TO_DEMUX}" naborsd@mskcc.org streidd@mskcc.org
  echo "MAIL: Failed Demux Run ${RUN_TO_DEMUX} naborsd@mskcc.org streidd@mskcc.org"
fi

# TODO - Update: Add a notification for when a DEMUX fails. VERY IMPORTANT - Some sequencers (e.g. SCOTT) delete their old data w/ each new run, i.e. $30,000 run could be deleted just b/c the copy didn't work correctly

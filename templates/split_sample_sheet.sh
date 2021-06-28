#!/bin/bash
# Given the sequencer directory output (of bcl files), split the sample sheet based on the unique recipe-request values
# Nextflow Inputs:
#   RUN_TO_DEMUX_DIR:     Absolute path to directory of the Run to demux (Defined as input in nextflow process)
#
#   (config)
#   COPIED_SAMPLE_SHEET_DIR
#   PROCESSED_SAMPLE_SHEET_DIR: Absolute path to the directory to write all processed sample sheets
#   LAB_SAMPLE_SHEET_DIR: Absolute path to directory of the mounted filesystem the lab writes the original sample sheets (for IGO, this is mounted on only the head LSF node)
#   SPLIT_SAMPLE_SHEETS   File name that the absolute paths of the split sample sheets will be written
# Nextflow Outputs:
#   DEMUXED_RUN, env: Name of run to demux, given by the name of @RUN_TO_DEMUX_DIR
# Run: 
#   RUN_TO_DEMUX_DIR=/igo/sequencers/michelle/200814_MICHELLE_0249_AHMNCJDRXX ./demultiplex.sh

#Deletes shortest match of $substring '/*Complet*' from back of $x
RUNPATH=$(echo ${RUN_TO_DEMUX_DIR%/*Complet*})		# ../PATH/TO/sequencers/johnsawyers/201113_JOHNSAWYERS_0252_000000000-G6H72
IFS='/'
array=($RUNPATH)					# ( PATH TO sequencers johnsawyers 201113_JOHNSAWYERS_0252_000000000-G6H72 )
RUN_TO_DEMUX="${array[-1]}" 				# 201113_JOHNSAWYERS_0252_000000000-G6H72
IFS=','

echo "Searching w/ ${LAB_SAMPLE_SHEET_DIR}/SampleShee*${RUN_TO_DEMUX}*.csv"
SAMPLESHEET=$(find ${LAB_SAMPLE_SHEET_DIR} -type f -name "SampleShee*${RUN_TO_DEMUX}*.csv" | sort | tail -1) # Retrieve the last modified sample sheet
echo "Set samplesheet path to ${SAMPLESHEET}"

SAMPLE_SHEET_FILE_NAME=$(basename $SAMPLESHEET)

# PLACE SAMPLE SHEET IN A FOLDER WHERE IT CAN BE REACHED WHEN JOB IS RUNNING ON NYX
cp $SAMPLESHEET ${COPIED_SAMPLE_SHEET_DIR}
COPIED_SAMPLE_SHEET=$(find ${COPIED_SAMPLE_SHEET_DIR} -type f -name "${SAMPLE_SHEET_FILE_NAME}")
echo "SampleSheet Copy (${SAMPLE_SHEET_FILE_NAME}): $SAMPLESHEET -> ${COPIED_SAMPLE_SHEET}"

# Creates the split sample sheets and appends each split sample sheet into the SPLIT_SAMPLE_SHEETS file
# e.g.
#   python create_multiple_sample_sheets.py --sample-sheet SampleSheet_201204_PITT_0527_BHK752BBXY.csv \
#     --source-dir /home/igo/SampleSheetCopies/ \
#     --processed-dir /home/streidd/working/nf-fastq-plus/bin \
#     --output-file test.csv
#  OUTPUT (saved in ${SPLIT_SAMPLE_SHEETS}):
#     SampleSheet_201204_PITT_0527_BHK752BBXY.csv
#     SampleSheet_201204_PITT_0527_BHK752BBXY_i7.csv
# TODO
#   - If lane is a single-ended library (all i5s are the same), then MAYBE separate out
#   - If an entire run is a single-ended library, then run w/ i5 only
#   - Don't separate out runs b/c it messes up the undetermined
echo "SampleSheet: ${COPIED_SAMPLE_SHEET}, OutputDir: ${PROCESSED_SAMPLE_SHEET_DIR} OutputFile: ${SPLIT_SAMPLE_SHEETS}"

# In ./bin 
CMD="create_multiple_sample_sheets.py --sample-sheet ${COPIED_SAMPLE_SHEET} --processed-dir ${PROCESSED_SAMPLE_SHEET_DIR} --output-file ${SPLIT_SAMPLE_SHEETS}"
create_multiple_sample_sheets.py --sample-sheet ${COPIED_SAMPLE_SHEET} --processed-dir ${PROCESSED_SAMPLE_SHEET_DIR} --output-file ${SPLIT_SAMPLE_SHEETS}

NUM_SHEETS=$(cat ${SPLIT_SAMPLE_SHEETS} | wc -l)
echo "Wrote ${NUM_SHEETS} sample sheets from ${COPIED_SAMPLE_SHEET} to file ${SPLIT_SAMPLE_SHEETS}: $(cat ${SPLIT_SAMPLE_SHEETS})"

if (( $NUM_SHEETS == 0 )); then
  echo "No sample sheets, copying original to ${PROCESSED_SAMPLE_SHEET_DIR}"
  cp ${COPIED_SAMPLE_SHEET} ${PROCESSED_SAMPLE_SHEET_DIR}
  COPIED_FILENAME=$(basename ${COPIED_SAMPLE_SHEET})
  COPIED_FILE=$(find ${PROCESSED_SAMPLE_SHEET_DIR} -type f -name ${COPIED_FILENAME}) # ${PROCESSED_SAMPLE_SHEET_DIR}/$(basename ${COPIED_SAMPLE_SHEET})
  if [[ -z ${COPIED_FILE} ]]; then
    echo "Could not find ${COPIED_FILENAME} in ${PROCESSED_SAMPLE_SHEET_DIR}"
    exit 1
  fi
  echo "Writing to ${SPLIT_SAMPLE_SHEETS}: ${COPIED_FILE}"
  ls ${COPIED_FILE} >> ${SPLIT_SAMPLE_SHEETS}
fi

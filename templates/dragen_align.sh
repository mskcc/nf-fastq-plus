#!/bin/bash
# Submits an alignment job to DRAGEN based off of the demultiplexing output
# Nextflow Inputs:
#   RUN_PARAMS_FILE, env - The suffix of the files we care about
# Nextflow Outputs:
#   CMD_FILE, path - where to log all commands to
#   RUN_PARAMS_FILE, file - Output all individual param files
#   SAM_CH, Outputs SAM w/ Readgroups (*.sam)

# TODO - this is really only to make only DRAGEN FASTQs go here
echo "Received DGN_DEMUX=${DGN_DEMUX}"

DGN_REFERENCE="/staging/ref/GRCh37_dna" # TODO - DGN_REFERENCE=$(parse_param ${LANE_PARAM_FILE} DGN_REFERENCE)
RUN_TAG_PARAM=$(parse_param ${RUN_PARAMS_FILE} RUN_TAG)
DGN_BAM=$(parse_param ${RUN_PARAMS_FILE} DGN_BAM)
FASTQ_LIST_FILE=$(parse_param ${RUN_PARAMS_FILE} FASTQ_LIST_FILE)
SAMPLE_TAG=$(parse_param ${RUN_PARAMS_FILE} SAMPLE_TAG)

OUTPUT_PREFIX="$(basename ${DGN_BAM} | cut -d'.' -f1)"
OUTPUT_DIR="$(dirname ${DGN_BAM})"

CMD="/opt/edico/bin/dragen --ref-dir ${DGN_REFERENCE} --enable-duplicate-marking true"
CMD+=" --enable-map-align-output true --enable-variant-caller true --output-directory ${OUTPUT_DIR}"
CMD+=" --output-file-prefix ${OUTPUT_PREFIX} --fastq-list-sample-id ${SAMPLE_TAG} --fastq-list ${FASTQ_LIST_FILE}"

echo ${CMD} >> ${CMD_FILE}
eval ${CMD}

# TODO - is this needed, since this may be a symbolic link?
cat ${RUN_PARAMS_FILE} > ${RUN_PARAMS_FILE}

OUTPUT_BAM=$(find ${OUTPUT_DIR} -type f -name "${OUTPUT_PREFIX}*.bam")
ln -s ${OUTPUT_BAM} .

SYMLINK=$(find -L . -type l -name "${OUTPUT_PREFIX}*")

# TODO - Actually grab DRAGEN stats
touch DRAGEN_STATS.txt

echo "DRAGEN BAM Successfully Created: ${OUTPUT_BAM}. SYMLINK=${SYMLINK}"

#!/bin/bash
# Sets up and runs stats pipeline for human whole genome (HWG)

LOCATION=$(dirname "$0")

ORIGINAL_CONFIG=${LOCATION}/../../nextflow.config
if [[ -z ${ORIGINAL_CONFIG} || ! -f ${ORIGINAL_CONFIG} ]]; then
  echo "Did not find original config"
  exit 1
fi

# Writes a nextflow.config file that is the same as the sourced config except its executor is local
TEMP_FILE="nextflow_temp.config"

# Write the local executor
echo "executor {" > ${TEMP_FILE}
echo "  name = 'local'" >> ${TEMP_FILE}
echo "  perJobMemLimit = true" >> ${TEMP_FILE}
echo "  scratch = true" >> ${TEMP_FILE}
echo "  TMPDIR = '/scratch'" >> ${TEMP_FILE}
echo "}" >> ${TEMP_FILE}

FASTQ_DIR=${LOCATION}/../data/FASTQ/

# Take whatever is in the original config for the environment variables. Replace bwa & picard w/ docker binaries
cat ${ORIGINAL_CONFIG} | sed -n '/env {/,$p' \
  | sed -E "s#BWA=.*#BWA=\"/usr/bin/bwa\"#" \
  | sed -E "s#PICARD=.*#PICARD=\"java -jar /usr/local/bioinformatics/picard.jar\"#" \
  | sed -E "s#SAMTOOLS=.*#SAMTOOLS=\"/usr/bin/samtools\"#" \
  | sed -E "s#FASTQ_DIR=.*#FASTQ_DIR=\"${FASTQ_DIR}\"#" \
  >> ${TEMP_FILE}

BACKUP=nextflow_original.config

echo "Writing temporary nextflow.config file (Saving old to ${BACKUP})"
cp ${ORIGINAL_CONFIG} ${BACKUP}
mv ${TEMP_FILE} ${ORIGINAL_CONFIG}

${LOCATION}/samplesheet_stats_main_test.sh HWG

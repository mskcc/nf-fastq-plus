#!/bin/bash
# Writes a nextflow.config file that is the same as the sourced config except its executor is local
# SHOULD ONLY BE USED FOR TESTING

ORIGINAL_CONFIG=$1

if [[ -z ${ORIGINAL_CONFIG} || ! -f ${ORIGINAL_CONFIG} ]]; then
  echo "Did not find original config"
  exit 1
fi

TEMP_FILE="nextflow_temp.config"

# Write the local executor
echo "executor {" > ${TEMP_FILE}
echo "  name = 'local'" >> ${TEMP_FILE}
echo "  perJobMemLimit = true" >> ${TEMP_FILE}
echo "  scratch = true" >> ${TEMP_FILE}
echo "  TMPDIR = '/scratch'" >> ${TEMP_FILE}
echo "}" >> ${TEMP_FILE}

# Take whatever is in the original config for the environment variables
cat ${ORIGINAL_CONFIG} | sed -n '/env {/,$p' >> ${TEMP_FILE}
BACKUP=nextflow_original.config

echo "Writing temporary nextflow.config file (Saving old to ${BACKUP})"
cp ${ORIGINAL_CONFIG} ${BACKUP}
mv ${TEMP_FILE} ${ORIGINAL_CONFIG}

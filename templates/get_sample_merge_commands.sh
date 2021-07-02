# !/bin/bash
# Reads in BAMs from nextflow and calls bin script for creating the merge commands
# Nextflow Inputs:
#   BAM_LIST_FILE, (path): BAM files (not necessarily from the same sample)
# Nextflow Outputs:
#   merge_commands.sh, file: File containing all the merge commands, one per line
# Run:
#   Can't be run - relies on ./bin

BAMS=$(cat output_bams.txt | tr '\n' ' ')

# TODO - Remove (Check that multiple of the same BAM are not present)
WARN_BAMS=
for bam in ${BAMS}; do
  bam_base=$(echo ${bam} | cut -d'.' -f1)
  sim_bams=$(echo ${BAMS} | tr ' ' '\n' | grep ${bam_base}).
  num_bams=$(echo ${sim_bams} | tr ' ' '\n' | wc -l)
  if [[ 1 -ne ${num_bams} ]]; then
    WARN_BAMS="${WARN_BAMS} ${bam}"
  fi
done
if [[ -z ${WARN_BAMS} ]]; then
  echo "BAMS: ${WARN_BAMS}" | mail -s "[WARNING] Review input for merged sample BAMs" ${DATA_TEAM_EMAIL}
fi

if [[ -z ${BAMS} ]]; then
  echo "Couldn't find bams in directory: $(pwd). Exiting"
  exit 1
fi

OUTPUT_FILE="merge_commands.sh"
create_merge_commands.py ${OUTPUT_FILE} ${SAMPLE_BAM_DIR} ${BAMS}

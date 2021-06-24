# !/bin/bash
# Reads in BAMs from nextflow and calls bin script for creating the merge commands
# Nextflow Inputs:
#   BAM_LIST_FILE, (path): BAM files (not necessarily from the same sample)
# Nextflow Outputs:
#   merge_commands.sh, file: File containing all the merge commands, one per line
# Run:
#   Can't be run - relies on ./bin

BAMS=$(find -L . -type f -name "*.bam" -exec realpath {} \;)
if [[ -z ${BAMS} ]]; then
  echo "Couldn't find bams in directory: $(pwd). Exiting"
  exit 1
fi

OUTPUT_FILE="merge_commands.sh"
create_merge_commands.py ${OUTPUT_FILE} ${SAMPLE_BAM_DIR} ${BAMS}

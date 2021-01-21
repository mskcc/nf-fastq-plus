#!/bin/bash
# Wrapper around script to compare Picard metrics files in input directories

if [[ -z "$1" || -z "$2" ]]; then
  echo "Please provide directory to search and compare - './compare_picard.sh {target} {source}'"
  echo "e.g.    ./compare_picard.sh /igo/work/streidd/PIPELINE_TESTS/stats /igo/stats/DONE"
  exit 1
fi

#########################################
# Finds the file to compare against
# Globals:
#   COMP_DIR - dir comparison file is in
# Arguments:
#   f - name of file to be compared
#########################################
find_file() {
  input_file=$1

  fname=$(basename ${input_file})
  comp_file=$(find ${COMP_DIR} -type f -name "${fname}")

  echo ${comp_file}
}

STAT_DIR=$1
COMP_DIR=$2
echo "Print searching ${STAT_DIR}..."
FILES=$(find ${STAT_DIR} -type f -name "*.txt")

for target_file in $FILES; do
  comp_file=$(find_file ${target_file})
  if [[ -z "$comp_file" ]]; then
    is_gc=$(echo ${target_file} | grep "___gc_")
    if [[ -z "${is_gc}" ]]; then
      echo "ERROR: Not Compared - $target_file"
    fi
  else
   python compare_picard_files.py ${comp_file} ${target_file}
  fi
done

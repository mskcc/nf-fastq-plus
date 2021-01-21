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
find_file(f) {
  fname=$(basename ${f})
  comp_file = find ${COMP_DIR} -type f -name "${fname}"

  echo ${comp_file}
}

STAT_DIR=$1
COMP_DIR=$2
echo "Print searching ${STAT_DIR}..."
FILES=$(find ${STAT_DIR} -type f -name "*.txt")

for target_file in FILES; do
  comp_file=$(find_file ${target_file})
  python compare_picard_files.py ${f} ${target_file}
done




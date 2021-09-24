#!/bin/bash

PROJECTS=$@

TO_ARCHIVE=""

for prj in ${PROJECTS}; do
  echo ${prj}
  P_DIRS=$(find /igo/staging/FASTQ -mindepth 2 -maxdepth 2 -type d -name "Project_${prj}")
  for pdir in ${P_DIRS}; do
    r_dir=$(dirname ${pdir})
    owner=$(stat -c '%U' ${r_dir})
    printf "\t ${r_dir} ${owner}\n"
    if [[ ${owner} != "seqdataown" ]]; then
      TO_ARCHIVE="${TO_ARCHIVE} ${r_dir}"
    fi
  done
  R_DIRS=$(echo ${P_DIRS} | tr ' ' '\n' | xargs dirname)
done

echo "TO ARCHIVE:"
echo ${TO_ARCHIVE} | tr ' ' '\n' | sort | uniq | grep -v "_REFERENCE" | sed 's/^/\t/g'

#!/bin/bash

PROJECTS=$@

LOCATION=$(dirname $(realpath $0))
CONFIG=${LOCATION}/../nextflow.config
FP_SCRIPT=${LOCATION}/../templates/fingerprint.sh
GENERATE_RUN_PARAMS_SCRIPT=${LOCATION}/../bin/generate_run_params.py

if [[ -f ${CONFIG} && -f ${FP_SCRIPT} ]]; then
  echo "Taking run parameters from ${CONFIG}" 
else
  echo "Invalid CONFIG=${CONFIG} and/or FP_SCRIPT=${FP_SCRIPT}" 
  exit 1
fi

CROSSCHECK_DIR=$(cat ${CONFIG} | grep CROSSCHECK_DIR | cut -d'"' -f2)
LAB_SAMPLE_SHEET_DIR=$(cat ${CONFIG} | grep LAB_SAMPLE_SHEET_DIR | cut -d'"' -f2)

for prj in ${PROJECTS}; do
  prj_ss=$(find ${LAB_SAMPLE_SHEET_DIR}/ -mindepth 1 -maxdepth 1 -type f -exec grep -l "Project_${prj}" {} \; 2>/dev/null)
  latest_ss=$(ls -ta ${prj_ss}  | tail -1)
  if [[ ! -f ${latest_ss} ]]; then
    echo "Invalid Samplesheet: ${latest_ss}"
    exit 1
  else
    species_recipe=$(cat ${latest_ss} | grep ${prj} | cut -d',' -f4,5 | sort | uniq)
    species=$(echo ${species_recipe} | cut -d',' -f1)
    recipe=$(echo ${species_recipe} | cut -d',' -f2)
    HAPLOTYPE_MAP=$(${GENERATE_RUN_PARAMS_SCRIPT} -r ${recipe} -s ${species} | tr ' ' '\n' | grep HAPLOTYPE_MAP | cut -d'=' -f2)
    if [[ ! -z ${HAPLOTYPE_MAP} && -f ${HAPLOTYPE_MAP} ]]; then
      echo "PROJECT=${prj} HAPLOTYPE_MAP=${HAPLOTYPE_MAP}"
      mkdir ${prj}
      cd ${prj}
      CMD="nohup nextflow ${CROSSCHECK_DIR}/crosscheck_metrics.nf --projects ${prj} --m ${HAPLOTYPE_MAP} --s -bg" 
      echo ${CMD}
      eval ${CMD}
      cd -
    else
      echo "Skipping PROJECT=${prj} - Invalid HAPLOTYPE_MAP=${HAPLOTYPE_MAP}"
    fi
  fi
done

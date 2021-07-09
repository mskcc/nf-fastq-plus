# !/bin/bash
# Runs fingerprinting on all projects in the input samplesheet
# Nextflow Inputs:
#   SAMPLE_SHEET, env: Absolute path to the sample sheet
#   CROSSCHECK_DIR, env: Absolute path to the fingerprinting nextflow directory
#   CMD_FILE, env: Absolute path of the file to log commands to
# Run:
#   SAMPLESHEET=/PATH/TO/SAMPLESHEET CROSSCHECK_DIR=/PATH/TO/CROSSCHECK_DIR ./fingerprint.sh

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard CollectAlignmentSummaryMetrics ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD}  >> ${CMD_FILE}
  eval ${INPUT_CMD}
}

#########################################
# Executes projects from a samplesheet
# Arguments:
#   SAMPLESHEET_PARAM - abs path to SS
#########################################
function get_project_species_recipe() {
  SAMPLESHEET_PARAM=$1
  DUAL_PARAM=${2:-NULL}
  if [[ "${DUAL_PARAM}" == "NULL" ]]; then
    awk '{if(found) print} /Lane/{found=1}' ${SAMPLESHEET_PARAM} | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$8,$4,$5}' | sort | uniq
  else
    awk '{if(found) print} /Lane/{found=1}' ${SAMPLESHEET_PARAM} | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$9,$4,$5}' | sort | uniq
  fi
}

DUAL=$(cat $SAMPLESHEET |  awk '{pos=match($0,"index2"); if (pos>0) print pos}')
project_species_recipe_list=$(get_project_species_recipe ${SAMPLESHEET} ${DUAL})
CROSSCHECK_WORKFLOW=${CROSSCHECK_DIR}/main.nf
echo "Running ${CROSSCHECK_WORKFLOW} (PROJECTS_AND_RECIPES=\"${project_species_recipe_list}\" SAMPLESHEET=${SAMPLESHEET})"
IFS=$'\n'
for prj_spc_rec in $project_species_recipe_list; do
  prj=$(echo $prj_spc_rec | awk '{printf"%s\n",$1}' );
  spc=$(echo $prj_spc_rec | awk '{printf"%s\n",$2}' );
  rec=$(echo $prj_spc_rec | awk '{printf"%s\n",$3}' );
  # arrIN=(${prj_spc_rec//,/ })
  # prj=${arrIN[0]}
  prj=${prj#Project_} # remove Project_ prefix
  # spc=${arrIN[1]}
  # rec=${arrIN[2]}
  echo "prj=${prj} spc=${spc} rec=${rec} (${prj_spc_rec})"

  PROJECT_PARAMS=$(generate_run_params.py -r ${rec} -s ${spc}) # Python scripts in bin of project root
  HAPLOTYPE_MAP=$(echo ${PROJECT_PARAMS} | tr ' ' '\n' | grep -e "^HAPLOTYPE_MAP=" | cut -d '=' -f2)
  if [[ -z ${HAPLOTYPE_MAP} || ! -f ${HAPLOTYPE_MAP} ]]; then
    echo "Skipping ${prj} w/ rec ${rec}. Invalid Haplotype Map: ${HAPLOTYPE_MAP}"
    continue
  fi

  FP_PRJ_DIR=Project_${prj}_${rec}
  mkdir $FP_PRJ_DIR
  cd $FP_PRJ_DIR
  CMD="nextflow ${CROSSCHECK_DIR}/crosscheck_metrics.nf --projects $prj --m ${HAPLOTYPE_MAP} --s"
  echo "Fingerprinting Command: ${CMD}"

  # We will ignore errors w/ fingerprinting for now
  set +e
  run_cmd $CMD
  set -e

  cd -
done

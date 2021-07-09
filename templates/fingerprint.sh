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
  DUAL_PARAM=$2
  if [[ "${DUAL_PARAM}" == "$UNASSIGNED_PARAMETER" ]]; then
    awk '{if(found) print} /Lane/{found=1}' ${SAMPLESHEET_PARAM} | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$8,$4,$5}' | sort | uniq
  else
    awk '{if(found) print} /Lane/{found=1}' ${SAMPLESHEET_PARAM} | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$9,$4,$5}' | sort | uniq
  fi
}

SAMPLESHEET=$(find -L . -type f -name "SampleSheet_*.csv")
DUAL=$(cat $SAMPLESHEET |  awk '{pos=match($0,"index2"); if (pos>0) print pos}')

project_species_recipe_list=$(get_project_species_recipe ${SAMPLESHEET} ${DUAL})
echo "Running ${CROSSCHECK_WORKFLOW} (PROJECTS_AND_RECIPES=\"${projects_and_recipe}\" SAMPLESHEET=${SAMPLESHEET})"
for prj_spc_rec in $project_species_recipe_list; do
  arrIN=(${prj_spc_rec//,/ })
  prj=${arrIN[0]}
  prj=${prj#Project_} # remove Project_ prefix
  spc=${arrIN[1]}
  rec=${arrIN[2]}
  echo "prj=${prj} spc=${spc} rec=${rec} (${prj_spc_rec})"

  PROJECT_PARAMS=$(generate_run_params.py -r ${RECIPE} -s ${SPECIES}) # Python scripts in bin of project root
  HAPLOTYPE_MAP=$(echo ${PROJECT_PARAMS} | tr ' ' '\n' | grep -e "^${PARAM_NAME}=" | cut -d '=' -f2)
  if [[ -z ${HAPLOTYPE_MAP} || ! -f ${HAPLOTYPE_MAP} ]]; then
    echo "Skipping ${prj} w/ rec ${rec}. Invalid Haplotype Map: ${HAPLOTYPE_MAP}"
    continue
  fi

  CROSSCHECK_WORKFLOW=${CROSSCHECK_DIR}/main.nf
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

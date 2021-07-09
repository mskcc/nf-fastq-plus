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
function get_samplesheet_projects_and_recipe() {
  SAMPLESHEET_PARAM=$1
  DUAL=$(cat $SAMPLESHEET_PARAM |  awk '{pos=match($0,"index2"); if (pos>0) print pos}')
  if [[ "$DUAL" == "" ]]; then
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET_PARAM | awk 'BEGIN { FS = "," } ;{printf"%s,%s\n",$8,$5}' | sort | uniq
  else
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET_PARAM | awk 'BEGIN { FS = "," } ;{printf"%s,%s\n",$9,$5}' | sort | uniq
  fi
}

#########################################
# Reads input file and outputs param value
# Globals:
#   FILE - file of format "P1=V1 P2=V2 ..."
#   PARAM_NAME - name of parameter
# Arguments:
#   Lane - Sequencer Lane, e.g. L001
#   FASTQ* - absolute path to FASTQ
#########################################
parse_param() {
  FILE=$1
  PARAM_NAME=$2

  cat ${FILE}  | tr ' ' '\n' | grep -e "^${PARAM_NAME}=" | cut -d '=' -f2
}

SAMPLESHEET=$(find -L . -type f -name "SampleSheet_*.csv")

CROSSCHECK_WORKFLOW=${CROSSCHECK_DIR}/main.nf
projects_and_recipe=$(get_samplesheet_projects_and_recipe $SAMPLESHEET)

echo "Running ${CROSSCHECK_WORKFLOW} (PROJECTS_AND_RECIPES=\"${projects_and_recipe}\" SAMPLESHEET=${SAMPLESHEET})"
for prj_recipe in $projects_and_recipe; do
  arrIN=(${prj_recipe//,/ })
  prj=${arrIN[0]}
  prj=${prj#Project_} # remove Project_ prefix
  recipe=${arrIN[1]}
  echo "Project $prj with recipe $recipe from $prj_recipe"

  FP_PRJ_DIR=Project_${prj}_${recipe}

  HAPLOTYPE_MAP=$(parse_param ${RUN_PARAMS_FILE} HAPLOTYPE_MAP)
  if [[ -z ${HAPLOTYPE_MAP} || ! -f ${HAPLOTYPE_MAP} ]]; then
    echo "Skipping ${prj} w/ recipe ${recipe}. Invalid Haplotype Map: ${HAPLOTYPE_MAP}"
    continue
  fi

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

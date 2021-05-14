# !/bin/bash
# Runs fingerprinting on all projects in the input samplesheet
# Nextflow Inputs:
#   SAMPLE_SHEET, env: Absolute path to the sample sheet
#   CROSSCHECK_DIR, env: Absolute path to the fingerprinting nextflow directory
# Run:
#   SAMPLESHEET=/PATH/TO/SAMPLESHEET CROSSCHECK_DIR=/PATH/TO/CROSSCHECK_DIR ./fingerprint.sh

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard CollectAlignmentSummaryMetrics ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD}  >> !{CMD_FILE}
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
  MAP="/home/igo/fingerprint_maps/map_files/hg38_chr.map"
  if [[ "$recipe" == *"ACCESS"* ]]; then
    MAP="/home/igo/fingerprint_maps/map_files/hg38_ACCESS.map"
  fi

  mkdir $FP_PRJ_DIR
  cd $FP_PRJ_DIR
  CMD="nextflow ${CROSSCHECK_DIR}/crosscheck_metrics.nf --projects $prj --s --m ${MAP}"
  echo "Fingerprinting Command: ${CMD}"

  # We will ignore errors w/ fingerprinting for now
  set +e
  run_cmd $CMD
  set -e

  cd -
done

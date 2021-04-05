# !/bin/bash
# Runs fingerprinting on all projects in the input samplesheet
# Nextflow Inputs:
#   SAMPLE_SHEET, env: Absolute path to the sample sheet
#   CROSSCHECK_DIR, env: Absoulte path to the fingerprinting nextflow directory
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
function get_samplesheet_projects() {
  SAMPLESHEET_PARAM=$1
  DUAL=$(cat $SAMPLESHEET_PARAM |  awk '{pos=match($0,"index2"); if (pos>0) print pos}')
  if [[ "$DUAL" == "$UNASSIGNED_PARAMETER" ]]; then
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET_PARAM | awk 'BEGIN { FS = "," } ;{printf"%s\n",$8}' | sort | uniq
  else
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET_PARAM | awk 'BEGIN { FS = "," } ;{printf"%s\n",$9}' | sort | uniq
  fi
}

CROSSCHECK_WORKFLOW=${CROSSCHECK_DIR}/main.nf
projects=$(get_samplesheet_projects $SAMPLESHEET)

echo "Running ${CROSSCHECK_WORKFLOW} (PROJECTS=\"${projects}\" SAMPLESHEET=${SAMPLESHEET})"
for prj in $projects; do
  FP_PRJ=${prj/Project_/}

  mkdir $FP_PRJ
  cd $FP_PRJ
  echo "Fingerprinting Project ${FP_PRJ}"
  CMD="nextflow ${CROSSCHECK_DIR}/crosscheck_metrics.nf --projects $FP_PRJ --s"

  # We will ignore errors w/ fingerprinting for now
  set +e
  run_cmd $CMD
  set -e

  cd -
done

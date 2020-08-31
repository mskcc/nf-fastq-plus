# !/bin/bash
# Configures FASTQ stats from input Runname
# Nextflow Inputs:
#   DEMUXED_RUN (Input): Name of run that has been demultiplexed
#   SAMPLE_SHEET_DIR (Config): Absolute path to where Sample Sheet for @DEMUXED_RUN will be found
#   STATS_DIR (Config): Absolute path to where stats should be written
# Nextflow Outputs:
#   RUN_PARAMS_FILE, file: file of lines of param values needed to run entire pipeline for single or paired FASTQs
# Run: 
#   STATSDIR=/igo/stats RUN=MICHELLE_0246_BHG7L2DSXY SAMPLE_SHEET_DIR=/home/igo/SampleSheetCopies templates/launch_stats.sh

STATSDIR=${STATS_DIR}
RUN=${DEMUXED_RUN}	

SAMPLESHEET=$(find ${SAMPLE_SHEET_DIR} -type f -name "SampleShee*$RUN.csv")
function get_run_type () {
  ROWS=$(sed -n "/Reads/,/Settings/p" $SAMPLESHEET | wc -l)
  if [[ "$ROWS" < 5  ]]; then
    echo "SE"
  else
    echo "PE"
  fi
}

function get_project_species_recipe() {
  if [[ "$DUAL" == "" ]]; then
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$8,$4,$5}' | sort | uniq
  else
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$9,$4,$5}' | sort | uniq
  fi
}

if [[ -z "${SAMPLESHEET}" ]]; then
  echo "No SampleSheet found for Run: ${RUN} in sample sheet directory: ${SAMPLE_SHEET_DIR}"
  touch ${RUN_PARAMS_FILE} # Need to write a file for output to next process or pipeline will fail
  # TODO - Alert
else
  RUN_TYPE=$(get_run_type)
  RUNNAME=$(echo $RUN | awk '{pos=match($0,"_"); print (substr($0,pos+1,length($0)))}')
  #If dual barcode (column index2 exists) then
  DUAL=$(cat $SAMPLESHEET |  awk '{pos=match($0,"index2"); if (pos>0) print pos}')

  echo "Launching RunName: ${RUNNAME}, Run: ${RUN}, SampleSheet: ${SAMPLESHEET}, RunType: ${RUN_TYPE}, Dual Index: ${DUAL}"

  # Tab-delimited project, species, recipe variable,
  #   e.g. "Project_08822_HF	Human	HumanWholeGenome"
  prj_spc_rec=$(get_project_species_recipe)

  IFS=$'\n'
  for psr in $prj_spc_rec; do
    PROJECT=$(echo $psr | awk '{printf"%s\n",$1}' );
    SPECIES=$(echo $psr | awk '{printf"%s\n",$2}' );
    RECIPE=$(echo $psr | awk '{printf"%s\n",$3}' );

    SAMPLE_SHEET_PARAMS="PROJECT=${PROJECT} SPECIES=${SPECIES} RECIPE=${RECIPE}"
    PROJECT_PARAMS=$(generate_run_params.py -r ${RECIPE} -s ${SPECIES}) # Python scripts in bin of project root

    PROJECT_DIR=${FASTQ_DIR}/${RUNNAME}/${PROJECT}
    SAMPLE_DIRS=$(find ${PROJECT_DIR} -mindepth 1 -maxdepth 1 -type d)
    for SAMPLE_DIR in $SAMPLE_DIRS; do
      FASTQS=$(find ${SAMPLE_DIR} -type f -name "*.fastq.gz")
      FASTQ_NUM=1
      FASTQ_PARAMS=""
      for FASTQ in $FASTQS; do
        FASTQ_PARAMS+=" FASTQ${FASTQ_NUM}=${FASTQ}"
        FASTQ_NUM=$(( 1 + FASTQ_NUM ))
      done
      # Encapsulate all required params to send FASTQ(s) down the statistic pipeline in a single line
      echo "$SAMPLE_SHEET_PARAMS $PROJECT_PARAMS $FASTQ_PARAMS" >> ${RUN_PARAMS_FILE}
    done
  done
  IFS=' \t\n'
fi










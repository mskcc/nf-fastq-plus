# !/bin/bash
# Configures FASTQ stats from input Runname
# Nextflow Inputs:
#   FASTQ_DIR (Input): Absolute path to directory that is the output of the demultiplexing
#   SAMPLE_SHEET_DIR (Config): Absolute path to where Sample Sheet for @DEMUXED_RUN will be found
#   STATS_DIR (Config): Absolute path to where stats should be written
# Nextflow Outputs:
#   RUN_PARAMS_FILE, file: file of lines of param values needed to run entire pipeline for single or paired FASTQs
# Run: 
#   Can't be run - relies on ./bin

RUN=$(basename FASTQ_DIR)
SAMPLESHEET=${RUN}/SampleSheet_*.csv # SampleSheet should have been copied from the previous nextflow module

STATSDIR=${STATS_DIR}

# SAMPLESHEET=$(find ${SAMPLE_SHEET_DIR} -type f -name "SampleShee*$RUN.csv")
function get_run_type () {
  ROWS=$(sed -n "/Reads/,/Settings/p" $SAMPLESHEET | wc -l)
  if [[ "$ROWS" < 5  ]]; then
    echo "SE"
  else
    echo "PE"
  fi
}

function get_project_species_recipe() {
  if [[ "$DUAL" == "$UNASSIGNED_PARAMETER" ]]; then
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$8,$4,$5}' | sort | uniq
  else
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$9,$4,$5}' | sort | uniq
  fi
}

touch !{RUN_PARAMS_FILE} # Need to write a file for output to next process or pipeline will fail

if [[ -z "${SAMPLESHEET}" ]]; then
  echo "No SampleSheet found for Run: ${RUN} in sample sheet directory: ${SAMPLE_SHEET_DIR}"
  # TODO - Alert
else
  RUN_TYPE=$(get_run_type)
  RUNNAME=$(echo $RUN | awk '{pos=match($0,"_"); print (substr($0,pos+1,length($0)))}')
  #If dual barcode (column index2 exists) then
  DUAL=$(cat $SAMPLESHEET |  awk '{pos=match($0,"index2"); if (pos>0) print pos}')
  if [[ "$DUAL" == "" ]]; then
    DUAL=$UNASSIGNED_PARAMETER # Assign constant that can be evaluated later in the pipeline
  fi
 
  echo "Launching RunName: ${RUNNAME}, Run: ${RUN}, SampleSheet: ${SAMPLESHEET}, RunType: ${RUN_TYPE}, Dual Index: ${DUAL}"

  # Tab-delimited project, species, recipe variable,
  #   e.g. "Project_08822_HF	Human	HumanWholeGenome"
  prj_spc_rec=$(get_project_species_recipe)

  IFS=$'\n'
  for psr in $prj_spc_rec; do
    PROJECT=$(echo $psr | awk '{printf"%s\n",$1}' );
    SPECIES=$(echo $psr | awk '{printf"%s\n",$2}' );
    RECIPE=$(echo $psr | awk '{printf"%s\n",$3}' );

    SAMPLE_SHEET_PARAMS="PROJECT=${PROJECT} SPECIES=${SPECIES} RECIPE=${RECIPE} RUN_TYPE=${RUN_TYPE} DUAL=${DUAL}"

    PROJECT_PARAMS=$(generate_run_params.py -r ${RECIPE} -s ${SPECIES}) # Python scripts in bin of project root

    PROJECT_DIR=${FASTQ_DIR}/${RUNNAME}/${PROJECT}
    if [ -d "$PROJECT_DIR" ]; then
      SAMPLE_DIRS=$(find ${PROJECT_DIR} -mindepth 1 -maxdepth 1 -type d)
      for SAMPLE_DIR in $SAMPLE_DIRS; do
        FASTQS=$(find ${SAMPLE_DIR} -type f -name "*.fastq.gz")
        if [[ -z $FASTQS ]]; then
          echo "!{RUN_ERROR}: No FASTQS found in $SAMPLE_DIR"	# Catch this exception, but don't fail
          exit 0
        fi
        FASTQ_NUM=1
        FASTQ_PARAMS=""
        for FASTQ in $FASTQS; do
          FASTQ_PARAMS+=" FASTQ${FASTQ_NUM}=${FASTQ}"
          FASTQ_NUM=$(( 1 + FASTQ_NUM ))
        done
        # Encapsulate all required params to send FASTQ(s) down the statistic pipeline in a single line
        echo "RUNNAME=${RUNNAME} $SAMPLE_SHEET_PARAMS $PROJECT_PARAMS $FASTQ_PARAMS" >> !{RUN_PARAMS_FILE}
      done
    else
      echo "ERROR: Could not locate FASTQ files for Run: ${RUNNAME}, Project: ${PROJECT} at ${PROJECT_DIR}"
      # TODO - warning?
    fi
  done
  IFS=' \t\n'
fi










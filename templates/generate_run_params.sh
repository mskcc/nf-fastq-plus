# !/bin/bash
# Configures FASTQ stats from input Runname
# Nextflow Inputs:
#   SAMPLE_SHEET_DIR (Config): Absolute path to where Sample Sheet for @DEMUXED_RUN will be found
#   STATS_DIR (Config): Absolute path to where stats should be written
#
#   RUNNAME (Input): Name of the run
#   DEMUXED_DIR (Input): Absolute path to directory that is the output of the demultiplexing
#   SAMPLESHEET (Input): Absolute path to the sample sheet used to produce the demultiplexing output
# Nextflow Outputs:
#   RUN_PARAMS_FILE, file: file of lines of param values needed to run entire pipeline for single or paired FASTQs
# Run: 
#   Can't be run - relies on ./bin


if [[ -z "${RUN_PARAMS_FILE}" ]]; then
  RUN_PARAMS_FILE="sample_params.txt"
fi

# These are inputs to the nextflow process
echo "Received RUNNAME=${RUNNAME} DEMUXED_DIR=${DEMUXED_DIR} SAMPLESHEET=${SAMPLESHEET} (RUN_PARAMS_FILE=${RUN_PARAMS_FILE})"

RUN=$(basename ${DEMUXED_DIR})
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

#########################################
# Returns sequencing lanes of a sample based on sample sheet
# Arguments:
#   INPUT_SAMPLE_NAME - "Sample_Name" as listed on sample sheet
#   INPUT_SAMPLE_SHEET - Absolute path to sample sheet
#########################################
function get_lanes_of_sample() {
  INPUT_SAMPLE_NAME=$1
  INPUT_SAMPLE_SHEET=$2

  num_lines=$(cat ${INPUT_SAMPLE_SHEET} | wc -l)

  SAMPLE_SHEET_HEADER="^Lane,Sample_ID,Sample_Name"

  LANES=$(grep -A ${num_lines} ${SAMPLE_SHEET_HEADER} ${INPUT_SAMPLE_SHEET} | \
    grep -v SAMPLE_SHEET_HEADER | \
    grep "${INPUT_SAMPLE_NAME}" | \
    cut -d',' -f1 | \
    sort | uniq)

  echo $LANES
}

if [[ -z "${SAMPLESHEET}" ]]; then
  echo "No SampleSheet found for Run: ${RUN} in sample sheet directory: ${SAMPLE_SHEET_DIR}"
  # TODO - Alert
else
  RUN_TYPE=$(get_run_type)
  #If dual barcode (column index2 exists) then
  DUAL=$(cat $SAMPLESHEET |  awk '{pos=match($0,"index2"); if (pos>0) print pos}')
  if [[ "$DUAL" == "" ]]; then
    DUAL=$UNASSIGNED_PARAMETER # Assign constant that can be evaluated later in the pipeline
  fi
 
  
  # Tab-delimited project, species, recipe variable,
  #   e.g. "Project_08822_HF	Human	HumanWholeGenome"
  prj_spc_rec=$(get_project_species_recipe)
  echo "Launching RunName: ${RUNNAME}, Run: ${RUN}, SampleSheet: ${SAMPLESHEET}, RunType: ${RUN_TYPE}, Dual Index: ${DUAL} PSR=${prj_spc_rec}"

  # Not being able to parse PROJECT, SPECIES, RECIPE is valid for runs w/ samplesheets that don't have sample rows (e.g. ADAPTIVE on SCOTT)
  if [[ -z ${prj_spc_rec} ]]; then
    echo "Failed to extract Project, Species, Recipe from SampleSheet: ${SAMPLESHEET}"
    exit 1
  fi

  IFS=$'\n'
  for psr in $prj_spc_rec; do
    PROJECT=$(echo $psr | awk '{printf"%s\n",$1}' );
    SPECIES=$(echo $psr | awk '{printf"%s\n",$2}' );
    RECIPE=$(echo $psr | awk '{printf"%s\n",$3}' );

    SAMPLE_SHEET_PARAMS="PROJECT=${PROJECT} SPECIES=${SPECIES} RECIPE=${RECIPE} RUN_TYPE=${RUN_TYPE} DUAL=${DUAL}"

    PROJECT_PARAMS=$(generate_run_params.py -r ${RECIPE} -s ${SPECIES}) # Python scripts in bin of project root

    # Extract GTAG value from generate_run_params.py output for ${RUN_TAG}, e.g. "...GTAG=GRCh37..." => "GRCh37"
    GTAG=$(echo ${PROJECT_PARAMS} | tr ' ' '\n' | grep 'GTAG' | cut -d'=' -f2)

    PROJECT_DIR=${DEMUXED_DIR}/${PROJECT}
    if [ -d "$PROJECT_DIR" ]; then
      RUN_DIR=$(echo ${PROJECT_DIR} | xargs dirname)

      # TODO - Make "___" a delimiter
      PROJECT_TAG=$(echo ${PROJECT_DIR} | xargs basename | sed 's/Project_/P/g')
      SAMPLE_DIRS=$(find ${PROJECT_DIR} -mindepth 1 -maxdepth 1 -type d)
      for SAMPLE_DIR in $SAMPLE_DIRS; do
        SAMPLE_TAG=$(echo ${SAMPLE_DIR} | xargs basename | sed 's/Sample_//g')
        SAMPLE_LANES=$(get_lanes_of_sample ${SAMPLE_TAG} ${SAMPLESHEET})
        # This will track all the parameters needed to complete the pipeline for a sample - each line will be one
        # lane of processing
        SAMPLE_PARAMS_FILE="${SAMPLE_TAG}___${RUN_PARAMS_FILE}"
        for LANE in $(echo ${SAMPLE_LANES} | tr ' ' '\n'); do
          LANE_TAG="L00${LANE}" # Assuming there's never going to be a lane greater than 9...
          RUN_TAG="${RUNNAME}___${PROJECT_TAG}___${SAMPLE_TAG}___${GTAG}" # RUN_TAG will determine the name of output stats

          # RUN_TAG="$(echo ${RUN_DIR} | xargs basename)___${PROJECT_TAG}___${SAMPLE_TAG}"
          TAGS="RUN_TAG=${RUN_TAG} PROJECT_TAG=${PROJECT_TAG} SAMPLE_TAG=${SAMPLE_TAG} LANE_TAG=${LANE_TAG}"

          FASTQ_REGEX="*_${LANE_TAG}_R[12]_*.fastq.gz"
          FASTQS=$(find ${SAMPLE_DIR} -type f -name ${FASTQ_REGEX})
          if [[ -z $FASTQS ]]; then
            echo "!{RUN_ERROR}: No FASTQS (regex: ${FASTQ_REGEX}) found in $SAMPLE_DIR"	# Catch this exception, but don't fail
            exit 1
          fi

          FASTQ_PARAMS=""
          # Create symbolic links to FASTQs so they can be sent via channel, @FASTQ_CH
          for SOURCE_FASTQ in $FASTQS; do
            FASTQ_PARAMS="${FASTQ_PARAMS} FASTQ=${SOURCE_FASTQ}"
          done
          # Encapsulate all required params to send FASTQ(s) down the statistic pipeline in a single line
          echo "RUNNAME=${RUNNAME} $SAMPLE_SHEET_PARAMS $PROJECT_PARAMS $TAGS ${FASTQ_PARAMS}" >> ${SAMPLE_PARAMS_FILE}
        done
        if [ ! -f "$SAMPLE_PARAMS_FILE" ]; then
          echo "Failed to write param file for ${SAMPLE_TAG} (${SAMPLE_PARAMS_FILE}). Failed to extract lane(s) or find FASTQ files"
          exit 1
        fi
      done
    else
      echo "ERROR: Could not locate Request directory w/ FASTQs for Run: ${RUNNAME}, Project: ${PROJECT} at ${PROJECT_DIR}"
      # TODO - warning?
    fi
  done
  IFS=' \t\n'
fi

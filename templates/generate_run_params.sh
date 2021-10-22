# !/bin/bash
# Generates parameter file, which encapsulates all values needed by all downstream downstream nextflow tasks
#   Steps:
#     1. Parse fields from SampleSheet (e.g. project, recipe, species)
#     2. Create Sample Parms .txt files (*${RUN_PARAMS_FILE}.txt) - different prefixes of these files determine
#        downstream branching logic in nextflow
#
# Nextflow Inputs:
#   SAMPLE_SHEET_DIR (Config): Absolute path to where Sample Sheet for @DEMUXED_RUN will be found
#   STATS_DIR (Config): Absolute path to where stats should be written
#
#   DEMUXED_DIR (Input): Absolute path to directory that is the output of the demultiplexing
#   SAMPLESHEET (Input): Absolute path to the sample sheet used to produce the demultiplexing output
# Nextflow Outputs:
#   RUN_PARAMS_FILE, file: file of lines of param values needed to run entire pipeline for single or paired FASTQs
# Run: 
#   Can't be run - relies on ./bin

DGN_DEMUX_ALN_RECIPES="HumanWholeGenome"    # Recipes for which we send to DRAGEN
DGN_SAMPLE_PARAMS_PREFIX="DGN___"           # Prefix for *sample_params.txt, which nextflow uses for routing

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

  # Regex of demux headers - include only required in the order they appear
  SAMPLE_SHEET_HEADER="^Lane,.*Sample_ID,.*index.*"

  LANES=$(grep -A ${num_lines} ${SAMPLE_SHEET_HEADER} ${INPUT_SAMPLE_SHEET} | \
    grep -v SAMPLE_SHEET_HEADER | \
    grep "${INPUT_SAMPLE_NAME}" | \
    cut -d',' -f1 | \
    sort | uniq)

  echo $LANES
}

if [[ -z "${RUN_PARAMS_FILE}" ]]; then
  RUN_PARAMS_FILE="sample_params.txt"
fi

# We write the location of all the BAMs that should be created to this file
RUN_BAMS="run_bams.txt"
touch ${RUN_BAMS}
RUNNAME="INVALID" # We do this b/c nextflow expects to export this environment variable

echo "Received DEMUXED_DIR=${DEMUXED_DIR} SAMPLESHEET=${SAMPLESHEET} FILTER=${FILTER}"
if [ ! -f ${SAMPLESHEET} ]; then
  msg="No SampleSheet found for DEMUXED_DIR=${DEMUXED_DIR} SAMPLESHEET=${SAMPLESHEET}"
  echo ${msg}
  # "NONE" is used as a placeholder when trying to merge all legacy BAMs, but request has no previous runs
  if [[ ${SAMPLESHEET} != "NONE" ]]; then
    echo ${msg} | mail -s "[ERROR] No Samplesheet" ${DATA_TEAM_EMAIL}
  fi
else
  SPLIT_RUNNAME=$(basename ${DEMUXED_DIR})
  MACHINE=$(echo ${SPLIT_RUNNAME} | cut -d'_' -f1)  # MICHELLE_0347_BHWN55DMXX_DLP -> MICHELLE
  RUN_NUM=$(echo ${SPLIT_RUNNAME} | cut -d'_' -f2)  # MICHELLE_0347_BHWN55DMXX_DLP -> 0347
  FLOWCELL=$(echo ${SPLIT_RUNNAME} | cut -d'_' -f3) # MICHELLE_0347_BHWN55DMXX_DLP -> BHWN55DMXX
  RUNNAME="${MACHINE}_${RUN_NUM}_${FLOWCELL}"

  # These are inputs to the nextflow process
  echo "Evaluated RUNNAME=${RUNNAME} DEMUXED_DIR=${DEMUXED_DIR} SAMPLESHEET=${SAMPLESHEET} (RUN_PARAMS_FILE=${RUN_PARAMS_FILE})"

  RUN=$(basename ${DEMUXED_DIR})
  STATSDIR=${STATS_DIR}

  RUN_TYPE=$(get_run_type)
  #If dual barcode (column index2 exists) then
  DUAL=$(cat $SAMPLESHEET |  awk '{pos=match($0,"index2"); if (pos>0) print pos}')
  if [[ "$DUAL" == "" ]]; then
    DUAL=$UNASSIGNED_PARAMETER # Assign constant that can be evaluated later in the pipeline
  fi
 
  # Tab-delimited project, species, recipe variable,
  #   e.g. "Project_08822_HF	Human	HumanWholeGenome"
  prj_spc_rec=$(get_project_species_recipe)
  echo "Launching RunName: ${RUNNAME}, Run: ${RUN}, SampleSheet: ${SAMPLESHEET}, RunType: ${RUN_TYPE}, Dual Index: ${DUAL} PSR=[$(echo ${prj_spc_rec} | tr ' ' ',' | tr '\n' ';')]"

  # Not being able to parse PROJECT, SPECIES, RECIPE is valid for runs w/ samplesheets that don't have sample rows (e.g. ADAPTIVE on SCOTT)
  if [[ -z ${prj_spc_rec} ]]; then
    echo "Failed to extract Project, Species, Recipe from SampleSheet: ${SAMPLESHEET}"
    exit 1
  fi

  IFS=$'\n'

  # TODO - Remove when PED_PEG is integrated in nextflow pipeline
  PPG_REQUESTS=""

  SKIPPING_SAMPLE_STATS_PRJS=""
  SKIPPING_SAMPLE_STATS_BODY=""
  for psr in $prj_spc_rec; do
    PROJECT=$(echo $psr | awk '{printf"%s\n",$1}' );
    SPECIES=$(echo $psr | awk '{printf"%s\n",$2}' );
    RECIPE=$(echo $psr | awk '{printf"%s\n",$3}' );

    # Create list of failed samples in a request, e.g. "FAILED_SAMPLES___${REUQEST}.txt" (Skip if previous loop created)
    FAILED_PRJ_SAMPLES_FILE="Failed___${RUNNAME}_${PROJECT}"
    if [[ -f ${FAILED_PRJ_SAMPLES_FILE} ]]; then
      retrieve_failed_samples.py --r=${RUNNAME} --p=${prj} --n=${FAILED_PRJ_SAMPLES_FILE}
    fi

    # Stats calculated only if w/ valid project, species, & recipe
    # Note: Controls like FFPE POOLED NORMAL don't need recipe, but we skip the stat-calculations
    if [[ -z ${PROJECT} || -z ${SPECIES} || -z ${RECIPE} ]]; then
      echo "Detected invalid PSR - PROJECT=${PROJECT} SPECIES=${SPECIES} RECIPE=${RECIPE}"
      continue
    fi
   
    SAMPLE_SHEET_PARAMS="PROJECT=${PROJECT} SPECIES=${SPECIES} RECIPE=${RECIPE} RUN_TYPE=${RUN_TYPE} DUAL=${DUAL}"
    echo "SAMPLE_SHEET_PARAMS: ${SAMPLE_SHEET_PARAMS}"
    PROJECT_PARAMS=$(generate_run_params.py -r ${RECIPE} -s ${SPECIES}) # Python scripts in bin of project root

    # Extract GTAG value from generate_run_params.py output for ${RUN_TAG}, e.g. "...GTAG=GRCh37..." => "GRCh37"
    GTAG=$(echo ${PROJECT_PARAMS} | tr ' ' '\n' | grep 'GTAG' | cut -d'=' -f2)

    PROJECT_TAG=$(echo ${PROJECT} | sed 's/Project_/P/g')
    PROJECT_DIR=${DEMUXED_DIR}/${PROJECT}
    if [[ ! -z ${FILTER} && $(echo ${PROJECT_DIR} | grep -c "${FILTER}$") -eq 0 ]]; then
      echo "${PROJECT_DIR} did not pass filter: ${FILTER}"
      continue
    fi
    if [ -d "$PROJECT_DIR" ]; then
      if [[ "${RECIPE}" = "DLP" ]]; then
        echo "DLP requests will be skipped for PROJECT=${PROJECT} SPECIES=${SPECIES} RECIPE=${RECIPE}"
        continue
      elif [[ ! -z $(echo ${SAMPLESHEET} | grep ".*_PPG.csv$") ]]; then
        echo "PED-PEG requests will be skipped for PROJECT=${PROJECT} SPECIES=${SPECIES} RECIPE=${RECIPE}"
        PPG_REQUESTS="${PROJECT} ${PPG_REQUESTS}"
        continue
      fi

      # We want a list of all the samples as they are listed in the samplesheet "Sample_Name" column
      # NOTE - W/ DRAGEN demultiplexing, there is no Sample_Name directory
      FASTQ_REGEX=".*IGO_[0-9]{5}_([A-Z]{1,2}_[0-9]+|[0-9]+)"
      SAMPLE_TAGS=$(find ${PROJECT_DIR} -type f -name "*.fastq.gz" \
        -exec basename {} \; \
        | grep -oP "${FASTQ_REGEX}" \
        | sort \
        | uniq)

      if [[ -z ${SAMPLE_TAGS} ]]; then
        BODY="No FASTQS - PROJECT_DIR=${PROJECT_DIR} FASTQ_REGEX=${FASTQ_REGEX}"
        SUBJECT="[ACTION REQUIRED] No FASTQS for $(dirname ${PROJECT_DIR})"
        echo ${BODY} | mail -s "${SUBJECT}" ${DATA_TEAM_EMAIL}
        echo ${BODY}
        exit 1
      fi

      # Check for missing Samples
      present_fastq_check_regex="$(echo ${SAMPLE_TAGS} | sed 's/ /,|/g'),"

      echo "Checking ${SAMPLESHEET} for missing fastqs for project ${PROJECT}. REGEX=${present_fastq_check_regex}"
      missing_samplesheet_entries=$(cat ${SAMPLESHEET} | grep ${PROJECT} | grep -v -P "${present_fastq_check_regex}")

      if [[ ! -z ${missing_samplesheet_entries} ]]; then
        # Pipeline has failed for this sample - Data Team needs to be alerted
        SKIPPING_SAMPLE_STATS_SUBJ="[ACTION-REQUIRED] Missing FASTQs in ${PROJECT_DIR} (RUNNAME=${RUNNAME} PROJECT_TAG=${PROJECT_TAG})"
        echo ${SKIPPING_SAMPLE_STATS_SUBJ}
        echo ${missing_samplesheet_entries} | mail -s "${SKIPPING_SAMPLE_STATS_SUBJ}" ${DATA_QC_ALERTS}
      fi

      for SAMPLE_TAG in ${SAMPLE_TAGS}; do
        RUN_TAG="${RUNNAME}___${PROJECT_TAG}___${SAMPLE_TAG}___${GTAG}___${RECIPE}" # RUN_TAG will determine the name of output stats
        FINAL_BAM=${STATS_DIR}/${RUNNAME}/${RUN_TAG}.bam                # Location of final BAM for sample

        # We add the final BAM & RUN_TAG so we can check that the BAM was written and stats of name ${RUN_TAG} exist
        echo "${FINAL_BAM}" >> ${RUN_BAMS}
        if [[ -f ${FINAL_BAM} ]]; then
          echo "Final BAM has already been written - ${FINAL_BAM}. Skipping."
          continue
        else
          echo "BAM needs to be created - ${FINAL_BAM}. Processing."
        fi

        SAMPLE_LANES=$(get_lanes_of_sample ${SAMPLE_TAG} ${SAMPLESHEET})

        # This will track all the parameters needed to complete the pipeline for a sample - each line will be one
        # lane of processing.
        #   - We add the DRAGEN prefix if it is intended for DRAGEN's alignment. DRAGEN projects also need to indicate
        #     their FASTQ_LIST file
        echo "Checking if '${RECIPE}' is a DRAGEN recipe [ ${DGN_DEMUX_ALN_RECIPES} ]..."
        if [[ ! -z $(echo "${DGN_DEMUX_ALN_RECIPES}" | tr ' ' '\n' | grep -oP "^${RECIPE}$") ]]; then
          SAMPLE_PARAMS_FILE="${DGN_SAMPLE_PARAMS_PREFIX}${SAMPLE_TAG}___${SPECIES}___${RECIPE}___${RUN_PARAMS_FILE}"
          FASTQ_LIST_FILE=$(find ${DEMUXED_DIR} -type f -name "fastq_list.csv")
          if [[ -z ${FASTQ_LIST_FILE} ]]; then
            SUBJECT="[ACTION REQUIRED] Skipping DRAGEN sample - Missing fastq_list.csv file"
            BODY="Sample in ${PROJECT_TAG} in ${DEMUXED_DIR} was identified as a project to run through DRAGEN, but did "
            BODY+="not have a DRAGEN demux structure (RUNNAME=${RUNNAME}). Stats were not run for this request"
            echo ${BODY} | mail -s "${SUBJECT}" ${DATA_TEAM_EMAIL}
          fi
          INFO="FASTQ_LIST_FILE=${FASTQ_LIST_FILE} RUNNAME=${RUNNAME} FINAL_BAM=${FINAL_BAM}"
        else
          SAMPLE_PARAMS_FILE="${SAMPLE_TAG}___${SPECIES}___${RECIPE}___${RUN_PARAMS_FILE}"
          FASTQ_LIST_FILE="NOT_DGN"
        fi

        for LANE in $(echo ${SAMPLE_LANES} | tr ' ' '\n'); do
          LANE_TAG="L00${LANE}" # Assuming there's never going to be a lane greater than 9...

          # RUN_TAG="$(echo ${RUN_DIR} | xargs basename)___${PROJECT_TAG}___${SAMPLE_TAG}"
          TAGS="RUN_TAG=${RUN_TAG} PROJECT_TAG=${PROJECT_TAG} SAMPLE_TAG=${SAMPLE_TAG} LANE_TAG=${LANE_TAG} RGID=${SAMPLE_TAG}_${LANE}" # TODO - replace RGID w/ [INDEX].[LANE]

          FASTQ_REGEX="*_${LANE_TAG}_R[12]_*.fastq.gz"
          FASTQS=$(find ${PROJECT_DIR} -type f -name ${FASTQ_REGEX} | sort)	# We sort so that R1 is always before R2

          FASTQ_PARAMS="FASTQ_LIST_FILE=${FASTQ_LIST_FILE} "
          # Create symbolic links to FASTQs so they can be sent via channel, @FASTQ_CH
          for SOURCE_FASTQ in $FASTQS; do
            FASTQ_PARAMS="${FASTQ_PARAMS} FASTQ=${SOURCE_FASTQ}"
          done
          # Encapsulate all required params to send FASTQ(s) down the statistic pipeline in a single line
          echo "RUNNAME=${RUNNAME} FINAL_BAM=${FINAL_BAM} $SAMPLE_SHEET_PARAMS $PROJECT_PARAMS $TAGS ${FASTQ_PARAMS}" >> ${SAMPLE_PARAMS_FILE}
        done
      done
    else
      SUBJECT="[WARNING] Request directory not found: ${PROJECT}"
      BODY="Directory named '${PROJECT}' was not found in ${DEMUXED_DIR} (RUNNAME=${RUNNAME}). Stats were not run for this request"
      echo ${BODY} | mail -s "${SUBJECT}" ${DATA_TEAM_EMAIL}
    fi
  done

  if [[ ! -z ${PPG_REQUESTS} ]]; then
    SUBJECT="[ACTION-REQUIRED] PED-PEG Requests on ${RUNNAME}"
    BODY="Please Run PED-PEG pipeline on following Requests: ${PPG_REQUESTS}. DRAGEN stats are currently running..."
    echo ${BODY} | mail -s "${SUBJECT}" ${DATA_TEAM_EMAIL}
  fi
  IFS=' \t\n'
fi

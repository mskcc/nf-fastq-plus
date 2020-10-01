# !/bin/bash
# Parses param line & assigns each value to a variable in the bash execution context for downstream nextflow process
# Nextflow Inputs:
#   PARAM_LINE (Input): param=value space-delimited line of params
#   UNASSIGNED_PARAMETER (Config): value to default unassigned parameters to (nextflow needs to have a non-blank value)
# Nextflow Outputs:
#   PROJECT, env
#   SPECIES, env
#   RECIPE, env
#   TYPE, env
#   GENOME, env
#   REFERENCE, env
#   REF_FLAT, env
#   RIBOSOMAL_INTERVALS, env
#   GTAG, env
#   BAITS, env
#   TARGETS, env
#   MSKQ, env
#   MD, env
#   FASTQ1, env
#   FASTQ2, env
# Run:
#   UNASSIGNED_PARAMETER="." PARAM_LINE="PROJECT=P1 SPECIES=S1 RECIPE=REC1 FASTQ1=F1 FASTQ2=F2" send_project_params.sh

# Mandatory Parameters
PROJECT=$UNASSIGNED_PARAMETER
SPECIES=$UNASSIGNED_PARAMETER
RECIPE=$UNASSIGNED_PARAMETER
FASTQ1=$UNASSIGNED_PARAMETER
FASTQ2=$UNASSIGNED_PARAMETER

# Statistics Parameters
TYPE=$UNASSIGNED_PARAMETER
# 2) Determined by genome & type (see: genome_reference_mapping)
GENOME=$UNASSIGNED_PARAMETER
REFERENCE=$UNASSIGNED_PARAMETER
REF_FLAT=$UNASSIGNED_PARAMETER
RIBOSOMAL_INTERVALS=$UNASSIGNED_PARAMETER
GTAG=$UNASSIGNED_PARAMETER
# 3) Determined by recipe (see: recipe_options_mapping)
BAITS=$UNASSIGNED_PARAMETER
TARGETS=$UNASSIGNED_PARAMETER
MSKQ=$UNASSIGNED_PARAMETER
MD=$UNASSIGNED_PARAMETER
RUN_TYPE=$UNASSIGNED_PARAMETER
DUAL=$UNASSIGNED_PARAMETER
RUN_TAG=$UNASSIGNED_PARAMETER
SAMPLE_TAG=$UNASSIGNED_PARAMETER

ASSIGNED_PARAMS=""
for pv in ${PARAM_LINE}; do
  PARAM=$(echo $pv | cut -d"=" -f1)
  VALUE=$(echo $pv | cut -d"=" -f2)
  case $PARAM in
    FASTQ*)
      # Create symboli links to FASTQs so they can be sent via channel, @FASTQ_CH
      TARGET_FASTQ=$(basename $VALUE)  
      echo "Linking ${VALUE} to ${TARGET_FASTQ}" 
      ln -s $VALUE $TARGET_FASTQ;;
    PROJECT)
      PROJECT=$VALUE
      ASSIGNED_PARAMS+="PROJECT=$VALUE ";;
    SPECIES)
      SPECIES=$VALUE
      ASSIGNED_PARAMS+="SPECIES=$VALUE ";;
    RECIPE)
      RECIPE=$VALUE
      ASSIGNED_PARAMS+="RECIPE=$VALUE ";;
    REFERENCE)
      REFERENCE=$VALUE
      ASSIGNED_PARAMS+="REFERENCE=$VALUE ";;
    REF_FLAT)
      REF_FLAT=$VALUE
      ASSIGNED_PARAMS+="REF_FLAT=$VALUE ";;
    RIBOSOMAL_INTERVALS)
      RIBOSOMAL_INTERVALS=$VALUE
      ASSIGNED_PARAMS+="RIBOSOMAL_INTERVALS=$VALUE ";;
    GTAG)
      GTAG=$VALUE
      ASSIGNED_PARAMS+="GTAG=$VALUE ";;
    REFERENCE)
      REFERENCE=$VALUE
      ASSIGNED_PARAMS+="REFERENCE=$VALUE ";;
    GENOME)
      GENOME=$VALUE
      ASSIGNED_PARAMS+="GENOME=$VALUE ";;
    BAITS)
      BAITS=$VALUE
      ASSIGNED_PARAMS+="BAITS=$VALUE ";;
    TARGETS)
      TARGETS=$VALUE
      ASSIGNED_PARAMS+="TARGETS=$VALUE ";;
    TYPE)
      TYPE=$VALUE
      ASSIGNED_PARAMS+="TYPE=$VALUE ";;
    CAPTURE)
      CAPTURE=$VALUE
      ASSIGNED_PARAMS+="CAPTURE=$VALUE ";;
    MSKQ)
      MSKQ=$VALUE
      ASSIGNED_PARAMS+="MSKQ=$VALUE ";;
    MD)
      MD=$VALUE
      ASSIGNED_PARAMS+="MD=$VALUE ";;
    RUN_TYPE)
      RUN_TYPE=$VALUE
      ASSIGNED_PARAMS+="RUN_TYPE=$VALUE ";;
    DUAL)
      DUAL=$VALUE
      ASSIGNED_PARAMS+="DUAL=$VALUE ";;
    *)
      echo ""
      echo "Failed to assign param: ${PARAM} with value: ${VALUE}"
  esac
done

# Check that sym-link ASTQs are present and create tags for runs
FASTQ_LINKS=$(find . -type l -name "*.fastq.gz")        # Sym-links
FASTQS=$(echo ${FASTQ_LINKS} | xargs readlink -f)       # Retrieve source of sym-links
SAMPLE_DIR=$(echo ${FASTQS} | xargs dirname | sort | uniq)
if [[ $(echo ${SAMPLE_DIR}| wc -l) -ne 1 ]]; then
  # FASTQs should come from the same directory
  echo "ERROR - FASTQ files are from different directories: ${SAMPLE_DIR}"
  exit 1
fi

PROJECT_DIR=$(echo ${SAMPLE_DIR} | xargs dirname)
RUN_DIR=$(echo ${PROJECT_DIR} | xargs dirname)

SAMPLE_TAG=$(echo ${SAMPLE_DIR} | xargs basename | sed 's/Sample_//g')
PROJECT_TAG=$(echo ${PROJECT_DIR} | xargs basename | sed 's/Project_/P/g')
RUN_TAG="$(echo ${RUN_DIR} | xargs basename)___${PROJECT_TAG}___${SAMPLE_TAG}___${GTAG}"

echo $ASSIGNED_PARAMS
echo "RUN_TAG=${RUN_TAG} PROJECT_TAG=${PROJECT_TAG} SAMPLE_TAG=${SAMPLE_TAG}"

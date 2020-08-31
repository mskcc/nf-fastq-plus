# !/bin/bash
# Parses input line of params into each part
# Nextflow Inputs:
#   TODO
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

UNASSIGNED="{}"

# ALL POSSIBLE PARAMS
TYPE=$UNASSIGNED
# 2) Determined by genome & type (see: genome_reference_mapping)
GENOME=$UNASSIGNED
REFERENCE=$UNASSIGNED
REF_FLAT=$UNASSIGNED
RIBOSOMAL_INTERVALS=$UNASSIGNED
GTAG=$UNASSIGNED
# 3) Determined by recipe (see: recipe_options_mapping)
BAITS=$UNASSIGNED
TARGETS=$UNASSIGNED
MSKQ=$UNASSIGNED
MD=$UNASSIGNED
# 4) Files of FASTQ
FASTQ1=$UNASSIGNED
FASTQ2=$UNASSIGNED

ASSIGNED_PARAMS=""
for pv in ${PARAM_LINE}; do
  PARAM=$(echo $pv | cut -d"=" -f1)
  VALUE=$(echo $pv | cut -d"=" -f2)
  case $PARAM in
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
    FASTQ1)
      FASTQ1=$VALUE
      ASSIGNED_PARAMS+="FASTQ1=$VALUE ";;
    FASTQ2)
      FASTQ2=$VALUE
      ASSIGNED_PARAMS+="FASTQ2=$VALUE ";;
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
    *)
      echo ""
      echo "Failed to assign param: ${PARAM} with value: ${VALUE}"
  esac
done

echo $ASSIGNED_PARAMS

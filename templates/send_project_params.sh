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

for pv in ${PARAM_LINE}; do
  PARAM=$(printf $pv | cut -d"=" -f1)
  VALUE=$(printf $pv | cut -d"=" -f2)
  case $PARAM in
    GENOME)
      GENOME=$VALUE
      printf " GENOME=$VALUE";;
    REFERENCE)
      REFERENCE=$VALUE
      printf " REFERENCE=$VALUE";;
    REF_FLAT)
      REF_FLAT=$VALUE
      printf " REF_FLAT=$VALUE";;
    RIBOSOMAL_INTERVALS)
      RIBOSOMAL_INTERVALS=$VALUE
      printf " RIBOSOMAL_INTERVALS";;
    GTAG)
      GTAG=$VALUE
      printf " GTAG=$VALUE";;
    FASTQ1)
      FASTQ1=$VALUE
      printf " FASTQ1=$VALUE";;
    FASTQ2)
      FASTQ2=$VALUE
      printf " FASTQ2=$VALUE";;
    REFERENCE)
      REFERENCE=$VALUE
      printf " REFERENCE=$VALUE";;
    GENOME)
      GENOME=$VALUE
      printf " GENOME=$VALUE";;
    BAITS)
      BAITS=$VALUE
      printf " BAITS=$VALUE";;
    TARGETS)
      TARGETS=$VALUE
      printf " TARGETS=$VALUE";;
    TYPE)
      TYPE=$VALUE
      printf " TYPE=$VALUE";;
    CAPTURE)
      CAPTURE=$VALUE
      printf " CAPTURE=$VALUE";;
    MSKQ)
      MSKQ=$VALUE
      printf " MSKQ=$VALUE";;
    MD)
      MD=$VALUE
      printf " MD=$VALUE";;
    *)
      echo ""
      echo "Failed to assign param: ${PARAM} with value: ${VALUE}"
  esac
done

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
GENOME=$UNASSIGNED
REFERENCE=$UNASSIGNED
REF_FLAT=$UNASSIGNED
RIBO_INTER=$UNASSIGNED
GTAG=$UNASSIGNED
FASTQ1=$UNASSIGNED
FASTQ2=$UNASSIGNED
REFERENCE=$UNASSIGNED
GENOME=$UNASSIGNED
BAIT=$UNASSIGNED
TARGET=$UNASSIGNED
CAPTURE=$UNASSIGNED
MSKQ=$UNASSIGNED
MARKDUPLICATES=$UNASSIGNED

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
    RIBO_INTER)
      RIBO_INTER=$VALUE
      printf " RIBO_INTER=$VALUE";;
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
    BAIT)
      BAIT=$VALUE
      printf " BAIT=$VALUE";;
    TARGET)
      TARGET=$VALUE
      printf " TARGET=$VALUE";;
    TYPE)
      TYPE=$VALUE
      printf " TYPE=$VALUE";;
    CAPTURE)
      CAPTURE=$VALUE
      printf " CAPTURE=$VALUE";;
    MSKQ)
      MSKQ=$VALUE
      printf " MSKQ=$VALUE";;
    MARKDUPLICATES)
      MARKDUPLICATES=$VALUE
      printf " MARKDUPLICATES=$VALUE";;
    *)
      echo ""
      echo "Failed to assign param: ${PARAM} with value: ${VALUE}"
  esac
done

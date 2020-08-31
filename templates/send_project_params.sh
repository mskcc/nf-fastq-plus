# !/bin/bash
# Parses input line of params into each part
# Nextflow Inputs:
#   TODO
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

UNASSIGNED=""

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
  PARAM=$(echo $pv | cut -d"=" -f1)
  VALUE=$(echo $pv | cut -d"=" -f2)
  DEFAULT = "DEFAULT_TYPE"
  case $PARAM in
    GENOME)
      GENOME=$PARAM
      printf " GENOME=$PARAM";;
    REFERENCE)
      REFERENCE=$PARAM
      printf " REFERENCE=$PARAM";;
    REF_FLAT)
      REF_FLAT=$PARAM
      printf " REF_FLAT=$PARAM";;
    RIBO_INTER)
      RIBO_INTER=$PARAM
      printf " RIBO_INTER=$PARAM";;
    GTAG)
      GTAG=$PARAM
      printf " GTAG=$PARAM";;
    FASTQ1)
      FASTQ1=$PARAM
      printf " FASTQ1=$PARAM";;
    FASTQ2)
      FASTQ2=$PARAM
      printf " FASTQ2=$PARAM";;
    REFERENCE)
      REFERENCE=$PARAM
      printf " REFERENCE=$PARAM";;
    GENOME)
      GENOME=$PARAM
      printf " GENOME=$PARAM";;
    BAIT)
      BAIT=$PARAM
      printf " BAIT=$PARAM";;
    TARGET)
      TARGET=$PARAM
      printf " TARGET=$PARAM";;
    CAPTURE)
      CAPTURE=$PARAM
      printf " CAPTURE=$PARAM";;
    MSKQ)
      MSKQ=$PARAM
      printf " MSKQ=$PARAM";;
    MARKDUPLICATES)
      MARKDUPLICATES=$PARAM
      printf " MARKDUPLICATES=$PARAM";;
    *)
      echo "Failed to assign param: ${PARAM} with value: ${VALUE}"
  esac
done

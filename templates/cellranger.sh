#!/bin/bash

#########################################
# Reads input file and outputs param value
# Globals:
#   FILE - file of format "P1=V1 P2=V2 ..."
#   PARAM_NAME - name of parameter
# Arguments:
#   Lane - Sequencer Lane, e.g. L001
#   FASTQ* - absolute path to FASTQ
#########################################
parse_param() {
  FILE=$1
  PARAM_NAME=$2

  cat ${FILE}  | tr ' ' '\n' | grep -e "^${PARAM_NAME}=" | cut -d '=' -f2
}

RECIPE=$(parse_param ${RUN_PARAMS_FILE} RECIPE)          # Must include a WGS genome to run CollectWgsMetrics

is_10X=$(echo $RECIPE | grep "10X_Genomics_")
if [[ -z ${is_10X} ]]; then
  echo "Non-10X Recipe: ${RECIPE}. Skipping"
else
  echo "Detected 10X Recipe: ${RECIPE}"
  case $RECIPE in
  *GeneExpression)
    # 10X_Genomics_NextGEM-GeneExpression
    # 10X_Genomics_NextGem_GeneExpression-5
    # 10X_Genomics_NextGEM_GeneExpression-5
    # 10X_Genomics_GeneExpression
    # 10X_Genomics_GeneExpression-3
    # 10X_Genomics_GeneExpression-5

    # TODO
    echo "Processing GeneExpression";;
    # /igo/work/bin/cellranger-6.0.0/cellranger count \
    #  --id=CH-02-T1-LD_IGO_11891_1 \
    #  --transcriptome=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-GRCh38-2020-A \
    #  --fastqs=/igo/work/FASTQ/DIANA_0335_AH5F3FDRXY/Project_11891/Sample_CH-02-T1-LD_IGO_11891_1,/igo/work/FASTQ/DIANA_0341_AH5MT7DRXY/Project_11891/Sample_CH-02-T1-LD_IGO_11891_1 \
    #  --nopreflight \
    #  --jobmode=lsf \
    #  --mempercore=64 \
    #  --disable-ui \
    #  --maxjobs=200
  *VDJ)
    # 10X_Genomics_NextGem_VDJ
    # 10X_Genomics_NextGEM_VDJ
    # 10X_Genomics_NextGEM-VDJ
    # 10X_Genomics_VDJ
    # 10X_Genomics-VDJ

    # TODO
    echo "Processing VDJ";;
  10X_Genomics_Visium)
    # 10X_Genomics_Visium

    # TODO
    echo "Processing Visium";;
  10X_Genomics_ATAC)
    # 10X_Genomics_ATAC

    # TODO
    echo "Processing ATAC";;
  *)
    # TODO
    # 10X_Genomics-Expression+VDJ
    # 10X_Genomics-FeatureBarcoding
    # 10X_Genomics_NextGEM-FB
    # 10X_Genomics_NextGEM_FeatureBarcoding

    echo "Processing Other";;
  esac
fi

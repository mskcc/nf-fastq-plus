#!/bin/bash

FASTQS=""

print_usage() {
  echo "./ppg_smp.sh -s [SAMPLE_NAME] [FASTQ]..."
  printf "\t./ppg_smp.sh -f smp_r1.fq -f smp_r2.fq -s smp\n"
}

while getopts 'f:s:' flag; do
  case "${flag}" in
    s) SAMPLE="${OPTARG}" ;;
    f) FASTQS="${OPTARG} ${FASTQS}" ;;     # Reference to create liftover file for, e.g. GRCh37
    *) print_usage
       exit 1 ;;
  esac
done

if [[ -z ${FASTQS} ]]; then
  echo "Please provide FASTQ input"
  print_usage
  exit 1
fi
for fastq in ${FASTQS}; do
  if [[ ! -f ${fastq} ]]; then
    echo "Invalid FASTQ: ${f}"
    print_usage
    exit 1
  fi
done

if [[ -z ${SAMPLE} ]]; then
  echo "Please provide a sample name"
  print_usage
  exit 1
fi

REF=/igo/work/nabors/tools/bwamem2/ref/gr37.fasta
OUT=$(pwd)
echo "SAMPLE_NAME=${SAMPLE} FASTQS=${FASTQS} REF=${REF}"

echo "Aligning (bwa_mem)..."
CMD="/igo/work/nabors/tools/bwamem2/bwa_mem2.pl -fragment 10 -reference ${REF} -threads 32 -map_threads 32 -sample ${SAMPLE} -outdir ${OUT} ${FASTQS} >> ${SAMPLE}_align.out 2>&1"
echo ${CMD}
eval ${CMD}
if [[ $? != 0 ]]; then
  printf "\t...FAILED\n"
  exit 1
else
  printf "\t...done.\n"
fi

BAM=$(find ${OUT} -type f -name "${SAMPLE}*.bam")
echo "BAM=${BAM}"

echo "Collecting Alignment Summary..."
java -Dpicard.useLegacyParser=false -jar /igo/home/igo/resources/picard2.23.8/picard.jar CollectAlignmentSummaryMetrics \
  --INPUT ${BAM} \
  --OUTPUT ${SAMPLE}___AM.txt \
  --REFERENCE_SEQUENCE ${REF} \
  --METRIC_ACCUMULATION_LEVEL null \
  --METRIC_ACCUMULATION_LEVEL SAMPLE >> ${SAMPLE}_am.out 2>&1
if [[ $? != 0 ]]; then
  printf "\t...FAILED\n"
else
  printf "\t...done.\n"
fi

echo "Collecting WGS Metrics..."
java -Dpicard.useLegacyParser=false -jar /igo/home/igo/resources/picard2.23.8/picard.jar CollectWgsMetrics \
  --INPUT ${BAM} \
  --OUTPUT ${SAMPLE}___WGS.txt \
  --REFERENCE_SEQUENCE ${REF} >> ${SAMPLE}_wgs.out 2>&1
if [[ $? != 0 ]]; then
  printf "\t...FAILED\n"
else
  printf "\t...done.\n"
fi

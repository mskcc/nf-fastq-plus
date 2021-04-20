#!/bin/bash

LOCATION=$(realpath $(dirname "$0"))
cd ${LOCATION}

# Write the directories
SAMPLE_DIR=${LOCATION}/FASTQ/ROSALIND_0001_AGTCTGAGTC/Project_12878_NA/Sample_U0a
mkdir -p ${SAMPLE_DIR}
cd ${SAMPLE_DIR}

echo "Downloading FASTQs to ${SAMPLE_DIR}: U0a_CGATGT_L001_R1_001.fastq.gz, U0a_CGATGT_L001_R2_001.fastq.gz"
wget -c ftp://ftp-trace.ncbi.nih.gov/ReferenceSamples/giab/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/131219_D00360_005_BH814YADXX/Project_RM8398/Sample_U0a/U0a_CGATGT_L001_R2_001.fastq.gz
wget -c ftp://ftp-trace.ncbi.nih.gov/ReferenceSamples/giab/data/NA12878/NIST_NA12878_HG001_HiSeq_300x/131219_D00360_005_BH814YADXX/Project_RM8398/Sample_U0a/U0a_CGATGT_L001_R1_001.fastq.gz

echo "Subsampling"
seqtk sample -s100 U0a_CGATGT_L001_R1_001.fastq.gz 500 > U0a_CGATGT_L001_R1_001_subsample.fastq.gz
rm U0a_CGATGT_L001_R1_001.fastq.gz

seqtk sample -s100 U0a_CGATGT_L001_R2_001.fastq.gz 500 > U0a_CGATGT_L001_R2_001_subsample.fastq.gz
rm U0a_CGATGT_L001_R2_001.fastq.gz

cd -

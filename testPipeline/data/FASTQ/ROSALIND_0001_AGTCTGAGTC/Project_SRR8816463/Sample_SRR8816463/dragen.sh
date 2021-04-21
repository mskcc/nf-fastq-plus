#!/bin/bash

/opt/edico/bin/dragen \
  -r /staging/ref/GRCh38_rna \
  -1 SRR8816463_downsample_s500_1.fastq.gz \
  -2 SRR8816463_downsample_s500_2.fastq.gz \
  --output-directory /igo/work/streidd/test_rna \
  --output-file-prefix SRR8816463 \
  --enable-rna true \
  --RGID SRR8816463 \
  --RGSM SRR8816463

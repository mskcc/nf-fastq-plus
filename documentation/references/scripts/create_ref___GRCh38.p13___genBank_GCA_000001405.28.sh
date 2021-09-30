#!/bin/bash

/opt/edico/bin/dragen --build-hash-table true \
  --ht-reference /igo/work/genomes/H.sapiens/GRCh38.p13/ncbi-genomes-2021-09-23/GCF_000001405.39_GRCh38.p13_genomic.fna \
  --output-directory /staging/ref/GRCh38.p13___genBank_GCA_000001405.28 >> log___create_ref___GRCh38.p13___genBank_GCA_000001405.28.out

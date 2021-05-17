# Image w/ bwa & picard binaries
FROM broadinstitute/genomes-in-the-cloud:2.3.1-1512499786

# Add the script that can be run as an entrypoint
COPY e2e/samplesheet_stats_main_test.sh /nf-fastq-plus/testPipeline/e2e/samplesheet_stats_main_test.sh

# Test script uses mock data at testPipeline/data (not needed if mounting nf-fastq-plus when running container)
COPY data .

# Install cellranger - places binary in /usr/gitc/cellranger-6.0.1/bin
RUN wget -O cellranger-6.0.1.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-6.0.1.tar.gz?Expires=1621307248&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci02LjAuMS50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MjEzMDcyNDh9fX1dfQ__&Signature=RJQMY0OGFrKBopyBTkkn~k4Hh5MJxTBRuqbzq5MQ7KAenx4SAGmJs-gfp0-7jeAboYjIVDWIDhggfneTWdnU5ufj3LLiImhAzyVngxDyuMCs4LGvwnZgr9gAFdR6C662ZlVdyacHsyJ0si-QESp6RPcYGxIhC2VpZzj0eT-3cSA3IjkqrwkRXojTcbf1UHG-s~qCDLqA5VdVI01xgJ8WZa5HlJcjmhO7j2BbqXGqdB2-FKPru8RS~sSS6w1u9Y9m6EHlJe3izI9v0PO0gyex1txbyWkdq2LUNPVy0blXZ0ue0tF0CVAnDjjw4Nsg-eQ9y9dDWCtFoq8NNWuKAnDwjQ__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" && \
  tar -zxvf cellranger-6.0.1.tar.gz

# Install nextflow
RUN wget -qO- https://get.nextflow.io | bash

# Add all executables, most importantly nextflow, to the path
ENV PATH=$PATH:/usr/gitc

# Get around not having "mail" command. This will just output to stdout
RUN ln -s /bin/echo /bin/mail

# Add Genome reference used by Human Whole Genome & IDT
RUN wget https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh37_latest/refseq_identifiers/GRCh37_latest_genomic.fna.gz && \
  gunzip GRCh37_latest_genomic.fna.gz && \
  mkdir -p /igo/work/genomes/H.sapiens/GRCh37/ && \
  mv GRCh37_latest_genomic.fna /igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta

# Setup directories of nextflow.config
RUN mkdir -p /home/igo/log/nf_fasltq_plus && \
  mkdir -p /home/igo/log/nf_fastq_plus && \
  mkdir -p /home/igo/log/nf_fastq_plus && \
  mkdir -p /igo/stats/DONE && \
  mkdir -p /home/igo/nextflow/crosscheck_metrics && \
  touch /home/igo/log/nf_fasltq_plus/nf_fastq_run.log && \
  touch /home/igo/log/nf_fastq_plus/commands.log && \
  touch /home/igo/log/nf_fastq_plus/bcl2fastq.log

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/nf-fastq-plus/testPipeline/e2e/samplesheet_stats_main_test.sh", "HWG"]

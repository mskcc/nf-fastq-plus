# Container image that runs your code
FROM broadinstitute/genomes-in-the-cloud:2.3.1-1512499786

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY e2e/samplesheet_stats_main_test.sh /nf-fastq-plus/testPipeline/e2e/samplesheet_stats_main_test.sh
COPY data .

# Install nextflow
RUN wget -qO- https://get.nextflow.io | bash

# Add all executables to the path
ENV PATH=$PATH:/usr/gitc

# Add executables
RUN mkdir -p /opt/common/CentOS_7/bwa/bwa-0.7.17 && \
  mkdir -p /home/igo/resources/picard2.21.8/ && \
  ln -s /usr/gitc/bwa /opt/common/CentOS_7/bwa/bwa-0.7.17/bwa && \
  ln -s /usr/gitc/picard.jar /home/igo/resources/picard2.21.8/picard.jar

# Add Genome reference
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

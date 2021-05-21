# Image w/ bwa & picard binaries
FROM broadinstitute/genomes-in-the-cloud:2.3.1-1512499786

# Add Genome reference used by Human Whole Genome & IDT
RUN wget https://cf.10xgenomics.com/supp/cell-dna/refdata-GRCh37-1.0.0.tar.gz

RUN /bin/tar -zxvf refdata-GRCh37-1.0.0.tar.gz refdata-GRCh37-1.0.0/fasta/ --exclude=genome.fa.flat

RUN mkdir -p /igo/work/genomes/H.sapiens/GRCh37 && \
  cd refdata-GRCh37-1.0.0/fasta && \
  FILES=$(find . -type f -name "genome.fa*") && \
  for f in $FILES; do mv $f /igo/work/genomes/H.sapiens/GRCh37/${f/genome.fa/GRCh37.fasta}; done

# Add the script that can be run as an entrypoint
COPY e2e/samplesheet_stats_main_test.sh /nf-fastq-plus/testPipeline/e2e/samplesheet_stats_main_test.sh

# Test script uses mock data at testPipeline/data (not needed if mounting nf-fastq-plus when running container)
COPY data .

# Install some utilities (needed to install bcl2fastq)
RUN apt-get -y install rpm cpio

# https://github.com/litd/docker-cellranger/blob/master/Dockerfile
# Install bcl2fastq to /usr/local/bin/
RUN cd / && \
	wget http://regmedsrv1.wustl.edu/Public_SPACE/litd/Public_html/pkg/bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm && \
	rpm2cpio bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm  | cpio -idmv && \
	rm -rf bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm

# Install cellranger
RUN cd /usr/gitc && \
	wget http://regmedsrv1.wustl.edu/Public_SPACE/litd/Public_html/pkg/cellranger-6.0.0.tar.gz && \
	tar -xzvf cellranger-6.0.0.tar.gz && \
	rm -f cellranger-6.0.0.tar.gz

# Install nextflow
RUN wget -qO- https://get.nextflow.io | bash

# Add all executables, most importantly nextflow, to the path
ENV PATH=$PATH:/usr/gitc

# Get around not having "mail" command. This will just output to stdout
RUN ln -s /bin/echo /bin/mail

# Setup directories of nextflow.config
RUN mkdir -p /home/igo/log/nf_fasltq_plus && \
  mkdir -p /home/igo/log/nf_fastq_plus && \
  mkdir -p /home/igo/log/nf_fastq_plus && \
  mkdir -p /igo/stats/DONE && \
  mkdir -p /home/igo/nextflow/crosscheck_metrics && \
  touch /home/igo/log/nf_fasltq_plus/nf_fastq_run.log && \
  touch /home/igo/log/nf_fastq_plus/commands.log && \
  touch /home/igo/log/nf_fastq_plus/bcl2fastq.log

FROM centos:7

# Add Genome reference
RUN curl https://cf.10xgenomics.com/supp/cell-dna/refdata-GRCh37-1.0.0.tar.gz > refdata-GRCh37-1.0.0.tar.gz && \
  /bin/tar -xvf refdata-GRCh37-1.0.0.tar.gz refdata-GRCh37-1.0.0/fasta/ --exclude=genome.fa.flat --exclude=genome.fa.bwt && \
  rm refdata-GRCh37-1.0.0.tar.gz

# Move all the reference files to the location expected by nextflow.config
RUN mkdir -p /igo/work/genomes/H.sapiens/GRCh37 && \
  cd refdata-GRCh37-1.0.0/fasta && \
  FILES=$(find . -type f -name "genome.fa*") && \
  for f in $FILES; do mv $f /igo/work/genomes/H.sapiens/GRCh37/${f/genome.fa/GRCh37.fasta}; done

# Install utilities needed for bcl2fastq
RUN yum -y install rpm cpio

# gc-bias requires R ("R is not installed on this machine. It is required for creating the chart.")
RUN yum -y install epel-release R
RUN yum -y install R

# Install bcl2fastq to /usr/local/bin/ (Ref - https://github.com/litd/docker-cellranger/blob/master/Dockerfile)
RUN cd / && \
  curl http://regmedsrv1.wustl.edu/Public_SPACE/litd/Public_html/pkg/bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm > bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm && \
  rpm2cpio bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm  | cpio -idmv && \
  rm -rf bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm

# cellranger & picard will go here
RUN mkdir -p /usr/local/bioinformatics

# Install cellranger binary to /usr/local/bioinformatics/cellranger-6.0.0/bin/cellranger
RUN cd /usr/local/bioinformatics && \
  curl http://regmedsrv1.wustl.edu/Public_SPACE/litd/Public_html/pkg/cellranger-6.0.0.tar.gz > cellranger-6.0.0.tar.gz && \
  tar -xzvf cellranger-6.0.0.tar.gz && \
  rm -f cellranger-6.0.0.tar.gz

# Add cellranger binary to PATH
ENV PATH="/usr/local/bioinformatics/cellranger-6.0.0/bin:${PATH}"

RUN yum -y install java-1.8.0-openjdk-devel git
ENV JAVA_HOME=/usr/lib/jvm/java-openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN git clone https://github.com/broadinstitute/picard.git && \
  cd picard && \
  ./gradlew shadowJar && \
  mv build/libs/picard.jar /usr/local/bioinformatics && \
  rm -rf picard

# Install nextflow
RUN cd /usr/local/bin && curl -s https://get.nextflow.io | bash

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



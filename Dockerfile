FROM centos:7

# Add Genome reference (Important for this to be first so it can be downloaded w/ most space available)
RUN mkdir -p /igo/work/genomes/H.sapiens/GRCh37 && cd /igo/work/genomes/H.sapiens/GRCh37 && \
  curl https://cf.10xgenomics.com/supp/cell-dna/refdata-GRCh37-1.0.0.tar.gz > refdata-GRCh37-1.0.0.tar.gz && \
  /bin/tar -xvf refdata-GRCh37-1.0.0.tar.gz refdata-GRCh37-1.0.0/fasta/ --exclude=genome.fa.flat --exclude=genome.fa.pac --strip-components 2 && \
  cd /igo/work/genomes/H.sapiens/GRCh37 && \
  FILES=$(find . -type f -name "genome.fa*") && \
  for f in $FILES; do mv $f ${f/genome.fa/GRCh37.fasta}; done && \
  /bin/tar -xvf refdata-GRCh37-1.0.0.tar.gz refdata-GRCh37-1.0.0/fasta/genome.fa.pac --strip-components 2 && \
  rm refdata-GRCh37-1.0.0.tar.gz && \
  mv genome.fa.pac GRCh37.fasta.pac

# Install utilities needed for bcl2fastq
RUN yum -y install rpm cpio

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
RUN yum -y install java-1.8.0-openjdk-devel git
ENV JAVA_HOME=/usr/lib/jvm/java-openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Picard's CollectGcBiasMetrics requires R ("R is not installed on this machine. It is required for creating the chart.")
RUN yum -y install epel-release
RUN yum -y install R

# Install Picard
RUN git clone https://github.com/broadinstitute/picard.git && \
  cd picard && \
  ./gradlew shadowJar && \
  mv build/libs/picard.jar /usr/local/bioinformatics && \
  rm -rf picard

RUN curl http://springdale.princeton.edu/data/springdale/7/x86_64/os/RPM-GPG-KEY-springdale > /etc/pki/rpm-gpg/RPM-GPG-KEY-springdale

# Installs YUM repo needed to install BWA (REF - https://springdale.math.ias.edu/wiki/YumRepositories7)
RUN echo "[computational-core]" > /etc/yum.repos.d/springdale.computational.repo && \
  echo "name=Springdale computational Base \$releasever - \$basearch" >> /etc/yum.repos.d/springdale.computational.repo && \
  echo "#baseurl=file:///springdale/computational/\$releasever/\$basearch" >> /etc/yum.repos.d/springdale.computational.repo && \
  echo "#mirrorlist=http://mirror.math.princeton.edu/pub/springdale/puias/computational/\$releasever/\$basearch/mirrorlist" >> /etc/yum.repos.d/springdale.computational.repo && \
  echo "baseurl=http://springdale.princeton.edu/data/springdale/computational/\$releasever/\$basearch" >> /etc/yum.repos.d/springdale.computational.repo && \
  echo "gpgcheck=1" >> /etc/yum.repos.d/springdale.computational.repo && \
  echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-springdale" >> /etc/yum.repos.d/springdale.computational.repo

# Installs to /usr/bin/bwa
RUN yum -y install bwa

# Install nextflow (Should be to directory in PATH)
RUN cd /usr/local/bin && curl -s https://get.nextflow.io | bash

# Download python libraries needed by /bin *.py scripts
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py  -o get-pip.py && \
  python get-pip.py && \
  pip install requests && \
  pip install pandas

# Installs bzip2 to unzip samtools
RUN yum -y install samtools

# Get around not having "mail" command. This will just output to stdout
RUN ln -s /bin/echo /bin/mail

# Setup remaining directories of nextflow.config
RUN mkdir -p /home/igo/log/nf_fasltq_plus && \
  mkdir -p /home/igo/log/nf_fastq_plus && \
  mkdir -p /home/igo/log/nf_fastq_plus && \
  mkdir -p /igo/staging/stats && \
  mkdir -p /igo/stats/DONE && \
  mkdir -p /home/igo/nextflow/crosscheck_metrics && \
  mkdir -p /pskis34/LIMS/LIMS_SampleSheets && \
  mkdir -p /igo/staging/BAM

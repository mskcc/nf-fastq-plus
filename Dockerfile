FROM centos:7

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

# Install utilities needed for bcl2fastq
RUN yum -y install rpm cpio

# Install bcl2fastq to /usr/local/bin/ (Ref - https://github.com/litd/docker-cellranger/blob/master/Dockerfile)
RUN cd / && \
  curl http://regmedsrv1.wustl.edu/Public_SPACE/litd/Public_html/pkg/bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm > bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm && \
  rpm2cpio bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm  | cpio -idmv && \
  rm -rf bcl2fastq2-v2.20.0.422-Linux-x86_64.rpm

# Installs samtools
RUN yum -y install samtools

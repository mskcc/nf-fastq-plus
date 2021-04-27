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
  mkdir -p /igo/work/nabors/tools/cellranger-atac-1.2.0/cellranger-atac-cs/1.2.0/bin/ && \
  ln -s /usr/gitc/bwa /opt/common/CentOS_7/bwa/bwa-0.7.17/bwa && \
  ln -s /usr/gitc/picard.jar /home/igo/resources/picard2.21.8/picard.jar && \
  touch /igo/work/nabors/tools/cellranger-atac-1.2.0/cellranger-atac-cs/1.2.0/bin/cellranger-atac
  # TODO - Add cellranger

# Add Genome reference
RUN wget https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh37_latest/refseq_identifiers/GRCh37_latest_genomic.fna.gz && \
  gunzip GRCh37_latest_genomic.fna.gz && \
  mv GRCh37_latest_genomic.fna /igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta && \
  ln -s /igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta /igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa

# Setup dummy supporting reference files
RUN mkdir -p /igo/work/nabors/bed_files/GRCh37_RNA_Ensembl && \
  mkdir -p /igo/work/genomes/H.sapiens/GRCh37/ && \
  mkdir -p /igo/home/igo/resources/ilist/IDT_Exome_v2_FP_Viral_Probes/ && \
  echo "@HD	VN:1.4	SO:coordinate" > /igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.rRNA.interval_list && \
  touch /igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/refFlat_ensembl.v75.txt && \
  echo "@HD	VN:1.6	SO:coordinate" > /igo/home/igo/resources/ilist/IDT_Exome_v2_FP_Viral_Probes/IDT_Exome_v2_FP_b37_targets.intervalList && \
  echo "@HD	VN:1.6	SO:coordinate" > /igo/home/igo/resources/ilist/IDT_Exome_v2_FP_Viral_Probes/IDT_Exome_v2_FP_b37_baits.intervalList

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

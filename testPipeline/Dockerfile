FROM centos:7

# Add Genome reference
RUN curl https://cf.10xgenomics.com/supp/cell-dna/refdata-GRCh37-1.0.0.tar.gz > refdata-GRCh37-1.0.0.tar.gz

RUN /bin/tar -zxvf refdata-GRCh37-1.0.0.tar.gz refdata-GRCh37-1.0.0/fasta/ --exclude=genome.fa.flat && \
  rm refdata-GRCh37-1.0.0.tar.gz

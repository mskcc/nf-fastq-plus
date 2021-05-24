FROM centos:7

# Add Genome reference (Important for this to be first so it can be downloaded w/ most space available)
RUN mkdir -p /igo/work/genomes/H.sapiens/GRCh37 && cd /igo/work/genomes/H.sapiens/GRCh37 && \
  curl https://cf.10xgenomics.com/supp/cell-dna/refdata-GRCh37-1.0.0.tar.gz > refdata-GRCh37-1.0.0.tar.gz && \
  FILES="genome.fa genome.fa.fai genome.fa.bwt genome.fa.pac genome.fa.ann genome.fa.amb genome.fa.sa" && \
  for f in $FILES; do /bin/tar -xvf refdata-GRCh37-1.0.0.tar.gz refdata-GRCh37-1.0.0/fasta/$f --strip-components 2 && gzip $f && mv $f.gz ${f/genome.fa/GRCh37.fasta}.gz; done && \
  rm refdata-GRCh37-1.0.0.tar.gz && \
  gunzip *

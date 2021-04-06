FROM ubuntu:20.04

# for easy upgrade later. ARG variables only persist during image build time
ARG mashtreeVer="1.2.0"
ARG mashVer="2.2"
ARG quicktreeVer="2.5"

# install dependencies
RUN apt-get update && \
    apt-get -y install perl build-essential sqlite3 libsqlite3-dev libjson-perl \
    make wget cpanminus libexpat1-dev liblwp-protocol-https-perl libnet-ssleay-perl

# install perl modules
RUN cpanm --force --notest BioPerl \
 Bio::Perl \
 Bio::DB::GenBank \
 LWP::Protocol::https \
 IO::Socket::SSL \
 Bio::Sketch::Mash \
 Bio::Kmer \
 DBD::SQLite \
 DBI \
 File::Which

# install mash
RUN wget https://github.com/marbl/Mash/releases/download/v${mashVer}/mash-Linux64-v${mashVer}.tar && \
  tar -xf mash-Linux64-v${mashVer}.tar && \
  rm -rf mash-Linux64-v${mashVer}.tar

# install quicktree
RUN wget https://github.com/khowe/quicktree/archive/v${quicktreeVer}.tar.gz && \
  tar -xzf v${quicktreeVer}.tar.gz && \
  rm -rf v${quicktreeVer}.tar.gz && \
  cd quicktree-${quicktreeVer} && \
  make quicktree

# add mash and quicktree to the path to allow mashtree to pass tests
ENV PATH="${PATH}:/mash-Linux64-v${mashVer}:\
/quicktree-${quicktreeVer}"

# install mashtree
RUN wget https://github.com/lskatz/mashtree/archive/v${mashtreeVer}.tar.gz && \
  tar -xzf v${mashtreeVer}.tar.gz && \
  rm -rf v${mashtreeVer}.tar.gz && \
  cd mashtree-${mashtreeVer}/ && \
  perl Makefile.PL && \
  mkdir /data

# set PATH to include mashtree. LC_ALL for singularity compatibility
ENV PATH="${PATH}:/mashtree-${mashtreeVer}/bin"\
 LC_ALL=C

WORKDIR /data

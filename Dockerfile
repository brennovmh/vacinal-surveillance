FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    gzip \
    ca-certificates \
    python3 \
    python3-pip \
    openjdk-17-jre-headless \
    build-essential \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    autoconf \
    automake \
    make \
    gcc \
    git \
    fastqc \
    samtools \
    bwa \
    python3-yaml \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir multiqc

RUN cd /tmp && \
    wget https://github.com/OpenGene/fastp/releases/download/v0.23.4/fastp && \
    chmod +x fastp && \
    mv fastp /usr/local/bin/fastp

RUN cd /tmp && \
    wget https://github.com/samtools/bcftools/releases/download/1.20/bcftools-1.20.tar.bz2 && \
    tar -xjf bcftools-1.20.tar.bz2 && \
    cd bcftools-1.20 && \
    ./configure && \
    make && \
    make install

WORKDIR /workspace

CMD ["bash"]

FROM ubuntu:20.04

env foo=bar

RUN apt update
RUN apt install -y \
bcftools \
minimap2 \
python3-pip \
libbz2-dev \
liblzma-dev \
wget
RUN wget -c https://repo.anaconda.com/archive/Anaconda3-2023.07-2-Linux-x86_64.sh | bash

# RUN pip install -v --retries --exists-action i 10000000 NanoPlot
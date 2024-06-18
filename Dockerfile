# Use the official Ubuntu image as the base image
FROM ubuntu:20.04

# Set environment variable to avoid user interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install the required packages, including Git and wget
RUN apt-get update && \
    apt install -y \
        build-essential \
        libpcap-dev \
        libpcre3-dev \
        iproute2 \
        libnet1-dev \
        zlib1g-dev \
        luajit \
        hwloc \
        libdumbnet-dev \
        liblzma-dev \
        openssl \
        libssl-dev \
        pkg-config \
        libhwloc-dev \
        cmake \
        libsqlite3-dev \
        uuid-dev \
        libcmocka-dev \
        libnetfilter-queue-dev \
        libmnl-dev \
        autotools-dev \
        libluajit-5.1-dev \
        libunwind-dev \
        libfl-dev \
        git \
        nano \
        wget && \
    # Clean up APT when done to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone the libdaq repository and build it
RUN git clone https://github.com/snort3/libdaq.git && \
    cd libdaq && \
    ./bootstrap && \
    ./configure && \
    make && \
    make install

# Download and install gperftools
RUN cd /root && \
    wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz && \
    tar xzf gperftools-2.9.1.tar.gz && \
    cd gperftools-2.9.1 && \
    ./configure && \
    make && \
    make install

# Download and install Snort3
RUN cd /root && \
    wget https://github.com/snort3/snort3/archive/refs/tags/3.1.43.0.tar.gz && \
    tar -xvzf 3.1.43.0.tar.gz && \
    cd snort3-3.1.43.0 && \
    ./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc && \
    cd build && \
    make && \
    make install && \
    ldconfig

# Set up Snort configuration directory
RUN mkdir -p /usr/local/etc/snort && \
    mkdir -p /usr/local/etc/rules && \
    mkdir -p /var/log/snort && \
    mkdir -p /usr/local/lib/snort_dynamicrules && \
    touch /usr/local/etc/snort/snort.lua && \
    touch /usr/local/etc/snort/snort_defaults.lua

# Download and extract Snort community rules
RUN cd /root && \
    wget https://www.snort.org/downloads/community/snort3-community-rules.tar.gz && \
    tar -xvzf snort3-community-rules.tar.gz && \
    cp -r snort3-community-rules/* /usr/local/etc/rules/
COPY ./snort.lua /usr/local/etc/snort/
COPY ./local.rules /usr/local/etc/rules/ 
    #Run Snort on eth0
RUN snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/rules/local.rules -i eth0 -A alert_fast -s 65535 -k none
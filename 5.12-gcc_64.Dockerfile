# Docker container to build Qt 5.12 for Linux 64-bits projects with SDL and linuxdeployqt
# Image: a12e/docker-qt:5.12-gcc_64

FROM ubuntu:16.04
MAINTAINER Aurélien Brooke <dev@abrooke.fr>

ARG QT_VERSION=5.12.2
ARG SDL_VERSION=2.0.9

ENV DEBIAN_FRONTEND=noninteractive \
    QMAKESPEC=linux-g++ \
    QT_PATH=/opt/qt \
    QT_PLATFORM=gcc_64

ENV \
    PATH=${QT_PATH}/${QT_VERSION}/${QT_PLATFORM}/bin:$PATH

# Install updates & requirements:
#  * git, openssh-client, ca-certificates - clone & build
#  * locales, sudo - useful to set utf-8 locale & sudo usage
#  * curl - to download Qt bundle
#  * build-essential, pkg-config, libgl1-mesa-dev - basic Qt build requirements
#  * libsm6, libice6, libxext6, libxrender1, libfontconfig1, libdbus-1-3 - dependencies of the Qt bundle run-file
#  * wget - another download utility
#  * fuse, file - linuxdeployqt dependencies
RUN apt update && apt full-upgrade -y && apt install -y --no-install-recommends \
    git \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
    build-essential \
    pkg-config \
    libgl1-mesa-dev \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libfontconfig1 \
    libdbus-1-3 \
    libssl-dev \
    wget \
    fuse \
    file \
    libxkbcommon-x11-0 \
    && apt-get -qq clean

COPY 3rdparty/* /tmp/build/

# Download & unpack Qt toolchain
COPY scripts/install-qt.sh /tmp/build/
RUN /tmp/build/install-qt.sh

# Download, build & install SDL
COPY scripts/install-sdl.sh /tmp/build/
RUN /tmp/build/install-sdl.sh

# Download & install linuxdeployqt
COPY scripts/install-linuxdeployqt.sh /tmp/build/
RUN /tmp/build/install-linuxdeployqt.sh

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales \
# Add group & user
    && groupadd -r user && useradd --create-home --gid user user && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

USER user
WORKDIR /home/user
ENV HOME /home/user

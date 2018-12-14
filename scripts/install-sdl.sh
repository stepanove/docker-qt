#!/bin/bash
# Download and compile SDL for Linux, because the one available in Ubuntu 16.04 is too old
# Based on https://wiki.libsdl.org/Installation
# Companion script for the Docker image a12e/docker-qt
# Aurélien Brooke - License: MIT

if [ -z "$SDL_VERSION" ]; then
    echo "Please define the SDL_VERSION environment variable as desired"
    exit 1
fi

set -e #quit on error

# Install automatically SDL2 dependencies based on the Ubuntu package
echo "deb-src http://archive.ubuntu.com/ubuntu/ xenial universe" >> /etc/apt/sources.list
apt-get update
apt-get build-dep -y --no-install-recommends libsdl2
apt-get -qq clean

wget https://libsdl.org/release/SDL2-$SDL_VERSION.tar.gz
tar xzvf SDL2-$SDL_VERSION.tar.gz
cd SDL2-$SDL_VERSION/
mkdir build
cd build
../configure \
--prefix=/usr \
--enable-shared \
--enable-joystick \
--disable-static \
--disable-audio \
--disable-video \
--disable-render \
--disable-haptic \
--disable-sensor \
--disable-power \
--disable-loadso

make -j$(nproc)
make install

cd ../../
rm -rf SDL2-$SDL_VERSION

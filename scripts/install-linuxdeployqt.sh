#!/bin/bash
# Download and install linuxdeployqt
# Companion script for the Docker image a12e/docker-qt
# Aurélien Brooke - License: MIT

set -e #quit on error 

mkdir -p /usr/local/bin
curl -Lo/usr/local/bin/linuxdeployqt "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
chmod a+x /usr/local/bin/linuxdeployqt

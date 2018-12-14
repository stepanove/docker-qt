#!/bin/bash
# Download and unpack the Android SDK
# Companion script for the Docker image a12e/docker-qt
# Aurélien Brooke - License: MIT

if [ -z "$SDK_PLATFORM" ]; then
    echo "Please define the SDK_PLATFORM environment variable as desired"
    exit 1
fi

if [ -z "$SDK_BUILD_TOOLS" ]; then
    echo "Please define the SDK_BUILD_TOOLS environment variable as desired"
    exit 1
fi

if [ -z "$SDK_PACKAGES" ]; then
    echo "Please define the SDK_PACKAGES environment variable as desired"
    exit 1
fi

set -e #quit on error

curl -Lo /tmp/sdk-tools.zip 'https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip'
unzip -q /tmp/sdk-tools.zip -d ${ANDROID_SDK_ROOT}
rm -fv /tmp/sdk-tools.zip
yes | sdkmanager --licenses
sdkmanager --update
sdkmanager --verbose "platforms;${SDK_PLATFORM}" "build-tools;${SDK_BUILD_TOOLS}" ${SDK_PACKAGES}

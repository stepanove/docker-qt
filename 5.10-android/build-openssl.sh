#!/bin/bash
# Download and compile OpenSSL for Android in ~/openssl
# Based on http://doc.qt.io/qt-5/opensslsupport.html
# Companion script for the Docker image a12e/docker-qt
# Aurélien Brooke - License: MIT

if [ -z "$OPENSSL_VERSION" ]; then
    echo "Please define the OPENSSL_VERSION environment variable as desired"
    exit 1
fi

set -e #quit on error

cd ~/
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
tar xvf openssl-${OPENSSL_VERSION}.tar.gz
mv openssl-${OPENSSL_VERSION}/ openssl/
cd openssl/

wget https://wiki.openssl.org/images/7/70/Setenv-android.sh
perl -pi -e 's/\r\n/\n/g' Setenv-android.sh

patch Setenv-android.sh <<'EOF'
--- Setenv-android.sh.1 2018-04-15 09:40:03.189896022 +0000
+++ Setenv-android.sh   2018-04-15 08:19:41.642098789 +0000
@@ -15,14 +15,14 @@
 # try to pick it up with the value of _ANDROID_NDK_ROOT below. If
 # ANDROID_NDK_ROOT is set, then the value is ignored.
 # _ANDROID_NDK="android-ndk-r8e"
-_ANDROID_NDK="android-ndk-r9"
+#_ANDROID_NDK="android-ndk-r9"
 # _ANDROID_NDK="android-ndk-r10"
 
 # Set _ANDROID_EABI to the EABI you want to use. You can find the
 # list in $ANDROID_NDK_ROOT/toolchains. This value is always used.
 # _ANDROID_EABI="x86-4.6"
 # _ANDROID_EABI="arm-linux-androideabi-4.6"
-_ANDROID_EABI="arm-linux-androideabi-4.8"
+_ANDROID_EABI="$ANDROID_NDK_TOOLCHAIN_PREFIX-$ANDROID_NDK_TOOLCHAIN_VERSION"
 
 # Set _ANDROID_ARCH to the architecture you are building for.
 # This value is always used.
@@ -36,7 +36,7 @@
 # Android 5.0, there will likely be another platform added (android-22?).
 # This value is always used.
 # _ANDROID_API="android-14"
-_ANDROID_API="android-18"
+_ANDROID_API=$ANDROID_NDK_PLATFORM
 # _ANDROID_API="android-19"
 
 #####################################################################
EOF

source Setenv-android.sh

./config shared \
--prefix=$(pwd)/out \
--sysroot=$ANDROID_NDK_SYSROOT \
-I$ANDROID_NDK_ROOT/sysroot/usr/include \
-I$ANDROID_NDK_ROOT/sysroot/usr/include/$ANDROID_NDK_TOOLCHAIN_PREFIX \
-I$ANDROID_NDK_ROOT/sources/cxx-stl/gnu-libstdc++/$ANDROID_NDK_TOOLCHAIN_VERSION/include \
-I$ANDROID_NDK_ROOT/sources/cxx-stl/gnu-libstdc++/$ANDROID_NDK_TOOLCHAIN_VERSION/libs/armeabi-v7a/include

make -j$(nproc) CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs

ls -alh ~/openssl/*.so ~/openssl/*.a

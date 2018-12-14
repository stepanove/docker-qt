#!/bin/bash
# Download and compile OpenSSL for Android, and install it directly in the Android NDK development files 
# Based on http://doc.qt.io/qt-5/opensslsupport.html
# Companion script for the Docker image a12e/docker-qt
# Aurélien Brooke - License: MIT

if [ -z "$OPENSSL_VERSION" ]; then
    echo "Please define the OPENSSL_VERSION environment variable as desired"
    exit 1
fi

if [ -z "$ANDROID_DEV" ]; then
    echo "Please define the ANDROID_DEV environment variable as desired"
    exit 1
fi

if [ -z "$ANDROID_NDK_ROOT" ]; then
    echo "Please define the ANDROID_NDK_ROOT environment variable as desired"
    exit 1
fi

if [ -z "$ANDROID_NDK_TOOLCHAIN" ]; then
    echo "Please define the ANDROID_NDK_TOOLCHAIN environment variable as desired"
    exit 1
fi

if [ -z "$CLANG_TARGET" ]; then
    echo "Please define the CLANG_TARGET environment variable as desired"
    exit 1
fi

set -e #quit on error

cd ~/
curl -Lo openssl-${OPENSSL_VERSION}.tar.gz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
tar xvf openssl-${OPENSSL_VERSION}.tar.gz
mv openssl-${OPENSSL_VERSION}/ openssl/
cd openssl/

# openssl doesn't have a arm64_v8a+clang target, only an "android-armv7"+gcc for armv7a.
# so we hack the cflags of the target "android-armv7"
# this is VERY ugly but works (tm)
patch Configure <<'EOF'
--- Configure.ori       2018-11-20 14:44:48.000000000 +0100
+++ Configure   2018-12-12 14:42:42.261952355 +0100
@@ -475,4 +475,5 @@
-"android-x86","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
-"android-armv7","gcc:-march=armv7-a -mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${armv4_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
+"android-arch-x86","clang:-I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -target \$(CLANG_TARGET) -gcc-toolchain \$(ANDROID_NDK_TOOLCHAIN) -DANDROID_HAS_WSTRING --sysroot=\$(ANDROID_NDK_ROOT)/sysroot -isystem \$(ANDROID_NDK_ROOT)/sysroot/usr/include/\$(ANDROID_NDK_TOOLCHAIN_PREFIX) -isystem \$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/include -isystem \$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++abi/include -fstack-protector-strong -Wall::-D_REENTRANT::-Wl,--exclude-libs,libgcc.a -lz -lm -ldl -lc -L\$(ANDROID_DEV)/lib:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:".eval{my $asm=${x86_elf_asm};$asm=~s/:elf/:android/;$asm}.":dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
+"android-arch-arm","clang:-I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -target \$(CLANG_TARGET) -gcc-toolchain \$(ANDROID_NDK_TOOLCHAIN) -DANDROID_HAS_WSTRING --sysroot=\$(ANDROID_NDK_ROOT)/sysroot -isystem \$(ANDROID_NDK_ROOT)/sysroot/usr/include/\$(ANDROID_NDK_TOOLCHAIN_PREFIX) -isystem \$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/include -isystem \$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++abi/include -fstack-protector-strong -Wall::-D_REENTRANT::-Wl,--exclude-libs,libgcc.a -lz -lm -ldl -lc -L\$(ANDROID_DEV)/lib:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${armv4_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
+"android-arch-arm64","clang:-I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -fomit-frame-pointer -target \$(CLANG_TARGET) -gcc-toolchain \$(ANDROID_NDK_TOOLCHAIN) -DANDROID_HAS_WSTRING --sysroot=\$(ANDROID_NDK_ROOT)/sysroot -isystem \$(ANDROID_NDK_ROOT)/sysroot/usr/include/\$(ANDROID_NDK_TOOLCHAIN_PREFIX) -isystem \$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/include -isystem \$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++abi/include -fstack-protector-strong -Wall::-D_REENTRANT::-Wl,--exclude-libs,libgcc.a -lz -lm -ldl -lc -L\$(ANDROID_DEV)/lib:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${aarch64_asm}:linux64:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
 "android-mips","gcc:-mandroid -I\$(ANDROID_DEV)/include -B\$(ANDROID_DEV)/lib -O3 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${mips32_asm}:o32:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
EOF

./Configure shared zlib --prefix=${ANDROID_DEV} android-${ANDROID_NDK_ARCH}
make -j$(nproc) depend
make -j$(nproc) CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" build_libs
# we didn't build the "openssl" binary (error of stdout and stderr not found when linking) so we fake the file so that the install_sw step doesn't fail
touch apps/openssl
# the following is to PREVENT the install script from creating links, instead of properly copying the .so files (what is this???)
mkdir -p ${ANDROID_DEV}/lib
echo "place-holder make target for avoiding symlinks" >> ${ANDROID_DEV}/lib/link-shared
make -j$(nproc) SHLIB_EXT=.so install_sw
rm -fv ${ANDROID_DEV}/lib/link-shared

ls -alh ${ANDROID_DEV}/lib

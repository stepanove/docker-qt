These Docker images allow you to very easily build a Qt app accross all platforms. You may use build system (e.g. Gitlab CI) to fully leverage these images.

Qt toolchain Docker images
==========================

Qt 5.9.7 LTS
* `a12e/docker-qt:5.9-android_armv7` (Platform 21, NDK r17c [gcc], OpenSSL 1.0.2q)
* `a12e/docker-qt:5.9-gcc_64` (Ubuntu 16.04 LTS, SDL 2.0.9, linuxdeployqt)

Qt 5.10.1
* `a12e/docker-qt:5.10-android_armv7` (Platform 21, NDK r17c [gcc], OpenSSL 1.0.2q)
* `a12e/docker-qt:5.10-gcc_64` (Ubuntu 16.04 LTS, SDL 2.0.9, linuxdeployqt)

Qt 5.12.0 LTS
* `a12e/docker-qt:5.12-android_armv7` (Platform 21, NDK r18b [clang], OpenSSL 1.0.2q)
* `a12e/docker-qt:5.12-android_arm64_v8a` (Platform 21, NDK r18b [clang], OpenSSL 1.0.2q)
* `a12e/docker-qt:5.12-android_x86` (Platform 21, NDK r18b [clang], OpenSSL 1.0.2q)
* `a12e/docker-qt:5.12-gcc_64` (Ubuntu 16.04 LTS, SDL 2.0.9, linuxdeployqt)

Android example
---------------

`docker run -it --rm a12e/docker-qt:5.12-android_armv7`
and/or 
`docker run -it --rm a12e/docker-qt:5.12-android_arm64_v8a`
and/or 
`docker run -it --rm a12e/docker-qt:5.12-android_x86`

```sh
# Clone repo with source
git clone --recursive <repo> ~/src
# Make build dir & cd into
mkdir ~/build && cd ~/build
# Run qmake, optional: ship the OpenSSL libraries
qmake -r ~/src ANDROID_EXTRA_LIBS+=$ANDROID_DEV/lib/libcrypto.so ANDROID_EXTRA_LIBS+=$ANDROID_DEV/lib/libssl.so
# Run make
make
# Run make install 
make install INSTALL_ROOT=$HOME/dist
# Create APK
androiddeployqt --input android-libMyAppName.so-deployment-settings.json --output dist/ --android-platform $SDK_PLATFORM --deployment bundled --gradle --release
```

Linux example
-------------

`docker run -it --rm a12e/docker-qt:5.12-gcc_64`

```sh
# Install required specific dependencies:
sudo apt-get -qq update && sudo apt-get install -qq -y libssl-dev
# Clone repo with source
git clone --recursive <repo> ~/src
# Make build dir & cd into
mkdir ~/build && cd ~/build
# Run qmake
qmake -r ~/src
# Run make
make
# Run make install 
make install INSTALL_ROOT=$HOME/appdir
# Prepare AppImage, deploy libs
linuxdeployqt appdir/usr/share/applications/*.desktop -bundle-non-qt-libs -qmldir=~/src/resources/ -extra-plugins=iconengines
# Optional: copy other files needed in the AppImage
mkdir -p appdir/usr/share/my-app/files/ && cp -v needed.file appdir/usr/share/my-app/files/
# Build the AppImage
linuxdeployqt appdir/usr/share/applications/*.desktop -appimage
```

Notes
-----

OpenSSL for Android is compiled and installed directly in `${ANDROID_DEV}`, and is platform-specific (API 21 in most cases). You can compile against it transparently, but you need to ship the libraries for run time. Look at `ANDROID_EXTRA_LIBS`.

Linux images are built inside a 16.04 LTS Ubuntu and not 18.04 LTS, to allow the AppImage's to be run on older systems. Otherwise, links to too recent versions of GLIBC are made.

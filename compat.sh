#!/bin/sh

set -e

VERSION="$1"
BUILD_DIR="builds/sdk/${VERSION}-compat"

flatpak remote-add --user winepak-local winepak-local --no-gpg-verify --if-not-exists

flatpak -y install --user winepak-local --arch=i386 --reinstall "runtime/org.winepak.Platform//${VERSION}"

rm -rf ${BUILD_DIR}
flatpak build-init ${BUILD_DIR} org.winepak.Platform.Compat.i386 org.winepak.Platform/i386 org.winepak.Platform/i386 --type=extension --writable-sdk "${VERSION}"

flatpak build-finish --sdk="org.winepak.Sdk/x86_64/${VERSION}" --runtime="org.winepak.Platform/x86_64/${VERSION}" --metadata=ExtensionOf=ref="runtime/org.winepak.Platform/x86_64/${VERSION}" ${BUILD_DIR}

flatpak build-export winepak-local ${BUILD_DIR} --files=usr/lib/i386-linux-gnu --arch=x86_64 "${VERSION}"


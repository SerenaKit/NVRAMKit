#!/bin/zsh

# Script for generating release of macOS executable and iOS Deb
PkgVer=$(cat layout/DEBIAN/control | grep Version | sed 's/Version: //')
make package DEBUG=0 FINALPACKAGE=1
DebLocatedAt=./packages/com.serena.nvramutil_${PkgVer}_iphoneos-arm.deb
mv ${DebLocatedAt} ./
DebLocatedAt=./com.serena.nvramutil_${PkgVer}_iphoneos-arm.deb
swift build -c release
macOSExecLocatedAt=.build/x86_64-apple-macosx/release/NVRAMUtil

mkdir macOS
mv ${macOSExecLocatedAt} ./
macOSExecLocatedAt=./NVRAMUtil
mv ${macOSExecLocatedAt} macOS
zip -r -X NVRAMUtil-${PkgVer}.zip ${DebLocatedAt} macOS
rm -rf ${DebLocatedAt} macOS

#!/bin/bash

set -e

export VERSION=`git tag -l --contains HEAD | egrep '^v[0-9]+\.[0-9]+\.[0-9]+.*' | cut -c 2-`

if [ -z "$VERSION" ]; then
   echo "No version tag found"
   exit 1
fi

export ADDONVERSION=`perl -e 'my ($v1, $v2, $v3) = split /\./, substr($ARGV[0], 1); $v = $v1*10000 + $v2 * 100 + $v3; printf "%d", $v;' $VERSION`

echo "Version: $VERSION"

rm -rf _build/Navigator
mkdir -p _build/Navigator

cp *.lua *.txt *.xml _build/Navigator
cp -r media _build/Navigator/media
cp -r lang _build/Navigator/lang

cd _build

sed -i "s/## Version: .*/## Version: $VERSION/g" Navigator/Navigator.txt
sed -i "s/## AddOnVersion: .*/## Version: $ADDONVERSION/g" Navigator/Navigator.txt
sed -i "s/  appVersion = ".*",/  appVersion = \"$VERSION\",/g" Navigator/Navigator.lua

zip -r "Navigator-v$VERSION.zip" Navigator

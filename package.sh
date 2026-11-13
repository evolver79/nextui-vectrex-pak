#!/bin/sh
# Builds dist/VECTREX.pak.zip with the pak's files at the top of the zip (the layout Pak Store expects).
# For a manual install, unzip it into a new folder: SD card Emus/tg5040/VECTREX.pak/.
set -e
cd "$(dirname "$0")"
[ -f VECTREX.pak/vecx_libretro.so ] || { echo "Run ./build-core.sh first"; exit 1; }
cp LICENSE-vecx VECTREX.pak/
mkdir -p dist
rm -f dist/VECTREX.pak.zip
(cd VECTREX.pak && zip -q -X ../dist/VECTREX.pak.zip launch.sh default.cfg vecx_libretro.so LICENSE-vecx)
rm VECTREX.pak/LICENSE-vecx
unzip -l dist/VECTREX.pak.zip

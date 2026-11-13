#!/bin/sh
# Builds VECTREX.pak/vecx_libretro.so from libretro-vecx in an ARM64 Debian bullseye container:
# software rendering only (no libGL) and RGB565 output (patches/vecx-rgb565.patch). Needs Docker.
set -e
cd "$(dirname "$0")"
VECX_COMMIT=dccff5402a16d1ea7c112095a8e42632bf149506
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
git clone -q https://github.com/libretro/libretro-vecx.git "$work/vecx"
git -C "$work/vecx" checkout -q "$VECX_COMMIT"
git -C "$work/vecx" apply "$PWD/patches/vecx-rgb565.patch"
docker build -q -t nextui-vectrex-build - >/dev/null <<'DOCKERFILE'
FROM --platform=linux/arm64 debian:bullseye
RUN printf '%s\n' "deb http://archive.debian.org/debian bullseye main" \
      "deb http://archive.debian.org/debian bullseye-updates main" \
      "deb http://archive.debian.org/debian-security bullseye-security main" > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends gcc libc6-dev make binutils git ca-certificates \
 && git config --global --add safe.directory '*'
DOCKERFILE
docker run --rm --platform linux/arm64 -v "$work/vecx:/src" -w /src nextui-vectrex-build \
  sh -c 'make -f Makefile.libretro HAS_GPU=0 -j4 >/dev/null && strip vecx_libretro.so'
cp "$work/vecx/vecx_libretro.so" VECTREX.pak/
file VECTREX.pak/vecx_libretro.so
shasum -a 256 VECTREX.pak/vecx_libretro.so

#!/bin/bash
#
# Build a portable KeeperFX AppImage.
#
# Must be run inside an Ubuntu 24.04 environment (glibc 2.39, ffmpeg 6.1), the toolchain
# upstream's Linux CI uses. The engine needs GCC 13+, so older bases do not build it.
# Run from the repository root, e.g. in CI:
#   docker run --rm -v "$PWD":/src -w /src ubuntu:24.04 bash dist/linux/build-appimage.sh /src/dist/out
#
# The resulting AppImage bundles the engine, all libraries (incl. SDL3, which CMake builds
# from source because Ubuntu 24.04 does not package it) and the freely-redistributable
# KeeperFX data. It NEVER contains the original Dungeon Keeper files (copyright
# EA/Bullfrog) - the user supplies those at runtime.
#
# Usage: dist/linux/build-appimage.sh [OUTPUT_DIR]
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
export APPIMAGE_EXTRACT_AND_RUN=1   # run the tool AppImages without FUSE (works in containers)

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
OUT_DIR="${1:-$REPO/dist/out}"
WORK=/tmp/kfx-appimage
# Official KeeperFX release whose binary assets we bundle (graphics, sound). Text data and
# language files come from this tree, so they always match the engine.
KFX_DATA_VERSION="${KFX_DATA_VERSION:-1.4.0}"
KFX_DATA_SHA256="${KFX_DATA_SHA256:-82d9d5634e8ea6cabb8f62fbd4830b758919893863cd313517af256a3040a279}"
mkdir -p "$OUT_DIR" "$WORK"
cd "$REPO"

echo "######## 1. build dependencies ########"
apt-get update -qq
apt-get install -y -qq build-essential cmake ninja-build git pkg-config \
  p7zip-full curl ca-certificates file wget squashfs-tools patchelf zsync \
  libavformat-dev libavcodec-dev libavutil-dev libswresample-dev \
  libopenal-dev libluajit-5.1-dev libspng-dev libminizip-dev \
  libssl-dev libzstd-dev libminiupnpc-dev libnatpmp-dev zlib1g-dev \
  libwayland-dev wayland-protocols libxkbcommon-dev libdecor-0-dev \
  libx11-dev libxext-dev libxcursor-dev libxi-dev libxrandr-dev libxfixes-dev \
  libxss-dev libxtst-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
  libdrm-dev libgbm-dev libdbus-1-dev libudev-dev libpulse-dev libasound2-dev \
  libpipewire-0.3-dev libibus-1.0-dev libpng-dev libjpeg-dev libogg-dev \
  libvorbis-dev libflac-dev libmpg123-dev libopusfile-dev >/dev/null
echo "glibc: $(ldd --version | head -1) | ffmpeg: $(pkg-config --modversion libavcodec)"

echo "######## 2. build engine (CMake, SDL3 from source) ########"
git config --global --add safe.directory '*' || true
cmake -S . -B "$WORK/build" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo >/dev/null
cmake --build "$WORK/build" --target keeperfx
file "$WORK/build/keeperfx"

echo "######## 3. AppDir skeleton ########"
APPDIR="$WORK/AppDir"
SHARE="$APPDIR/usr/share/keeperfx"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$SHARE" \
         "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/256x256/apps"
cp "$WORK/build/keeperfx" "$APPDIR/usr/bin/keeperfx"

echo "######## 4. free data (official release; already free of the 16 copyright files) ########"
DATA_7Z="keeperfx_${KFX_DATA_VERSION//./_}_complete.7z"
curl -fLso "$WORK/$DATA_7Z" \
  "https://github.com/dkfans/keeperfx/releases/download/v${KFX_DATA_VERSION}/${DATA_7Z}"
echo "$KFX_DATA_SHA256  $WORK/$DATA_7Z" | sha256sum -c -
rm -rf "$WORK/fxdata"
mkdir -p "$WORK/fxdata" && (cd "$WORK/fxdata" && 7z x -y "$WORK/$DATA_7Z" >/dev/null)
for d in data fxdata ldata levels sound campgns creatrs mods music multiplayer; do
  [ -d "$WORK/fxdata/$d" ] && cp -r "$WORK/fxdata/$d" "$SHARE/"
done
mkdir -p "$SHARE/save"

echo "######## 5. text data + language files from this tree (laid out like package.mk) ########"
cp -r config/creatrs config/fxdata config/mods "$SHARE/"
cp config/keeperfx.cfg "$SHARE/keeperfx.cfg"
cp -r campgns multiplayer "$SHARE/"
( cd levels && find . -type f \( -name '*.cfg' -o -name '*.txt' -o -name '*.toml' \) \
    ! -name readme.txt ! -name personal.cfg ) | while IFS= read -r f; do
  install -Dm644 "levels/$f" "$SHARE/levels/$f"
done
bash dist/linux/build-lang-data.sh "$SHARE"

echo "######## 6. icon + desktop ########"
ICON="$(ls res/keeperfx_icon256-*bpp.png | tail -1)"
cp "$ICON" "$APPDIR/usr/share/icons/hicolor/256x256/apps/keeperfx.png"
cp "$ICON" "$APPDIR/keeperfx.png"
cp dist/linux/keeperfx.desktop "$APPDIR/usr/share/applications/keeperfx.desktop"

echo "######## 7. bundle libraries (linuxdeploy) ########"
cd "$WORK"
wget -qN https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage
LD_LIBRARY_PATH="$(dirname "$(find "$WORK/build" -name 'libSDL3.so.0' | head -1)"):$(dirname "$(find "$WORK/build" -name 'libSDL3_image.so.0' | head -1)"):$(dirname "$(find "$WORK/build" -name 'libSDL3_mixer.so.0' | head -1)")" \
./linuxdeploy-x86_64.AppImage --appdir "$APPDIR" \
  -e "$APPDIR/usr/bin/keeperfx" \
  -d "$APPDIR/usr/share/applications/keeperfx.desktop" \
  -i "$APPDIR/keeperfx.png" 2>&1 | tail -15

echo "######## 8. custom AppRun (data setup; original DK files supplied by the user) ########"
rm -f "$APPDIR/AppRun"   # linuxdeploy leaves a symlink -> usr/bin/keeperfx; replace with ours
cp "$REPO/dist/linux/AppRun" "$APPDIR/AppRun"
chmod +x "$APPDIR/AppRun"

echo "######## 9. appimagetool ########"
VER="$(grep -E '^VER_MAJOR=' "$REPO/version.mk" | cut -d= -f2).$(grep -E '^VER_MINOR=' "$REPO/version.mk" | cut -d= -f2).$(grep -E '^VER_RELEASE=' "$REPO/version.mk" | cut -d= -f2)"
REV="r$(git -C "$REPO" rev-list --count HEAD).g$(git -C "$REPO" rev-parse --short=9 HEAD)"
wget -qN https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
OUT_FILE="$OUT_DIR/KeeperFX-${VER}.${REV}-linux-x86_64.AppImage"
ARCH=x86_64 ./appimagetool-x86_64.AppImage "$APPDIR" "$OUT_FILE" 2>&1 | tail -10
chmod -R a+rwX "$OUT_DIR" || true
echo "######## DONE ########"
ls -la "$OUT_FILE"

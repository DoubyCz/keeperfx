#!/bin/bash
#
# Compile the language .po/.pot files of this tree into the .dat files the engine reads.
# The .dat files in a release archive are indexed by the engine's string enum, so an engine
# newer than the release loses every string added since. pkg_lang.mk lists the files
# upstream packages; po2ngdat is built at the version prebuilds.mk pins.
#
# Usage: dist/linux/build-lang-data.sh OUTPUT_DIR   (run from the repository root)
set -euo pipefail

OUT="$1"
TAG="$(grep -m1 -oE 'po2ngdat/releases/download/[^/]+' prebuilds.mk | cut -d/ -f4)"
TOOL="$(mktemp -d)"
git clone -q --depth 1 -b "$TAG" https://github.com/dkfans/po2ngdat.git "$TOOL"
make -C "$TOOL" >/dev/null

grep -oE 'pkg/[a-z0-9_/]+\.dat' pkg_lang.mk | sort -u | while IFS= read -r dat; do
  dat=${dat#pkg/}
  po=lang/${dat#fxdata/}; po=${po%.dat}.po
  [ -f "$po" ] || po+=t
  case $dat in
    *_jpn.dat)           tbl=jp ;;
    *_rus.dat|*_ukr.dat) tbl=ru ;;
    *_chi.dat|*_cht.dat) tbl=ch ;;
    *_kor.dat)           tbl=kr ;;
    *)                   tbl=eu ;;
  esac
  mkdir -p "$OUT/${dat%/*}"
  "$TOOL/bin/po2ngdat" -o "$OUT/$dat" -e "$TOOL/res/char_encoding_tbl_$tbl.txt" "$po" >/dev/null
done
rm -rf "$TOOL"

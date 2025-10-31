#!/usr/bin/env bash
# https://docs.romm.app/latest/Tools/Igir-Collection-Manager/#initial-setup-steps
# https://igir.io/usage/desktop/romm/

set -ou pipefail

INPUT_DIR="$1"
OUTPUT_DIR="$2"

cd $INPUT_DIR

# dats
# https://datomatic.no-intro.org/index.php?page=download&op=daily&s=64
# - Select P/C then Request
#
# http://redump.org/downloads/

# Documentation: https://igir.io/
# Uses dat files: https://datomatic.no-intro.org/index.php?page=download&op=daily
time igir \
  move \
  zip \
  report \
  test \
  -d dats/ \
  -i "${INPUT_DIR}/" \
  -o "${OUTPUT_DIR}/{romm}/" \
  --input-checksum-quick false \
  --input-checksum-min CRC32 \
  --input-checksum-max SHA256 \
  --only-retail

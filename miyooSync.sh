#!/usr/bin/env bash
unraid_games=/mnt/unraid-games

# Check if $unraid_games mountpoint is working
if [ ! -d "$unraid_games" ] || [ ! -d "$unraid_games/romimport" ] || [ ! -d "$unraid_games/roms" ] || [ ! -d "$unraid_games/saves" ]; then
  echo "Error: unraid-games mountpoint is not available."
  echo "Please check your mounts and try again."
  exit 1
fi

# Check if we are really on the MinUI SD card
if [ ! -d "./Bios" ] || [ ! -d "./Roms" ] || [ ! -d "./Saves" ] || [ ! -d "./Tools" ]; then
  echo "Error: This script must be run from the root of the MinUI SD card."
  echo "Please mount the MinUI SD card and try again."
  exit 1
fi

saves() {
  echo ""
  echo "--> Backing up saves"
  rsync -rLi --update --delete ./Saves/ $unraid_games/saves/miyoo/
}

roms() {
  echo ""
  echo "--> Copying roms to Miyoo Mini Plus"
  igir copy extract test clean \
    --dat $unraid_games/romimport/dats/No-Intro*.zip \
    --dat-name-regex-exclude "/encrypted|source code|headerless|MSX/i" \
    --input $unraid_games/roms/No-Intro/ \
    --output "./roms/{minui}" \
    --dir-letter \
    --dat-threads 1 \
    --no-bios \
    --overwrite-invalid \
    --only-retail \
    --single \
    --prefer-language EN \
    --prefer-region USA,WORLD,EUR,JPN \
    --prefer-retail \
    --prefer-parent
}

usage() {
  # Display Help
  echo "Sync ROMs and saves from my Miyoo Mini Plus with my unraid shares."
  echo "Using no flags will will first sync saves then roms."
  echo
  echo "Syntax: romSync [--roms | --saves | --help]"
  echo
}

### Main ###
if [ "$1" = "" ]; then
  saves
  roms
else
  while [ "$1" != "" ]; do
  case $1 in
    -r | --roms ) shift
                  roms
                  ;;
    -s | --saves) shift
                  saves
                  ;;
    -h | --help ) usage
                  exit
                  ;;
    * )           usage
                  exit 1
  esac
  shift
done
fi

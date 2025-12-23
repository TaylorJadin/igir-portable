#!/usr/bin/env bash
unraid_games=/mnt/unraid-games

# Check if $unraid_games mountpoint is working
if [ ! -d "$unraid_games" ] || [ ! -d "$unraid_games/romimport" ] || [ ! -d "$unraid_games/roms" ] || [ ! -d "$unraid_games/saves" ]; then
  echo "Error: unraid-games mountpoint is not available."
  echo "Please check your mounts and try again."
  exit 1
fi

# Check if we are really on the Pocket SD card
if [ ! -d "./Assets" ] || [ ! -d "./Cores" ] || [ ! -d "./Memories" ] || [ ! -d "./Saves" ]; then
  echo "Error: This script must be run from the root of the Pocket SD card."
  echo "Please mount the Pocket SD card and try again."
  exit 1
fi

saves() {
  echo ""
  echo "--> Backing up saves"
  rsync -rLi --times --update --delete ./Memories/ $unraid_games/saves/pocket/Memories/
  rsync -rLi --times --update --delete ./Saves/ $unraid_games/saves/pocket/Saves/
}

roms() {
  echo ""
  echo "--> Copying roms to Pocket"
  igir copy extract clean \
    --dat $unraid_games/romimport/dats/No-Intro*.zip \
    --dat-name-regex-exclude "/encrypted|source code|headerless|ByteSwapped|8-bit Family|MSX/i" \
    --input $unraid_games/roms/No-Intro/ \
    --output "./Assets/{pocket}/common/" \
    --dir-letter \
    --dir-letter-limit 1000 \
    --clean-exclude "/media/POCKET/Assets/*/common/*.*" \
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
  echo "Sync ROMs and saves from my Analogue Pocket with my unraid shares."
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
                  echo "--> Roms"
                  roms
                  echo ""
                  ;;
    -s | --saves) shift
                  echo "--> Saves"
                  saves
                  echo ""
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

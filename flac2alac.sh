#!/bin/bash

### definitions ################################################################

FLAC2ALAC_VERSION="1.0"
SOURCES=("$@")
FLAC_EXTENSION=".flac"
ALAC_EXTENSION=".m4a"

### functions ##################################################################

function print_usage() {
    echo "flac2alac version: ${FLAC2ALAC_VERSION}"
    echo "Usage: $(basename "$0") [ filename | directory]";
    cat <<'EOF'

Usage: ./flac2alac.sh [filename|directory]

Description:
    Utility for coverting flac audio files to Apple Lossless (ALAC)

Examples:
    ./flac2alac.sh song.flac
    ./flac2alac.sh track_1.flac track_2.flac track_3.flac
    ./flac2alac.sh album
EOF
}

function flac2alac() {
    local _FLAC_FILE=$1
    local _ALAC_FILE=${_FLAC_FILE/$FLAC_EXTENSION/$ALAC_EXTENSION}

    if [[ -f $_ALAC_FILE ]]; then
        echo "$_ALAC_FILE already exists. Skipping..."
        return
    fi

    if [[ $_FLAC_FILE == *.flac ]]; then
        ffmpeg -i "$_FLAC_FILE" -y -acodec alac "$_ALAC_FILE" >> ffmpeg.log 2>&1 &
    else
        echo "$_FLAC_FILE invalid file"
    fi
}

### main #######################################################################

if [[ ${#SOURCES[@]} == 0 ]]; then
    print_usage
    exit 1
fi

for SOURCE in ${SOURCES[*]};
do
    if [[ -d $SOURCE ]]; then
        FLAC_FILES=$(find $SOURCE -name "*.flac")
        for FLAC_FILE in ${FLAC_FILES[*]};
        do
            flac2alac "$FLAC_FILE"
        done
    elif [[ -f $SOURCE ]]; then
        flac2alac $SOURCE
    else
        echo "$SOURCE is not valid filename or directory"
        print_usage
        exit 1
    fi
done

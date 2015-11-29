#!/bin/bash

### version history ############################################################

# 1.1 - Added check to see if ffmpeg binary is installed
#     - Improved usage comments

### definitions ################################################################

FLAC2ALAC_VERSION="1.1"
SOURCES=("$@")
FLAC_EXTENSION="flac"
ALAC_EXTENSION="m4a"
ACODEC="alac"
LOG_FILE="flac2alac.log"


### functions ##################################################################

function print_usage(){
    echo "flac2alac version: ${FLAC2ALAC_VERSION}"
    cat <<'EOF'
Usage:

    ./flac2alac.sh [filename|directory]

Description:

    Utility for converting flac audio files to Apple Lossless (ALAC) using FFmpeg.
    Must have FFmpeg installed.

Examples:

    Convert a single flac file:
    ./flac2alac.sh song.flac

    Convert multiple flac files:
    ./flac2alac.sh track_1.flac track_2.flac track_3.flac

    Convert a folder of flac files:
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

    if [[ $_FLAC_FILE == *.${FLAC_EXTENSION} ]]; then
        ffmpeg -i "$_FLAC_FILE" -y -acodec $ACODEC "$_ALAC_FILE" >> $LOG_FILE 2>&1 &
    else
        echo "$_FLAC_FILE invalid file"
    fi
}


### main #######################################################################

# check if ffmpeg is installed
if ! type ffmpeg > /dev/null 2>&1; then
	echo "FFmpeg not found. Must have FFmpeg installed."
	exit 1;
fi

# check if any args were passed on the command line
if [[ ${#SOURCES[@]} == 0 ]]; then
    print_usage
    exit 1
fi

for SOURCE in ${SOURCES[*]};
do
    if [[ -d $SOURCE ]]; then
        FLAC_FILES=$(find $SOURCE -name "*.${FLAC_EXTENSION}")
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

#!/bin/bash

#
# Music convert script- converts music files to opus
#
# Usage: ./musicconvert.sh SOURCE_PATH DEST_PATH
# SOURCE_PATH - source directory (the one with the music files you have already)
# DEST_PATH - where you want to save the music; can be omitted
#
# If no DEST_PATH is provided, will use SOURCE_PATH
#

ORIG_PATH="${PWD}"

if [[ -z "${1}" ]]; then
  SOURCE_PATH="$(pwd)"
else
  cd "${1}" && SOURCE_PATH="${PWD}"
fi

cd "${ORIG_PATH}"

if [[ -z "${2}" ]]; then
  DEST_PATH=${SOURCE_PATH}
else
  cd "${2}" && DEST_PATH="${PWD}"
fi

cd "${ORIG_PATH}"

shopt -s nocasematch
convertmusic() {
  IFS='
'
  for f in $(ls -A1 "$1"); do
    if [[ -d "$1/$f" ]]; then
      echo "$1/$f"
      if ! [[ -d "$2/$f" ]]; then
        rm "$2/$f" 2>/dev/null
        mkdir -p "$2/$f"
      fi
      convertmusic "$1/$f" "$2/$f"
    else
      filename=$(basename "$1/$f")
      extension="${filename##*.}"
      filename="${filename%.*}"
      case "$extension" in
        "alac" | "flac" | "mp3" | "ogg" | "wav" | "m4a")
          if ! [[ -f "$2/$filename.opus" ]]; then
            ffmpeg -y -v error -nostats -i "$1/$filename.$extension" -b:a 92k -vbr on "$2/$filename.opus"
            echo "$1/$filename.$extension to $2/$filename.opus"
          fi
          ;;
        "jpeg")
          if ! [[ -f "$2/$filename.jpg" || "$1" = "$2" ]]; then
            cp "$1/$f" "$2/$filename.jpg"
            echo "$1/$filename.$extension to $2/$filename.jpg"
          fi
          ;;
        *)
          if ! [[ -f "$2/$f" || "$1" = "$2" ]]; then
            cp "$1/$f" "$2/$f"
            echo "$1/$filename.$extension to $2/$filename.$extension"
          fi
          ;;
      esac
    fi
  done
}

convertmusic $SOURCE_PATH $DEST_PATH


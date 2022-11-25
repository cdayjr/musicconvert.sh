#!/usr/bin/env zsh

#
# Music convert script- converts music files to opus
#
# Usage: ./musicconvert.sh SOURCE_PATH DEST_PATH
# SOURCE_PATH - source directory (the one with the music files you have already)
# DEST_PATH - where you want to save the music; can be omitted
#
# If no DEST_PATH is provided, will use SOURCE_PATH
#

local ORIG_PATH="${PWD}"

local SOURCE_PATH=""
if [[ -z "${1}" ]]; then
  SOURCE_PATH="$(pwd)"
else
  cd "${1}" && SOURCE_PATH="${PWD}"
fi

cd "${ORIG_PATH}"

local DEST_PATH=""
if [[ -z "${2}" ]]; then
  DEST_PATH=${SOURCE_PATH}
else
  cd "${2}" && DEST_PATH="${PWD}"
fi

cd "${ORIG_PATH}"

local CURRENT_FILE=""
on-int() {
  if [ -n "$CURRENT_FILE" ]; then
    >&2 echo "Removing incomplete transfer/conversion for: $CURRENT_FILE"
    rm "$CURRENT_FILE"
  fi
  trap - SIGINT
  kill -TERM -$$
}
trap "on-int" SIGINT

convertmusic() {
  local IFS='
'
  for FILE in $(ls -A1 "$1"); do
    CURRENT_FILE=""
    if [[ -d "$1/$FILE" ]]; then
      echo "$1/$FILE"
      if ! [[ -d "$2/$FILE" ]]; then
        rm "$2/$FILE" 2>/dev/null
        mkdir -p "$2/$FILE"
      fi
      convertmusic "$1/$FILE" "$2/$FILE"
    else
      local FILENAME=$(basename "$1/$FILE")
      local EXTENSION="${FILENAME##*.}"
      FILENAME="${FILENAME%.*}"
      case "$EXTENSION" in
        "alac" | "flac" | "mp3" | "ogg" | "wav" | "m4a")
          if ! [[ -f "$2/$FILENAME.opus" ]]; then
            CURRENT_FILE="$2/$FILENAME.opus"
            ffmpeg -y -v error -nostats -i "$1/$FILENAME.$EXTENSION" -b:a 92k -vbr on "$CURRENT_FILE"
            echo "$1/$FILENAME.$EXTENSION to $CURRENT_FILE"
          fi
          ;;
        *)
          if ! [[ -f "$2/$FILE" || "$1" = "$2" ]]; then
            CURRENT_FILE="$2/$FILE"
            cp "$1/$FILE" "$CURRENT_FILE"
            echo "$1/$FILENAME.$EXTENSION to $2/$FILENAME.$EXTENSION"
          fi
          ;;
      esac
    fi
  done
}

convertmusic $SOURCE_PATH $DEST_PATH

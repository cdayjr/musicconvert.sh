#!/usr/bin/env zsh

#
# Auto-rename
#
# Replace unicode/problematic characters in filenames automatically.
#
# Runs in the directory you run the script in
#

local safe_rename() {
  if [ -z "$1" ]; then
    return 0;
  fi
  for ITEM in "$1"/*; do
    if [ "$ITEM" = "." ]; then
      continue
    fi
    local DIRECTORY="$(dirname "$ITEM")"
    local FILTERED="$(basename "$ITEM" | uconv -x "::Latin; ::Latin-ASCII; ([^\x00-\x7F]) > ;" | sed 's/[\?\/'"'"'\"<]/_/g')"
    local NEW_LOCATION="$DIRECTORY/$FILTERED"
    if [[ "$ITEM" != "$NEW_LOCATION" ]]; then
      mv "$ITEM" "$NEW_LOCATION"
      echo Moved "$ITEM" to "$NEW_LOCATION"
    fi
    if [ -d "$NEW_LOCATION" ]; then
      safe_rename "$NEW_LOCATION"
    fi
  done
}

safe_rename .

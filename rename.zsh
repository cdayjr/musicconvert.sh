#!/usr/bin/env zsh

#
# Auto-rename
#
# Replace unicode/problematic characters in filenames automatically.
#
# Runs in the directory you run the script in
#

for ITEM in ./**/*; do \
  local FILE="$(basename $ITEM)"
	local FILTERED="$(echo $ITEM | uconv -x "::Latin; ::Latin-ASCII; ([^\x00-\x7F]) > ;" | sed 's/\?/_/g')"
	# filter the dirname when moving files since the directory will be updated
	# before this item is gotten to
  local DIRECTORY="$(dirname $FILTERED)"
	if [[ "$DIRECTORY/$FILE" != "$FILTERED" ]]; then
		mv "$DIRECTORY/$FILE" "$FILTERED"
	fi
done

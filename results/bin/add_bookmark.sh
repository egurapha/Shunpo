#!/bin/bash

# Imports.
SHUNPO_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SHUNPO_SCRIPT_DIR"/colors.sh
source "$SHUNPO_SCRIPT_DIR"/functions.sh

# File to store bookmarks.
SHUNPO_MAX_BOOKMARKS=128

# Ensure the bookmarks file exists and is not empty
if [ ! -f "$SHUNPO_BOOKMARKS_FILE" ]; then
    touch "$SHUNPO_BOOKMARKS_FILE"
fi

# Check the number of existing bookmarks.
current_bookmarks=$(wc -l <"$SHUNPO_BOOKMARKS_FILE")

# If the bookmarks list is full, print a message and do not add the new bookmark.
if [ "$current_bookmarks" -ge "$SHUNPO_MAX_BOOKMARKS" ]; then
    echo -e "${SHUNPO_CYAN}${SHUNPO_BOLD}Bookmarks list is full!${SHUNPO_RESET} Maximum of $SHUNPO_MAX_BOOKMARKS bookmarks allowed."
    exit 1
fi

# Save the current directory to the bookmarks file.
current_dir=$(realpath "$PWD")
if ! grep -q -x "$(printf '%s\n' "$current_dir")" "$SHUNPO_BOOKMARKS_FILE"; then
    echo "$current_dir" >>"$SHUNPO_BOOKMARKS_FILE"
    echo -e "${SHUNPO_GREEN}${SHUNPO_BOLD}Bookmark added:${SHUNPO_RESET} $current_dir"
else
    echo -e "${SHUNPO_ORANGE}${SHUNPO_BOLD}Bookmark exists:${SHUNPO_RESET} $current_dir"
fi

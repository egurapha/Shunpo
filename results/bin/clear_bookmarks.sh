#!/bin/bash

# Colors and formatting.
SHUNPO_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SHUNPO_SCRIPT_DIR"/colors.sh
source "$SHUNPO_SCRIPT_DIR"/functions.sh

# Remove the bookmarks file if it exists.
if [ ! -f "$SHUNPO_BOOKMARKS_FILE" ] || [ ! -s "$SHUNPO_BOOKMARKS_FILE" ]; then
    echo -e "${SHUNPO_ORANGE}${SHUNPO_BOLD}No Bookmarks Found.${SHUNPO_RESET}"
    exit 1

else
    rm "$SHUNPO_BOOKMARKS_FILE"
    echo -e "${SHUNPO_RED}${SHUNPO_BOLD}Cleared Bookmarks.${SHUNPO_RESET}"
fi

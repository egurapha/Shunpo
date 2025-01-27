#!/bin/bash

# Colors and formatting.
SHUNPO_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SHUNPO_SCRIPT_DIR/colors.sh"
source "$SHUNPO_SCRIPT_DIR/functions.sh"

function shunpo_handle_kill() {
    shunpo_clear_output
    shunpo_cleanup
    exit 1
}

trap 'shunpo_handle_kill' SIGINT

# Check if bookmarks exist.
if ! shunpo_assert_bookmarks_exist; then
    exit 1
fi

shunpo_interact_bookmarks "Remove Bookmarks" $1

# Handle case where bookmark is not set. Corresponds to return code 2.
if [ $? -eq 2 ]; then
    if declare -f shunpo_cleanup >/dev/null; then
        shunpo_cleanup
    fi
    echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}Bookmark is Empty.${SHUNPO_RESET}"
    exit 1
fi

bookmarks=()
while IFS= read -r bookmark; do
    bookmarks+=("$bookmark")
done <"$SHUNPO_BOOKMARKS_FILE"

if [[ -z $shunpo_selected_dir ]]; then
    unset shunpo_selected_dir
    exit 1

elif [[ $shunpo_selected_bookmark_index -ge 0 ]] && [[ $shunpo_selected_bookmark_index -lt ${#bookmarks[@]} ]]; then
    # Remove the selected bookmark from the file.
    awk -v dir="$shunpo_selected_dir" '$0 != dir' "$SHUNPO_BOOKMARKS_FILE" >"${SHUNPO_BOOKMARKS_FILE}.tmp" && mv "${SHUNPO_BOOKMARKS_FILE}.tmp" "$SHUNPO_BOOKMARKS_FILE"

    # Display the removed bookmark message.
    echo -e "${SHUNPO_RED}${SHUNPO_BOLD}Removed bookmark:${SHUNPO_RESET} $shunpo_selected_dir"

    # Delete the bookmarks file if it is empty.
    if [ ! -s "$SHUNPO_BOOKMARKS_FILE" ]; then
        rm -f "$SHUNPO_BOOKMARKS_FILE"
    fi
else
    exit 1
fi

shunpo_cleanup

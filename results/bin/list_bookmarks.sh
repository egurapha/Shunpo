#!/bin/bash

# Colors and formatting
SHUNPO_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SHUNPO_SCRIPT_DIR"/colors.sh
source "$SHUNPO_SCRIPT_DIR"/functions.sh

function shunpo_handle_kill() {
    shunpo_clear_output
    shunpo_cleanup
    exit 1
}

trap 'shunpo_handle_kill' SIGINT

if ! shunpo_assert_bookmarks_exist; then
    exit 1
fi

shunpo_interact_bookmarks "List Bookmarks"
shunpo_cleanup

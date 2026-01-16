#!/usr/bin/env bash

BASHRC="$HOME/.bashrc"
source "$BASHRC"

uninstall() {
    # Remove commands file.
    echo "Uninstalling..."
    SHUNPO_CMD="$SHUNPO_DIR/shunpo_cmd"
    if [ -f "$SHUNPO_CMD" ]; then
        rm "$SHUNPO_CMD"
        echo "Removed $SHUNPO_CMD"
    fi

    # Remove bookmarks file.
    SHUNPO_BOOKMARKS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/shunpo"
    SHUNPO_BOOKMARKS_FILE="$SHUNPO_BOOKMARKS_DIR/.shunpo_bookmarks"
    if [ -f "$SHUNPO_BOOKMARKS_FILE" ]; then
        rm "$SHUNPO_BOOKMARKS_FILE"
        echo "Removed $SHUNPO_BOOKMARKS_FILE"
    fi

    # Remove config file and directory.
    SHUNPO_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shunpo"
    SHUNPO_CONFIG_FILE="$SHUNPO_CONFIG_DIR/config"
    if [ -f "$SHUNPO_CONFIG_FILE" ]; then
        rm "$SHUNPO_CONFIG_FILE"
        echo "Removed $SHUNPO_CONFIG_FILE"
    fi
    if [ -d "$SHUNPO_CONFIG_DIR" ]; then
        rmdir "$SHUNPO_CONFIG_DIR" 2>/dev/null && echo "Removed $SHUNPO_CONFIG_DIR"
    fi

    # Remove scripts and directories.
    if [ -z "$SHUNPO_DIR" ]; then
        echo "No Installation Found."
        exit 1
    else
        cd "${SHUNPO_DIR}"/scripts
        rm jump_to_parent.sh
        rm jump_to_child.sh
        rm add_bookmark.sh
        rm remove_bookmark.sh
        rm go_to_bookmark.sh
        rm list_bookmarks.sh
        rm clear_bookmarks.sh
        rm functions.sh
        rm colors.sh
        cd ..
        rmdir "${SHUNPO_DIR}"/scripts
        cd ..
        rmdir "$SHUNPO_DIR"
        echo "Removed $SHUNPO_DIR"
        unset SHUNPO_DIR
    fi

    # Remove SHUNPO_CMD source in bashrc.
    temp_file=$(mktemp)
    sed '/^source .*\/shunpo_cmd$/d' "$BASHRC" >"$temp_file"
    mv "$temp_file" "$BASHRC"

    # Remove SHUNPO_DIR export in bashrc.
    temp_file=$(mktemp)
    grep -v '^export SHUNPO_DIR=' "$BASHRC" >"$temp_file"
    mv "$temp_file" "$BASHRC"
}

uninstall
echo "Done."

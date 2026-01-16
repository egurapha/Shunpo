#!/usr/bin/env bash

if [[ "$(uname)" == "Darwin" ]]; then
    SHUNPO_TEST_DIR="/private/tmp/shunpo_test"
else
    SHUNPO_TEST_DIR="/tmp/shunpo_test"
fi

function setup_env {
    HOME=${SHUNPO_TEST_DIR}/home
    mkdir -p "$HOME"
    XDG_DATA_HOME=${SHUNPO_TEST_DIR}/home/.local/share
    mkdir -p "$XDG_DATA_HOME"
    XDG_CONFIG_HOME=${SHUNPO_TEST_DIR}/home/.config
    mkdir -p "$XDG_CONFIG_HOME"
}

function cleanup_env {
    rm "$SHUNPO_TEST_DIR/home/.bashrc"
    rm "$SHUNPO_TEST_DIR/home/.bashrc$"

    if [ -d "${SHUNPO_TEST_DIR}/home" ]; then
        rmdir "${SHUNPO_TEST_DIR}/home/"
    fi

    if [ -d "${SHUNPO_TEST_DIR}" ]; then
        find "${SHUNPO_TEST_DIR}" -type d -empty -delete
        rmdir "$SHUNPO_TEST_DIR"
    fi
}

make_directories() {
    # Make directory structure.
    local depth=4
    local width=3
    for i in $(seq 1 $depth); do
        if [[ $1 -eq 1 ]]; then
            run sb >/dev/null
        fi
        mkdir -p "$i"
        if [[ $i -ne 1 ]]; then
            for j in $(seq 1 $width); do
                mkdir -p "$i.$j"
            done
        fi
        cd "$i"
    done
}

get_num_bookmarks() {
    SHUNPO_BOOKMARKS_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/shunpo/.shunpo_bookmarks"
    echo $(wc -l <"$SHUNPO_BOOKMARKS_FILE" | tr -d '[:space:]')
}

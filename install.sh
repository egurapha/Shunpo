#!/usr/bin/env bash

# Get install paths.
DEFAULT_INSTALL_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/shunpo
read -p "Enter the installation directory [default: $DEFAULT_INSTALL_DIR]: " user_input
INSTALL_DIR=${user_input:-"$DEFAULT_INSTALL_DIR"}
SCRIPT_DIR=${INSTALL_DIR}/scripts/
BASHRC="$HOME/.bashrc"

# File containing command definitions.
SHUNPO_CMD="$INSTALL_DIR/shunpo_cmd"

# Config file path.
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shunpo"
CONFIG_FILE="$CONFIG_DIR/config"

setup() {
    mkdir -p $INSTALL_DIR
    mkdir -p $SCRIPT_DIR
    if [ -f $SHUNPO_CMD ]; then
        rm $SHUNPO_CMD
    fi
    touch $SHUNPO_CMD
}

add_commands() {
    # Define command set.
    SCRIPT_DIR="$(realpath "$SCRIPT_DIR")"
    cat >"$SHUNPO_CMD" <<EOF
#!/usr/bin/env bash
sj() { source "$SCRIPT_DIR/jump_to_parent.sh" "\$@"; }
sd() { source "$SCRIPT_DIR/jump_to_child.sh"; }
sb() { "$SCRIPT_DIR/add_bookmark.sh"; }
sr() { "$SCRIPT_DIR/remove_bookmark.sh" "\$@"; }
sg() { source "$SCRIPT_DIR/go_to_bookmark.sh" "\$@"; }
sl() { "$SCRIPT_DIR/list_bookmarks.sh"; }
sc() { "$SCRIPT_DIR/clear_bookmarks.sh"; }
EOF
}

install() {
    # Store scripts in SCRIPTS_DIR.
    cp src/* $SCRIPT_DIR

    # Add sourcing for shunpo_cmd (overwrite).
    source_rc_line="source $SHUNPO_CMD"
    temp_file=$(mktemp)
    sed '/^source.*\shunpo_cmd/d' "$BASHRC" >"$temp_file"
    mv "$temp_file" "$BASHRC"
    echo "$source_rc_line" >>"$BASHRC"
    echo "Added to BASHRC: $source_rc_line"

    # Record SHUNPO_DIR for uninstallation (overwrite).
    install_dir_line="export SHUNPO_DIR=$INSTALL_DIR" >>"$BASHRC$"
    temp_file=$(mktemp)
    grep -v '^export SHUNPO_DIR=' "$BASHRC" >"$temp_file"
    mv "$temp_file" "$BASHRC"
    echo "$install_dir_line" >>"$BASHRC"
    echo "Added to BASHRC: $install_dir_line"

    add_commands

    # Create default config file if it doesn't exist.
    if [ ! -f "$CONFIG_FILE" ]; then
        mkdir -p "$CONFIG_DIR"
        cat >"$CONFIG_FILE" <<EOF
# Shunpo Configuration
# Selection keys (exactly 10 characters, one per menu item)
# Reserved keys that cannot be used: n, p, b
# Note: CLI arguments (e.g., sg 3, sj 1) always use numeric indices 0-9
SHUNPO_SELECTION_KEYS="1234567890"
EOF
        echo "Created config: $CONFIG_FILE"
    fi
}

# Install.
echo "Installing."
setup
install

echo "Done."
echo "(Remember to run source ~/.bashrc.)"

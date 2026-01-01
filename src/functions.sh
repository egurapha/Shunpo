#!/usr/bin/env bash

# Configuration Path.
SHUNPO_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shunpo"
SHUNPO_CONFIG_FILE="$SHUNPO_CONFIG_DIR/config"

# Default selection keys (can be overridden in config).
SHUNPO_SELECTION_KEYS="1234567890"

# Load and validate user configuration.
function shunpo_load_config() {
    if [ -f "$SHUNPO_CONFIG_FILE" ]; then
        local user_keys
        # Source the config to get SHUNPO_SELECTION_KEYS
        source "$SHUNPO_CONFIG_FILE"
        user_keys="$SHUNPO_SELECTION_KEYS"

        # Validate: exactly 10 characters
        if [ ${#user_keys} -ne 10 ]; then
            echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}Warning: SHUNPO_SELECTION_KEYS must be exactly 10 characters. Using defaults.${SHUNPO_RESET}"
            SHUNPO_SELECTION_KEYS="1234567890"
            return
        fi

        # Validate: no reserved keys (n, p, b)
        if [[ $user_keys == *n* ]] || [[ $user_keys == *p* ]] || [[ $user_keys == *b* ]]; then
            echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}Warning: SHUNPO_SELECTION_KEYS cannot contain 'n', 'p', or 'b'. Using defaults.${SHUNPO_RESET}"
            SHUNPO_SELECTION_KEYS="1234567890"
            return
        fi

        # Validate: no duplicate characters
        local seen=""
        for ((i = 0; i < ${#user_keys}; i++)); do
            local char="${user_keys:i:1}"
            if [[ $seen == *"$char"* ]]; then
                echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}Warning: SHUNPO_SELECTION_KEYS cannot contain duplicates. Using defaults.${SHUNPO_RESET}"
                SHUNPO_SELECTION_KEYS="1234567890"
                return
            fi
            seen+="$char"
        done

        SHUNPO_SELECTION_KEYS="$user_keys"
    fi
}

# Get the index (0-9) for a given key, or return 1 if not found.
function shunpo_get_key_index() {
    local key="$1"
    for ((i = 0; i < ${#SHUNPO_SELECTION_KEYS}; i++)); do
        if [[ ${SHUNPO_SELECTION_KEYS:i:1} == "$key" ]]; then
            echo "$i"
            return 0
        fi
    done
    return 1
}

# Load configuration on source.
shunpo_load_config

# Default Bookmarks Path.
SHUNPO_BOOKMARKS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/shunpo/"
if [ ! -d "$SHUNPO_BOOKMARKS_DIR" ]; then
    mkdir -p "$SHUNPO_BOOKMARKS_DIR"
fi

SHUNPO_BOOKMARKS_FILE="$SHUNPO_BOOKMARKS_DIR/.shunpo_bookmarks"

# Function to display bookmarks with pagination.
function shunpo_interact_bookmarks() {
    local bookmarks=()
    local total_bookmarks
    local current_page=0
    local max_per_page=10
    local last_page
    local start_index
    local end_index
    local padding_lines

    tput civis

    # Read bookmarks into an array.
    while IFS= read -r bookmark; do
        bookmarks+=("$bookmark")
    done <"$SHUNPO_BOOKMARKS_FILE"

    # Check that bookmarks file is not empty.
    total_bookmarks=${#bookmarks[@]}
    if [ "$total_bookmarks" -eq 0 ]; then
        echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}No Bookmarks Found.${SHUNPO_RESET}"
        return 0
    fi

    # If a selection is specified, select it.
    if [ -n "$2" ]; then
        if ! [[ $2 =~ ^[0-9]+$ ]]; then
            echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}Invalid Bookmark Selection.${SHUNPO_RESET}"
            return 1
        else
            if [[ $2 -lt $total_bookmarks ]]; then
                shunpo_selected_dir="${bookmarks[$2]}"
                tput cnorm
                return 0
            else
                tput cnorm
                return 2
            fi
        fi
    fi

    last_page=$(((total_bookmarks + max_per_page - 1) / max_per_page))

    # Pagination loop.
    while true; do
        # Calculate the start and end indices for the current page.
        start_index=$((current_page * max_per_page))
        end_index=$((start_index + max_per_page))
        if [ "$end_index" -gt "$total_bookmarks" ]; then
            end_index=$total_bookmarks
        fi

        # Pad the bottom of the terminal to avoid erroneous printing.
        if [ "$max_per_page" -lt "$total_bookmarks" ]; then
            padding_lines=$max_per_page
        else
            padding_lines=$total_bookmarks
        fi

        if [ $last_page -gt 1 ]; then
            padding_lines=$((padding_lines + 1)) # page numbers.
        fi

        padding_lines=$((padding_lines + 1)) # header.
        shunpo_add_space $padding_lines

        tput sc
        echo -e "${SHUNPO_BOLD}${SHUNPO_CYAN}Shunpo <$1>${SHUNPO_RESET}"

        # Display bookmarks for the current page.
        for ((i = start_index; i < end_index; i++)); do
            echo -e "[${SHUNPO_BOLD}${SHUNPO_ORANGE}${SHUNPO_SELECTION_KEYS:$((i - start_index)):1}${SHUNPO_RESET}] ${bookmarks[i]}"
        done

        if [ $last_page -gt 1 ]; then
            echo -e "${SHUNPO_CYAN}[$((current_page + 1)) / $((last_page))]${SHUNPO_RESET}"
        fi

        # Read input to select bookmarks and cycle through pages.
        read -rsn1 input
        if [[ $input == "n" ]]; then
            if [ $((current_page + 1)) -le $((last_page - 1)) ]; then
                current_page=$((current_page + 1))
            fi
            shunpo_clear_output

        elif [[ $input == "p" ]]; then
            if [ $((current_page - 1)) -ge 0 ]; then
                current_page=$((current_page - 1))
            fi
            shunpo_clear_output

        elif key_index=$(shunpo_get_key_index "$input"); then
            # Process bookmark selection input.
            shunpo_selected_bookmark_index=$((current_page * max_per_page + key_index))
            if [[ $shunpo_selected_bookmark_index -lt $total_bookmarks ]]; then
                shunpo_selected_dir="${bookmarks[$shunpo_selected_bookmark_index]}"
                shunpo_clear_output
                tput cnorm
                return 0
            else
                shunpo_clear_output
            fi
        else
            shunpo_clear_output
            tput cnorm
            return 0
        fi
    done
    shunpo_clear_output
    tput cnorm
    return 0
}

function shunpo_jump_to_parent_dir() {
    local current_dir=$(pwd)
    local max_levels=128
    local parent_dirs=()
    local total_parents
    local current_page=0
    local max_per_page=10
    local last_page
    local start_index
    local end_index
    local padding_lines

    tput civis

    # Collect all parent directories.
    while [ "$current_dir" != "/" ] && [ "${#parent_dirs[@]}" -lt "$max_levels" ]; do
        parent_dirs+=("$current_dir")
        current_dir=$(dirname "$current_dir")
    done

    parent_dirs+=("/") # Add root.

    # Check if we are at the root.
    if [[ ${#parent_dirs[@]} -eq 1 && ${parent_dirs[0]} == "/" ]]; then
        echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}No Parent Directories.${SHUNPO_RESET}"
        return 1
    fi

    total_parents=${#parent_dirs[@]}

    # If a selection is specified, select it.
    if [ -n "$1" ]; then
        if ! [[ $1 =~ ^[0-9]+$ ]]; then
            echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}Invalid Parent Selection.${SHUNPO_RESET}"
            return 1
        else
            if [[ $1 -lt $total_parents ]]; then
                cd "${parent_dirs[$1]}" || exit
                tput cnorm
                echo -e "${SHUNPO_GREEN}${SHUNPO_BOLD}Changed to:${SHUNPO_RESET} ${parent_dirs[$1]}"
                return 0
            else
                tput cnorm
                return 2
            fi
        fi
    fi

    last_page=$(((total_parents + max_per_page - 1) / max_per_page))

    while true; do
        # Calculate start and end indices for pagination.
        start_index=$((current_page * max_per_page))
        end_index=$((start_index + max_per_page))
        if [ "$end_index" -gt "$total_parents" ]; then
            end_index=$total_parents
        fi

        # Pad the bottom of the terminal to avoid erroneous printing.
        if [ "$max_per_page" -lt "$total_parents" ]; then
            padding_lines=$max_per_page
        else
            padding_lines=$total_parents
        fi

        if [ $last_page -gt 1 ]; then
            padding_lines=$((padding_lines + 1)) # page numbers.
        fi

        padding_lines=$((padding_lines + 1)) # header.
        shunpo_add_space $padding_lines

        tput sc
        echo -e "${SHUNPO_BOLD}${SHUNPO_CYAN}Shunpo <Jump to Parent>${SHUNPO_RESET}"

        # Display the current page of parent directories.
        for ((i = start_index; i < end_index; i++)); do
            if [[ $i -eq $((end_index - 1)) && $current_page -eq $((last_page - 1)) ]]; then
                echo -e "[${SHUNPO_BOLD}${SHUNPO_ORANGE}${SHUNPO_SELECTION_KEYS:$((i - start_index)):1}${SHUNPO_RESET}] $(basename ${parent_dirs[i]})"
            else
                echo -e "[${SHUNPO_BOLD}${SHUNPO_ORANGE}${SHUNPO_SELECTION_KEYS:$((i - start_index)):1}${SHUNPO_RESET}] /$(basename ${parent_dirs[i]})"
            fi
        done

        if [ $last_page -gt 1 ]; then
            echo -e "${SHUNPO_CYAN}[$((current_page + 1)) / $last_page]${SHUNPO_RESET}"
        fi

        # Read and process user input.
        read -rsn1 input
        if [[ $input == "n" ]]; then
            if [ $((current_page + 1)) -lt "$last_page" ]; then
                current_page=$((current_page + 1))
            fi
            shunpo_clear_output

        elif [[ $input == "p" ]]; then
            if [ $((current_page - 1)) -ge 0 ]; then
                current_page=$((current_page - 1))
            fi
            shunpo_clear_output

        elif key_index=$(shunpo_get_key_index "$input"); then
            selected_index=$((start_index + key_index))
            # Skip index 0 (current directory) - only allow selecting actual parents
            if [[ $selected_index -gt 0 ]] && [[ $selected_index -lt $total_parents ]]; then
                shunpo_clear_output
                tput cnorm
                cd "${parent_dirs[$selected_index]}" || exit
                echo -e "${SHUNPO_GREEN}${SHUNPO_BOLD}Changed to:${SHUNPO_RESET} ${parent_dirs[$selected_index]}"
                return 0
            fi
            shunpo_clear_output
        else
            shunpo_clear_output
            tput cnorm
            return 0
        fi
    done
    shunpo_clear_output
    tput cnorm
    return 0
}

function shunpo_jump_to_child_dir() {
    local current_dir=$(pwd)
    local max_per_page=10
    local current_page=0
    local last_page
    local start_index
    local end_index
    local child_dirs=()
    local cache_index
    local selected_path="$current_dir" # selected path gets updated in each iteration.
    local start_dir=$(realpath "$current_dir")
    local is_start_dir=1
    local total_child_dirs
    local padding_lines

    tput civis

    # Cache previously traversed directories.
    local cache_keys=()
    local cache_values=()

    function shunpo_is_cached() {
        local path="$1"
        for i in "${!cache_keys[@]}"; do
            if [[ ${cache_keys[$i]} == "$path" ]]; then
                echo "$i"
                return 0
            fi
        done
        return 1
    }

    while true; do
        # Attempt to retrieve from cache.
        if cache_index=$(shunpo_is_cached "$selected_path"); then
            # Use cached value.
            IFS='|' read -r -a child_dirs <<<"${cache_values[$cache_index]}"
        else
            # Collect directories if not cached.
            child_dirs=()
            while IFS= read -r dir; do
                child_dirs+=("$dir")
            done < <(find "$selected_path" -maxdepth 1 -mindepth 1 -type d | sort)

            # Add to cache.
            cache_keys+=("$selected_path")
            cache_values+=("$(
                IFS='|'
                echo "${child_dirs[*]}"
            )")
        fi
        total_child_dirs=${#child_dirs[@]}

        # Determine index range to diplay.
        start_index=$((current_page * max_per_page))
        end_index=$((start_index + max_per_page))
        if [ "$end_index" -gt "$total_child_dirs" ]; then
            end_index=$total_child_dirs
        fi

        last_page=$(((total_child_dirs + max_per_page - 1) / max_per_page))

        # Pad the bottom of the terminal to avoid erroneous printing.
        if [ "$max_per_page" -lt "$total_child_dirs" ]; then
            padding_lines=$max_per_page
        else
            padding_lines=$total_child_dirs
        fi

        if [ $last_page -gt 1 ]; then
            padding_lines=$((padding_lines + 1)) # page numbers.
        fi

        padding_lines=$((padding_lines + 2)) # header and selected path.
        shunpo_add_space $padding_lines

        tput sc
        echo -e "${SHUNPO_BOLD}${SHUNPO_CYAN}Shunpo <Jump to Child>${SHUNPO_RESET}"

        # Print selected path and options.
        if [[ $is_start_dir -eq 1 ]]; then
            echo -e "Selected Path: ${SHUNPO_CYAN}$selected_path${SHUNPO_RESET} ${SHUNPO_ORANGE}(Initial)${SHUNPO_RESET}"
        else
            echo -e "Selected Path: ${SHUNPO_CYAN}$selected_path${SHUNPO_RESET}"
        fi

        if [[ $total_child_dirs -eq 0 ]]; then
            if [[ $is_start_dir -eq 1 ]]; then
                shunpo_clear_output
                echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}No Child Directories.${SHUNPO_RESET}"
                tput cnorm
                return 1
            else
                echo -e "${SHUNPO_BOLD}${SHUNPO_ORANGE}No Child Directories.${SHUNPO_RESET}"
            fi
        else
            # Print child directories.
            for ((i = start_index; i < end_index; i++)); do
                echo -e "[${SHUNPO_BOLD}${SHUNPO_ORANGE}${SHUNPO_SELECTION_KEYS:$((i - start_index)):1}${SHUNPO_RESET}] ${child_dirs[i]#$selected_path}"
            done

            if [ $last_page -gt 1 ]; then
                echo -e "${SHUNPO_CYAN}[$((current_page + 1)) / $last_page]${SHUNPO_RESET}"
            fi
        fi

        # Process input.
        read -rsn1 input
        if [[ $input == "n" ]]; then
            if [ $((current_page + 1)) -lt "$last_page" ]; then
                current_page=$((current_page + 1))
            fi
            shunpo_clear_output

        elif [[ $input == "p" ]]; then
            if [ $((current_page - 1)) -ge 0 ]; then
                current_page=$((current_page - 1))
            fi
            shunpo_clear_output

        elif [[ $input == "b" ]]; then
            if [[ $is_start_dir -eq 1 ]]; then
                shunpo_clear_output
                continue
            else
                selected_path=$(realpath "$selected_path/../")
            fi

            if [[ $selected_path == "$start_dir" ]]; then
                is_start_dir=1
            else
                is_start_dir=0
            fi
            current_page=0
            shunpo_clear_output

        elif [[ $input == "" ]]; then
            shunpo_clear_output
            if [[ $is_start_dir -ne 1 ]]; then
                cd "$selected_path" || exit
                echo -e "${SHUNPO_GREEN}${SHUNPO_BOLD}Changed to:${SHUNPO_RESET} $selected_path"
            fi
            break

        elif key_index=$(shunpo_get_key_index "$input"); then
            selected_index=$((start_index + key_index))
            if [[ $selected_index -lt $total_child_dirs ]]; then
                selected_path="${child_dirs[selected_index]}"
                is_start_dir=0
                current_page=0
            fi
            shunpo_clear_output

        else
            shunpo_clear_output
            tput cnorm
            break
        fi
    done
    tput cnorm
    return 0
}

# Function to open several lines of space before writing when near the end of the terminal
# to avoid visual issues.
function shunpo_add_space() {
    # Get total terminal lines.
    total_lines=$(tput lines)

    # Fetch the current cursor row position using ANSI escape codes.
    cursor_line=$(IFS=';' read -rsdR -p $'\033[6n' -a pos && echo "${pos[0]#*[}")

    # Calculate lines from current position to bottom.
    lines_to_bottom=$((total_lines - cursor_line))
    if [ "$lines_to_bottom" -lt "$1" ]; then
        for ((i = 0; i < $1; i++)); do
            echo
        done
        tput cuu "$1"
    fi
    tput ed
}

function shunpo_clear_output() {
    tput rc # Restore saved cursor position.
    tput ed # Clear everything below the cursor.
}

function shunpo_assert_bookmarks_exist() {
    # Ensure the bookmarks file exists and is not empty.
    if [ ! -f "$SHUNPO_BOOKMARKS_FILE" ] || [ ! -s "$SHUNPO_BOOKMARKS_FILE" ]; then
        echo -e "${SHUNPO_ORANGE}${SHUNPO_BOLD}No Bookmarks Found.${SHUNPO_RESET}"
        shunpo_cleanup
        return 1
    fi
}

function shunpo_cleanup() {
    # Clean up to avoid namespace pollution.
    unset SHUNPO_BOOKMARKS_FILE
    unset SHUNPO_BOOKMARKS_DIR
    unset SHUNPO_CONFIG_DIR
    unset SHUNPO_CONFIG_FILE
    unset SHUNPO_SELECTION_KEYS
    unset IFS
    unset shunpo_selected_dir
    unset shunpo_selected_bookmark_index
    unset -f shunpo_interact_bookmarks
    unset -f shunpo_add_space
    unset -f shunpo_clear_output
    unset -f shunpo_assert_bookmarks_exist
    unset -f shunpo_jump_to_parent_dir
    unset -f shunpo_jump_to_child_dir
    unset -f shunpo_is_cached
    unset -f shunpo_handle_kill
    unset -f shunpo_load_config
    unset -f shunpo_get_key_index
    unset -f shunpo_cleanup
    tput cnorm
    stty echo
    trap - SIGINT
}

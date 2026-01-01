#!/usr/bin/env bats

load common.sh
load bats/assert.sh
load bats/error.sh
load bats/lang.sh
load bats/output.sh

setup() {
    echo "Setting Up Test."
    setup_env
    printf '\n' | ./install.sh
    working_dir=$(pwd)
    source ${SHUNPO_TEST_DIR}/home/.bashrc
}

teardown() {
    echo "Shutting Down Test."
    cd "$working_dir"
    ./uninstall.sh
}

@test "Test Config File Created During Install." {
    # Check that config file was created.
    assert [ -f "${XDG_CONFIG_HOME}/shunpo/config" ]
}

@test "Test Config File Removed During Uninstall." {
    # Verify config exists before uninstall.
    assert [ -f "${XDG_CONFIG_HOME}/shunpo/config" ]

    # Run uninstall.
    cd "$working_dir"
    ./uninstall.sh

    # Verify config is removed.
    refute [ -f "${XDG_CONFIG_HOME}/shunpo/config" ]
    refute [ -d "${XDG_CONFIG_HOME}/shunpo" ]

    # Reinstall for teardown.
    printf '\n' | ./install.sh
    source ${SHUNPO_TEST_DIR}/home/.bashrc
}

@test "Test Default Selection Keys." {
    # Source functions to load config.
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh

    # Check default keys.
    assert_equal "$SHUNPO_SELECTION_KEYS" "1234567890"
}

@test "Test Custom Selection Keys." {
    # Write custom config.
    echo 'SHUNPO_SELECTION_KEYS="asdfghjkl;"' >"${XDG_CONFIG_HOME}/shunpo/config"

    # Source functions to load config.
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh

    # Check custom keys loaded.
    assert_equal "$SHUNPO_SELECTION_KEYS" "asdfghjkl;"

    # Restore default config.
    cat >"${XDG_CONFIG_HOME}/shunpo/config" <<EOF
# Shunpo Configuration
SHUNPO_SELECTION_KEYS="1234567890"
EOF
}

@test "Test Key Lookup Function." {
    # Source functions.
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh

    # Test key lookup with default keys "1234567890".
    result=$(shunpo_get_key_index "1")
    assert_equal "$result" "0"

    result=$(shunpo_get_key_index "5")
    assert_equal "$result" "4"

    result=$(shunpo_get_key_index "0")
    assert_equal "$result" "9"

    # Test invalid key returns failure.
    run shunpo_get_key_index "x"
    assert_failure
}

@test "Test Custom Key Lookup Function." {
    # Write custom config (no reserved keys: n, p, b).
    echo 'SHUNPO_SELECTION_KEYS="asdfghjkl;"' >"${XDG_CONFIG_HOME}/shunpo/config"

    # Source functions.
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh

    # Test key lookup with custom keys.
    result=$(shunpo_get_key_index "a")
    assert_equal "$result" "0"

    result=$(shunpo_get_key_index "g")
    assert_equal "$result" "4"

    result=$(shunpo_get_key_index ";")
    assert_equal "$result" "9"

    # Test that old numeric keys no longer work.
    run shunpo_get_key_index "1"
    assert_failure

    # Restore default config.
    cat >"${XDG_CONFIG_HOME}/shunpo/config" <<EOF
# Shunpo Configuration
SHUNPO_SELECTION_KEYS="1234567890"
EOF
}

@test "Test Validation: Wrong Length Falls Back to Defaults." {
    # Write invalid config (too short).
    echo 'SHUNPO_SELECTION_KEYS="abc"' >"${XDG_CONFIG_HOME}/shunpo/config"

    # Source functions (should show warning and use defaults).
    source ${SHUNPO_DIR}/scripts/colors.sh
    run source ${SHUNPO_DIR}/scripts/functions.sh

    # Re-source to get the variable.
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh

    # Should fall back to defaults.
    assert_equal "$SHUNPO_SELECTION_KEYS" "1234567890"

    # Restore default config.
    cat >"${XDG_CONFIG_HOME}/shunpo/config" <<EOF
# Shunpo Configuration
SHUNPO_SELECTION_KEYS="1234567890"
EOF
}

@test "Test Validation: Reserved Keys Fall Back to Defaults." {
    # Write invalid config (contains 'n').
    echo 'SHUNPO_SELECTION_KEYS="abcdefghin"' >"${XDG_CONFIG_HOME}/shunpo/config"

    # Source functions.
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh

    # Should fall back to defaults.
    assert_equal "$SHUNPO_SELECTION_KEYS" "1234567890"

    # Test with 'p'.
    echo 'SHUNPO_SELECTION_KEYS="abcdefghip"' >"${XDG_CONFIG_HOME}/shunpo/config"
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh
    assert_equal "$SHUNPO_SELECTION_KEYS" "1234567890"

    # Test with 'b'.
    echo 'SHUNPO_SELECTION_KEYS="abcdefghib"' >"${XDG_CONFIG_HOME}/shunpo/config"
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh
    assert_equal "$SHUNPO_SELECTION_KEYS" "1234567890"

    # Restore default config.
    cat >"${XDG_CONFIG_HOME}/shunpo/config" <<EOF
# Shunpo Configuration
SHUNPO_SELECTION_KEYS="1234567890"
EOF
}

@test "Test Validation: Duplicate Keys Fall Back to Defaults." {
    # Write invalid config (duplicate 'a').
    echo 'SHUNPO_SELECTION_KEYS="aacdefghij"' >"${XDG_CONFIG_HOME}/shunpo/config"

    # Source functions.
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh

    # Should fall back to defaults.
    assert_equal "$SHUNPO_SELECTION_KEYS" "1234567890"

    # Restore default config.
    cat >"${XDG_CONFIG_HOME}/shunpo/config" <<EOF
# Shunpo Configuration
SHUNPO_SELECTION_KEYS="1234567890"
EOF
}

@test "Test Empty Config File Uses Defaults." {
    # Write empty config.
    echo "" >"${XDG_CONFIG_HOME}/shunpo/config"

    # Source functions.
    source ${SHUNPO_DIR}/scripts/colors.sh
    source ${SHUNPO_DIR}/scripts/functions.sh

    # Should use defaults.
    assert_equal "$SHUNPO_SELECTION_KEYS" "1234567890"

    # Restore default config.
    cat >"${XDG_CONFIG_HOME}/shunpo/config" <<EOF
# Shunpo Configuration
SHUNPO_SELECTION_KEYS="1234567890"
EOF
}

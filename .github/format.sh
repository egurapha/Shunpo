#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shfmt -w -i 4 -ci -s -l "$SCRIPT_DIR/.."

#!/usr/bin/env bash
# Headless test for the keymap mode manager. Loads the full config, then runs
# tests/keymaps_spec.lua and checks for the success sentinel.
set -uo pipefail
cd "$(dirname "$0")/.."
out=$(nvim --headless "+lua dofile('tests/keymaps_spec.lua')" "+qa" 2>&1)
echo "$out"
echo "$out" | grep -q "KEYMAPS-TESTS-PASS" && { echo "KEYMAPS-OK"; exit 0; } || { echo "KEYMAPS-FAIL"; exit 1; }

#!/usr/bin/env bash
# Headless test for the keymap mode manager. Loads the full config, then runs
# tests/keymaps_spec.lua and checks for the success sentinel.
set -uo pipefail
cd "$(dirname "$0")/.."
out=$(nvim --headless "+lua dofile('tests/keymaps_spec.lua')" "+qa" 2>&1)
echo "$out"
echo "$out" | grep -q "KEYMAPS-TESTS-PASS" && { echo "KEYMAPS-OK"; } || { echo "KEYMAPS-FAIL"; exit 1; }

# Test 2: Verify manager is wired up in core (fresh nvim without explicit setup)
core=$(nvim --headless "+lua io.stdout:write('CMD='..vim.fn.exists(':KeymapMode')..'\n')" "+qa" 2>&1)
echo "$core" | grep -q "CMD=2" && echo "CORE-WIRED-OK" || { echo "CORE-WIRED-FAIL"; exit 1; }

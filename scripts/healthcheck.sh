#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== spec files return tables =="
for f in lua/plugins/*.lua; do
  nvim --headless --noplugin -u NONE \
    "+lua local ok,r=pcall(dofile,'$f'); assert(ok and type(r)=='table', '$f: '..tostring(r))" "+qa" \
    && echo "SPEC-OK $f"
done
echo "== vscode guard: core loads, lazy does not =="
nvim --headless --cmd "let g:vscode = 1" \
  "+lua assert(not package.loaded['lazy'], 'lazy loaded under vscode')" \
  "+lua assert(vim.g.mapleader, 'core did not load')" "+qa"
echo "GUARD-OK"

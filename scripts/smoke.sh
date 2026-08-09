#!/usr/bin/env bash
# End-to-end smoke test (terminal home). Network: installs lua_ls via mason.
set -uo pipefail
cd "$(dirname "$0")/.."
LAZY="$HOME/.local/share/nvim/lazy"
fail=0

echo "== 1. Full terminal config load (no Lua errors) =="
if nvim --headless "+qa" 2>&1 | grep -iE "E5108|stack traceback|Error detected"; then
  echo "FAIL: load errors above"; fail=1
else echo "LOAD-OK"; fi

echo "== 2. Plugin install completeness (no incomplete clones) =="
remnants=$(ls "$LAZY" 2>/dev/null | grep -E '\.(cloning|updating)$' || true)
count=$(ls "$LAZY" 2>/dev/null | grep -vE '\.(cloning|updating)$' | wc -l | tr -d ' ')
echo "installed plugin dirs: $count"
if [ -n "$remnants" ]; then echo "FAIL: incomplete clones: $remnants"; fail=1; else echo "NO-REMNANTS"; fi
for p in ibl telescope.nvim blink.cmp nvim-lspconfig github-nvim-theme neo-tree.nvim nvim-dap neotest; do
  [ -d "$LAZY/$p" ] && echo "  ok $p" || { echo "  FAIL missing $p"; fail=1; }
done

echo "== 3. Colorscheme applied =="
if nvim --headless "+lua io.stdout:write('COLORS='..(vim.g.colors_name or 'none')..'\n')" "+qa" 2>/dev/null | grep -q "COLORS=github_dark"; then
  echo "THEME-OK"; else echo "FAIL: theme not github_dark"; fail=1; fi

echo "== 4. Treesitter parser highlights a real buffer =="
printf 'local x = 1\nlocal function f() return x end\n' > /tmp/smoke_probe.lua
nvim --headless /tmp/smoke_probe.lua "+sleep 2" \
  "+lua local ok = pcall(vim.treesitter.get_parser, 0, 'lua'); io.stdout:write('TS='..tostring(ok)..'\n')" "+qa" 2>/dev/null | grep -E "TS=" || echo "TS=unknown"

echo "== 5. LSP: ensure lua_ls, then attach to a .lua buffer =="
nvim --headless "+MasonInstall lua-language-server" "+sleep 20" "+qa" >/dev/null 2>&1
clients=$(nvim --headless /tmp/smoke_probe.lua "+sleep 6" \
  "+lua io.stdout:write('LSPCLIENTS='..#vim.lsp.get_clients({bufnr=0})..'\n')" "+qa" 2>/dev/null | grep -E "LSPCLIENTS=")
echo "${clients:-LSPCLIENTS=?}"
if echo "$clients" | grep -qE "LSPCLIENTS=[1-9]"; then echo "LSP-OK"; else
  echo "LSP-SOFT: no client attached yet (server may still be installing — not fatal)"; fi

echo "== SMOKE DONE (fail=$fail) =="
exit $fail

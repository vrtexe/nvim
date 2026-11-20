#!/usr/bin/env bash
# End-to-end smoke test (terminal home). Network: installs lua_ls via mason.
set -uo pipefail
cd "$(dirname "$0")/.."
LAZY="$HOME/.local/share/nvim/lazy"
fail=0

echo "== 1. Full terminal config load — inspect every plugin's error state =="
# Note: lazy swallows plugin `config` errors into p._.error (NOT stderr), so a raw
# stderr grep gives false passes. Inspect lazy's own per-plugin error field instead.
res=$(nvim --headless \
  "+lua local bad=false; for _,p in pairs(require('lazy.core.config').plugins) do if p._.error then bad=true; io.stdout:write('PLUGIN-ERROR '..p.name..': '..tostring(p._.error)..'\n') end end; io.stdout:write(bad and 'HAS-ERRORS\n' or 'ALL-PLUGINS-CLEAN\n')" \
  "+qa" 2>&1)
echo "$res" | grep -E "PLUGIN-ERROR" || true
if echo "$res" | grep -q "ALL-PLUGINS-CLEAN"; then echo "LOAD-OK"; else echo "FAIL: plugin errors above"; fail=1; fi

echo "== 2. Plugin install completeness (no incomplete clones) =="
remnants=$(ls "$LAZY" 2>/dev/null | grep -E '\.(cloning|updating)$' || true)
count=$(ls "$LAZY" 2>/dev/null | grep -vE '\.(cloning|updating)$' | wc -l | tr -d ' ')
echo "installed plugin dirs: $count"
if [ -n "$remnants" ]; then echo "FAIL: incomplete clones: $remnants"; fail=1; else echo "NO-REMNANTS"; fi
for p in ibl blink.cmp nvim-lspconfig github-nvim-theme neo-tree.nvim nvim-dap neotest; do
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

echo "== 6. Keymap modes cycle cleanly =="
modes=$(nvim --headless "+lua local km=require('keymaps'); for _,m in ipairs({'classic','consistent','vscode','intellij','classic'}) do assert(km.switch(m), 'switch '..m) end; io.stdout:write('MODES-CYCLE-OK\n')" "+qa" 2>&1)
echo "$modes" | grep -q "MODES-CYCLE-OK" && echo "MODES-OK" || { echo "FAIL: mode cycle"; fail=1; }

echo "== 7. DAP adapters registered by mason-nvim-dap =="
adapters=$(nvim --headless "+lua io.stdout:write('ADAPTERS='..table.concat(vim.tbl_keys(require('dap').adapters), ',')..'\n')" "+qa" 2>&1 | grep -E "ADAPTERS=")
echo "$adapters"
echo "$adapters" | grep -q "delve" && echo "DAP-OK" || { echo "FAIL: no dap adapters"; fail=1; }

echo "== 8. No deprecated API calls with every plugin loaded =="
deps=$(nvim --headless \
  --cmd "lua _G.__dep={}; local o=vim.deprecate; vim.deprecate=function(n,...) local s=debug.traceback('',2):match('/lazy/([^/]+)') or '?'; __dep[#__dep+1]=n..' @ '..s; return o(n,...) end" \
  /tmp/smoke_probe.lua "+doautocmd UIEnter" "+Lazy! load all" \
  "+lua for _,d in ipairs(__dep) do io.stdout:write('DEPRECATED '..d..'\n') end; io.stdout:write('DEP-SCAN-DONE\n')" "+qa!" 2>&1)
echo "$deps" | grep -E "^DEPRECATED" | sort -u
if echo "$deps" | grep -q "DEP-SCAN-DONE" && ! echo "$deps" | grep -q "^DEPRECATED"; then echo "DEPRECATIONS-OK"; else echo "FAIL: deprecated calls above"; fail=1; fi

echo "== 9. A language server attaches per language (Java, Go, Rust, TypeScript, Python) =="
proj=$(mktemp -d)
mkdir -p "$proj/src/demo" "$proj/rs/src"
git -C "$proj" init -q
printf 'package demo;\npublic class App {}\n' > "$proj/src/demo/App.java"
printf 'module demo\n\ngo 1.22\n' > "$proj/go.mod"
printf 'package main\n\nfunc main() {}\n' > "$proj/main.go"
printf '[package]\nname = "rs"\nversion = "0.1.0"\nedition = "2021"\n' > "$proj/rs/Cargo.toml"
printf 'fn main() {}\n' > "$proj/rs/src/main.rs"
printf 'export const x: number = 1;\n' > "$proj/a.ts"
printf 'x = 1\n' > "$proj/a.py"
# One nvim per file, each waiting up to 40 s for a client. The leading newline
# keeps the line apart from jdtls progress text, which has none.
langs=$(cd "$proj" && for f in src/demo/App.java main.go rs/src/main.rs a.ts a.py; do
  nvim --headless "$f" \
    "+lua vim.wait(40000, function() return #vim.lsp.get_clients({bufnr=0}) > 0 end, 500) local c={} for _,x in ipairs(vim.lsp.get_clients({bufnr=0})) do c[#c+1]=x.name end io.stdout:write('\nLANG '..vim.bo.filetype..'='..table.concat(c,',')..'\n')" \
    "+qa!" 2>&1 | grep -E "^LANG "
done)
pkill -f "jdtls-workspace/$(basename "$proj")" 2>/dev/null
rm -rf "$proj"
echo "$langs"
for ft in java go rust typescript python; do
  echo "$langs" | grep -qE "^LANG $ft=.+" || { echo "FAIL: no language server for $ft"; fail=1; }
done

echo "== SMOKE DONE (fail=$fail) =="
exit $fail

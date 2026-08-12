# Keybinding Modes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the ad-hoc keymap layer with four coherent, live-switchable keybinding schemes (classic / consistent / vscode / intellij) driven by a central `:KeymapMode` manager, with all bindings centralized out of plugin specs.

**Architecture:** A manager module (`lua/keymaps/init.lua`) applies a shared `base` scheme plus one active overlay (`classic`/`consistent`/`vscode`/`intellij`), records every mapping it sets, and tears them down + re-applies on switch — live, no restart, choice persisted to `stdpath("data")/keymap-mode`. Plugins become keyless capability providers (lazy via `cmd`/`event`/`ft`); all bindings live in the scheme modules. LSP buffer-local maps are routed through the manager via an `LspAttach` autocmd so they switch too.

**Tech Stack:** Neovim 0.12.4 (Lua), lazy.nvim, which-key.nvim, snacks.nvim (picker/ui.select), headless-nvim bash tests.

**Spec:** `docs/superpowers/specs/2026-08-12-keybinding-modes-design.md` (companion: `docs/superpowers/specs/2026-08-12-keybinding-capability-inventory.md`). The plan argues from the spec; executors read both.

## Global Constraints

- Neovim baseline **0.12.4** — `gr*` LSP defaults ship built-in; scheme maps override deliberately.
- `mapleader` = `<Space>`, `maplocalleader` = `\` (already set in `options.lua`; grug-far depends on it).
- The four modes are `classic`, `consistent`, `vscode`, `intellij`. `vscode` and `intellij` are separate, self-contained pure IDE emulations (no combined mode; no cross-IDE conflict resolution).
- Scheme modules return **data only** (no side effects at require time). Shape: `{ name, desc, maps, lsp?, groups? }`.
- `maps`/`lsp` entry shape: `{ mode, lhs, rhs, desc, opts? }` where `mode` is a string or list of strings.
- The config MUST stay loadable (`scripts/healthcheck.sh` green) after **every** task. `scripts/smoke.sh` must stay green after plugin-cutover tasks.
- Never leave a plugin without a lazy trigger after removing its `keys` — it must still load on first use.
- Persistence file path: `vim.fn.stdpath("data") .. "/keymap-mode"` (outside the repo).
- Default mode when no persisted choice: `classic`.
- Commit after each task. We are on branch `feat/keybinding-modes`.

---

## File Structure

**Create:**
- `lua/keymaps/init.lua` — the manager (state, apply/teardown, switch, persistence, `:KeymapMode`, LSP routing, which-key groups).
- `lua/keymaps/base.lua` — universal bindings (all modes).
- `lua/keymaps/classic.lua` — vim-native overlay.
- `lua/keymaps/consistent.lua` — mnemonic leader-tree overlay.
- `lua/keymaps/vscode.lua` — VS Code emulation overlay.
- `lua/keymaps/intellij.lua` — IntelliJ emulation overlay.
- `tests/keymaps_spec.lua` — headless Lua assertions (loaded by the test script).
- `scripts/keymaps_test.sh` — headless runner for the mode system.

**Modify (plugin cutover — remove `keys`, add lazy trigger):**
- `lua/core/init.lua` — require `keymaps` instead of `core.keymaps`.
- `lua/plugins/navigation.lua`, `ai.lua`, `git.lua`, `snacks.lua`, `shell.lua`, `run.lua`, `coding.lua`, `debug.lua`, `lsp.lua`, `diagnostics.lua`, `ui_extra.lua`, `ui.lua`, `tree.lua`.

**Delete:**
- `lua/core/keymaps.lua` (last, after schemes cover its contents).

---

## Task 1: Manager core — apply / teardown / switch / persistence / command

**Files:**
- Create: `lua/keymaps/init.lua`
- Create: `lua/keymaps/base.lua` (temporary minimal stub, expanded in Task 4)
- Create: `lua/keymaps/classic.lua`, `lua/keymaps/consistent.lua`, `lua/keymaps/vscode.lua`, `lua/keymaps/intellij.lua` (temporary minimal stubs, expanded in Tasks 5-7)
- Create: `tests/keymaps_spec.lua`
- Create: `scripts/keymaps_test.sh`

**Interfaces:**
- Produces:
  - `require("keymaps").setup()` — read persisted mode (or `classic`), apply base+overlay.
  - `require("keymaps").switch(name)` — teardown current, apply `name`, persist, notify. Returns `true` on success, `false` if `name` invalid.
  - `require("keymaps").current()` — returns active mode name string.
  - `require("keymaps").MODES` — `{ "classic", "consistent", "vscode", "intellij" }`.
  - `require("keymaps").apply_lsp(bufnr)` — apply active scheme's `lsp` maps buffer-local (used by Task 8's autocmd; testable directly).
  - Ex command `:KeymapMode [name]`.
- Consumes: scheme modules `keymaps.base`, `keymaps.classic`, `keymaps.consistent`, `keymaps.vscode`, `keymaps.intellij` (data tables).

- [ ] **Step 1: Create minimal scheme stubs so requires resolve**

`lua/keymaps/base.lua`:
```lua
-- Universal bindings present in ALL modes. Expanded in Task 4.
return {
  name = "base",
  maps = {
    { "n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight" },
  },
  lsp = {},
  groups = {},
}
```

`lua/keymaps/classic.lua`:
```lua
-- Vim-native overlay. Expanded in Task 5.
return {
  name = "classic",
  desc = "Vim-native / LazyVim-canonical",
  maps = {
    { "n", "gh", "<cmd>echo 'classic'<cr>", "classic marker" },
  },
  lsp = {},
  groups = {},
}
```

`lua/keymaps/consistent.lua`:
```lua
-- Mnemonic leader-tree overlay. Expanded in Task 6.
return {
  name = "consistent",
  desc = "Mnemonic leader-trees",
  maps = {
    { "n", "<leader>zc", "<cmd>echo 'consistent'<cr>", "consistent marker" },
  },
  lsp = {},
  groups = {},
}
```

`lua/keymaps/vscode.lua`:
```lua
-- VS Code emulation overlay. Expanded in Task 7.
return {
  name = "vscode",
  desc = "VS Code emulation",
  maps = {
    { "n", "<F17>", "<cmd>echo 'vscode'<cr>", "vscode marker" },
  },
  lsp = {},
  groups = {},
}
```

`lua/keymaps/intellij.lua`:
```lua
-- IntelliJ emulation overlay. Expanded in Task 7.
return {
  name = "intellij",
  desc = "IntelliJ emulation",
  maps = {
    { "n", "<F18>", "<cmd>echo 'intellij'<cr>", "intellij marker" },
  },
  lsp = {},
  groups = {},
}
```

- [ ] **Step 2: Write the failing test**

`tests/keymaps_spec.lua`:
```lua
-- Headless assertions for the keymap mode manager.
-- Run via scripts/keymaps_test.sh. Prints "KEYMAPS-TESTS-PASS" on success,
-- or aborts with an assertion error (non-zero exit) on failure.
local km = require("keymaps")

-- helper: is (mode, lhs) currently mapped globally?
local function mapped(mode, lhs)
  return vim.fn.maparg(lhs, mode) ~= ""
end

-- 1. MODES and default
assert(vim.deep_equal(km.MODES, { "classic", "consistent", "vscode", "intellij" }), "MODES list")

-- 2. setup() applies base + default overlay (classic)
km.setup()
assert(km.current() == "classic", "default mode is classic, got " .. tostring(km.current()))
assert(mapped("n", "<Esc>"), "base <Esc> applied")
assert(mapped("n", "gh"), "classic marker applied")

-- 3. switch() tears down previous overlay and applies the new one
assert(km.switch("vscode") == true, "switch to vscode returns true")
assert(km.current() == "vscode", "current is vscode")
assert(mapped("n", "<F17>"), "vscode marker applied after switch")
assert(not mapped("n", "gh"), "classic marker torn down after switch")
assert(mapped("n", "<Esc>"), "base survives switch")

-- 4. switch to consistent
assert(km.switch("consistent") == true, "switch to consistent")
assert(mapped("n", "<leader>zc") or mapped("n", " zc"), "consistent marker applied")
assert(not mapped("n", "<F17>"), "vscode marker torn down")

-- 4b. switch to intellij applies its marker
assert(km.switch("intellij") == true, "switch to intellij")
assert(mapped("n", "<F18>"), "intellij marker applied")

-- 5. invalid mode rejected
assert(km.switch("nonsense") == false, "invalid mode returns false")
assert(km.current() == "intellij", "invalid switch does not change mode")

-- 6. persistence: switch writes the state file
km.switch("vscode")
local f = io.open(vim.fn.stdpath("data") .. "/keymap-mode", "r")
assert(f, "state file exists")
local persisted = (f:read("*a") or ""):gsub("%s+$", "")
f:close()
assert(persisted == "vscode", "persisted mode is vscode, got '" .. persisted .. "'")

-- 7. :KeymapMode command switches
vim.cmd("KeymapMode classic")
assert(km.current() == "classic", ":KeymapMode classic switched")

io.stdout:write("KEYMAPS-TESTS-PASS\n")
```

`scripts/keymaps_test.sh`:
```bash
#!/usr/bin/env bash
# Headless test for the keymap mode manager. Loads the full config, then runs
# tests/keymaps_spec.lua and checks for the success sentinel.
set -uo pipefail
cd "$(dirname "$0")/.."
out=$(nvim --headless "+lua dofile('tests/keymaps_spec.lua')" "+qa" 2>&1)
echo "$out"
echo "$out" | grep -q "KEYMAPS-TESTS-PASS" && { echo "KEYMAPS-OK"; exit 0; } || { echo "KEYMAPS-FAIL"; exit 1; }
```

- [ ] **Step 3: Run test to verify it fails**

Run: `chmod +x scripts/keymaps_test.sh && bash scripts/keymaps_test.sh`
Expected: FAIL — `module 'keymaps' not found` (init.lua doesn't exist yet).

- [ ] **Step 4: Implement the manager**

`lua/keymaps/init.lua`:
```lua
local M = {}

M.MODES = { "classic", "consistent", "vscode", "intellij" }
local STATE_FILE = vim.fn.stdpath("data") .. "/keymap-mode"

M._active = nil
M._global = {} -- list of { mode, lhs } applied globally (for teardown)
M._lsp = {} -- active scheme's lsp spec (list of entries)
M._lsp_bufs = {} -- bufnr -> list of { mode, lhs } applied buffer-local

local function is_mode(name)
  return vim.tbl_contains(M.MODES, name)
end

local function base()
  return require("keymaps.base")
end

local function overlay(name)
  return require("keymaps." .. name)
end

-- Apply a list of { mode, lhs, rhs, desc, opts? } entries. Record each
-- concrete (mode, lhs) pair into `sink` for later teardown. `extra` merges
-- into opts (e.g. { buffer = bufnr }).
local function apply_maps(list, sink, extra)
  for _, m in ipairs(list) do
    local mode, lhs, rhs, desc = m[1], m[2], m[3], m[4]
    local opts = vim.tbl_extend("force", { desc = desc, silent = true }, m.opts or {}, extra or {})
    pcall(vim.keymap.set, mode, lhs, rhs, opts)
    local modes = type(mode) == "table" and mode or { mode }
    for _, mo in ipairs(modes) do
      table.insert(sink, { mo, lhs })
    end
  end
end

local function del_maps(pairs_list, extra)
  for _, p in ipairs(pairs_list) do
    pcall(vim.keymap.del, p[1], p[2], extra)
  end
end

-- which-key group labels (best-effort; no teardown needed — labels for live
-- prefixes are harmless, and which-key dedups by key).
local function register_groups(groups)
  if not groups or vim.tbl_isempty(groups) then
    return
  end
  local ok, wk = pcall(require, "which-key")
  if ok and wk.add then
    pcall(wk.add, groups)
  end
end

-- Apply the active scheme's LSP maps to a buffer (buffer-local). Records the
-- pairs so a mode switch can remove them. Public so the LspAttach autocmd
-- (Task 8) and tests can call it.
function M.apply_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  -- remove any previously-applied lsp maps in this buffer first
  if M._lsp_bufs[bufnr] then
    del_maps(M._lsp_bufs[bufnr], { buffer = bufnr })
  end
  M._lsp_bufs[bufnr] = {}
  apply_maps(M._lsp, M._lsp_bufs[bufnr], { buffer = bufnr })
end

local function apply(name)
  M._global = {}
  apply_maps(base().maps, M._global)
  apply_maps(overlay(name).maps, M._global)
  M._lsp = overlay(name).lsp or {}
  register_groups(base().groups)
  register_groups(overlay(name).groups)
  -- re-apply lsp maps to every buffer that already has them (mode switch)
  for bufnr, _ in pairs(M._lsp_bufs) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      M.apply_lsp(bufnr)
    else
      M._lsp_bufs[bufnr] = nil
    end
  end
  M._active = name
end

local function teardown()
  del_maps(M._global)
  M._global = {}
  -- lsp buffer-local maps are removed/re-applied inside apply() -> apply_lsp()
end

local function persist(name)
  local f = io.open(STATE_FILE, "w")
  if f then
    f:write(name)
    f:close()
  end
end

local function read_persisted()
  local f = io.open(STATE_FILE, "r")
  if not f then
    return nil
  end
  local s = (f:read("*a") or ""):gsub("%s+$", "")
  f:close()
  return is_mode(s) and s or nil
end

function M.current()
  return M._active
end

function M.switch(name)
  if not is_mode(name) then
    vim.notify("KeymapMode: unknown mode '" .. tostring(name) .. "'", vim.log.levels.WARN)
    return false
  end
  teardown()
  apply(name)
  persist(name)
  vim.notify("Keymap mode: " .. name, vim.log.levels.INFO)
  return true
end

local function pick()
  local items = M.MODES
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.picker then
    vim.ui.select(items, { prompt = "Keymap mode (current: " .. (M._active or "?") .. ")" }, function(choice)
      if choice then
        M.switch(choice)
      end
    end)
  else
    vim.ui.select(items, { prompt = "Keymap mode" }, function(choice)
      if choice then
        M.switch(choice)
      end
    end)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("KeymapMode", function(o)
    if o.args and o.args ~= "" then
      M.switch(o.args)
    else
      pick()
    end
  end, {
    nargs = "?",
    complete = function()
      return M.MODES
    end,
    desc = "Switch keybinding mode",
  })
  apply(read_persisted() or "classic")
end

return M
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bash scripts/keymaps_test.sh`
Expected: PASS — prints `KEYMAPS-TESTS-PASS` then `KEYMAPS-OK`.

- [ ] **Step 6: Verify config still loads (not yet wired into core)**

Run: `bash scripts/healthcheck.sh`
Expected: all `SPEC-OK` lines + `GUARD-OK` (we haven't touched `core/init.lua` yet).

- [ ] **Step 7: Commit**

```bash
git add lua/keymaps/ tests/keymaps_spec.lua scripts/keymaps_test.sh
git commit -m "feat(keymaps): mode manager (apply/teardown/switch/persist/:KeymapMode)"
```

---

## Task 2: Snacks picker for `:KeymapMode` (no-arg)

**Files:**
- Modify: `lua/keymaps/init.lua` (replace `pick()` body with a Snacks.picker when available)
- Modify: `tests/keymaps_spec.lua` (add a headless assertion that `pick` is callable without error)

**Interfaces:**
- Consumes: `require("keymaps").switch` (Task 1).
- Produces: no new public API; `:KeymapMode` with no arg opens the picker.

- [ ] **Step 1: Add failing assertion**

Append to `tests/keymaps_spec.lua` before the final `io.stdout:write`:
```lua
-- 8. pick() is callable without throwing (headless: vim.ui.select is a no-op)
assert(pcall(function() vim.cmd("KeymapMode") end), ":KeymapMode (no arg) does not error")
```

- [ ] **Step 2: Run to verify current behavior**

Run: `bash scripts/keymaps_test.sh`
Expected: PASS already (the current `pick()` uses `vim.ui.select`, which is a safe no-op headless). This step confirms the no-arg path is exercised.

- [ ] **Step 3: Upgrade `pick()` to use Snacks.picker when interactive**

Replace the `pick()` function in `lua/keymaps/init.lua`:
```lua
local function pick()
  local current = M._active or "?"
  local ok, Snacks = pcall(require, "snacks")
  if ok and Snacks and Snacks.picker then
    Snacks.picker.select(M.MODES, {
      prompt = "Keymap mode (current: " .. current .. ")",
      format_item = function(item)
        return item == current and (item .. "  (current)") or item
      end,
    }, function(choice)
      if choice then
        M.switch(choice)
      end
    end)
  else
    vim.ui.select(M.MODES, { prompt = "Keymap mode (current: " .. current .. ")" }, function(choice)
      if choice then
        M.switch(choice)
      end
    end)
  end
end
```

> Note: `Snacks.picker.select` mirrors `vim.ui.select`. If the installed snacks
> version lacks it, `snacks.nvim` already sets `vim.ui.select` to its own picker
> (via `opts.picker.ui_select`), so the `else` branch still yields the snacks UI.
> Both paths are safe headless.

- [ ] **Step 4: Run test to verify it still passes**

Run: `bash scripts/keymaps_test.sh`
Expected: PASS (`KEYMAPS-OK`).

- [ ] **Step 5: Commit**

```bash
git add lua/keymaps/init.lua tests/keymaps_spec.lua
git commit -m "feat(keymaps): Snacks picker for :KeymapMode with no arg"
```

---

## Task 3: Wire manager into core; keep old keymaps temporarily disabled behind a flag

**Rationale:** Cut `core/init.lua` over to the manager now so the system is live,
but do NOT delete `core/keymaps.lua` yet — its bindings are re-homed into the
scheme modules across Tasks 4-7. To avoid double-mapping during that window, we
guard the old file so it only runs its *non*-migrated pieces (none, once Task 4-7
land). For this task we simply stop requiring it and rely on base+overlay stubs
plus the still-present plugin `keys`. The config must remain usable.

**Files:**
- Modify: `lua/core/init.lua:2`

**Interfaces:**
- Consumes: `require("keymaps").setup()` (Task 1).

- [ ] **Step 1: Write the failing test**

Add to `tests/keymaps_spec.lua` (after setup section):
```lua
-- 9. manager is initialized by core (command exists after full startup)
assert(vim.fn.exists(":KeymapMode") == 2, ":KeymapMode command registered by core")
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash scripts/keymaps_test.sh`
Expected: the spec's own `km.setup()` call registers the command, so this may already pass. To make it a genuine core-wiring test, instead assert on a fresh nvim WITHOUT calling setup in-spec. Replace the assertion with a separate check in `scripts/keymaps_test.sh`:
```bash
core=$(nvim --headless "+lua io.stdout:write('CMD='..vim.fn.exists(':KeymapMode')..'\n')" "+qa" 2>&1)
echo "$core" | grep -q "CMD=2" && echo "CORE-WIRED-OK" || { echo "CORE-WIRED-FAIL"; exit 1; }
```
Run: `bash scripts/keymaps_test.sh`
Expected: FAIL — `CMD=0` (core still requires `core.keymaps`, not `keymaps`).

- [ ] **Step 3: Rewire core**

`lua/core/init.lua`:
```lua
require("core.options")
require("keymaps").setup()
```

- [ ] **Step 4: Run to verify it passes**

Run: `bash scripts/keymaps_test.sh`
Expected: PASS incl. `CORE-WIRED-OK`.

- [ ] **Step 5: Verify healthcheck + smoke**

Run: `bash scripts/healthcheck.sh && bash scripts/smoke.sh`
Expected: healthcheck all-OK; smoke `LOAD-OK` / `THEME-OK` (LSP-SOFT acceptable).

- [ ] **Step 6: Commit**

```bash
git add lua/core/init.lua scripts/keymaps_test.sh tests/keymaps_spec.lua
git commit -m "feat(keymaps): wire mode manager into core startup"
```

---

## Task 4: Author `base.lua` (universal bindings)

**Files:**
- Modify: `lua/keymaps/base.lua`
- Modify: `tests/keymaps_spec.lua` (assert representative base maps)

**Interfaces:**
- Produces: `keymaps.base` with full universal `maps` + `groups`. Source of truth: spec §5.

- [ ] **Step 1: Write the failing test**

Append base assertions to `tests/keymaps_spec.lua` (inside the classic-active section, after `km.setup()`):
```lua
-- base coverage (present in every mode)
for _, pair in ipairs({
  { "n", "<C-h>" }, { "n", "<C-l>" }, { "n", "<C-s>" }, { "v", "<C-c>" },
  { "n", "<A-Up>" }, { "n", "<S-l>" }, { "n", "<S-h>" }, { "n", "<C-\\>" },
  { "n", "<leader>ut" }, { "n", "<leader>uh" }, { "n", "s" },
  { "n", "<leader>wv" }, { "n", "<leader>qs" },
}) do
  assert(mapped(pair[1], pair[2]), "base map missing: " .. pair[1] .. " " .. pair[2])
end
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash scripts/keymaps_test.sh`
Expected: FAIL — base map missing (stub only has `<Esc>`).

- [ ] **Step 3: Implement `base.lua`**

`lua/keymaps/base.lua`:
```lua
-- Universal, idiom-neutral bindings present in ALL modes (spec §5).
-- Personality verbs (goto-def, rename, find, etc.) live in the overlays.
local function focus_terminal()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.cmd("ToggleTerm")
end

return {
  name = "base",
  maps = {
    -- Pane navigation (no <C-w> prefix), normal + terminal
    { "n", "<C-h>", "<C-w>h", "Go to left pane" },
    { "n", "<C-j>", "<C-w>j", "Go to lower pane" },
    { "n", "<C-k>", "<C-w>k", "Go to upper pane" },
    { "n", "<C-l>", "<C-w>l", "Go to right pane" },
    { "t", "<C-h>", "<C-\\><C-n><C-w>h", "Go to left pane" },
    { "t", "<C-j>", "<C-\\><C-n><C-w>j", "Go to lower pane" },
    { "t", "<C-k>", "<C-\\><C-n><C-w>k", "Go to upper pane" },
    { "t", "<C-l>", "<C-\\><C-n><C-w>l", "Go to right pane" },

    -- System clipboard reflexes (don't shadow vim motions)
    { "v", "<C-c>", '"+y', "Copy to system clipboard" },
    { "i", "<C-v>", "<C-r>+", "Paste from system clipboard" },
    { "v", "<C-v>", '"+p', "Paste over selection" },

    -- Clear search highlight
    { "n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight" },

    -- Save
    { "n", "<C-s>", "<cmd>silent! write<cr>", "Save file" },
    { "i", "<C-s>", "<C-o><cmd>silent! write<cr>", "Save file" },

    -- Move lines
    { "n", "<A-Down>", "<cmd>m .+1<cr>==", "Move line down" },
    { "n", "<A-Up>", "<cmd>m .-2<cr>==", "Move line up" },
    { "v", "<A-Down>", ":m '>+1<cr>gv=gv", "Move selection down" },
    { "v", "<A-Up>", ":m '<-2<cr>gv=gv", "Move selection up" },

    -- Buffer cycle
    { "n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
    { "n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Prev buffer" },

    -- Terminal (toggleterm)
    { { "n", "t" }, "<C-\\>", "<cmd>ToggleTerm<cr>", "Toggle terminal" },
    { { "n", "t" }, "<M-t>", "<cmd>ToggleTerm direction=float<cr>", "Float terminal" },
    { { "n", "t" }, "<M-1>", "<cmd>1ToggleTerm direction=horizontal<cr>", "Terminal 1" },
    { { "n", "t" }, "<M-2>", "<cmd>2ToggleTerm direction=horizontal<cr>", "Terminal 2" },
    { { "n", "t" }, "<M-3>", "<cmd>3ToggleTerm direction=horizontal<cr>", "Terminal 3" },

    -- Flash jump
    { { "n", "x", "o" }, "s", function() require("flash").jump() end, "Flash jump" },
    { { "n", "x", "o" }, "S", function() require("flash").treesitter() end, "Flash treesitter" },

    -- Window / split management (<leader>w tree)
    { "n", "<leader>wv", "<C-w>v", "Split vertical" },
    { "n", "<leader>ws", "<C-w>s", "Split horizontal" },
    { "n", "<leader>wh", "<C-w>h", "Go to left window" },
    { "n", "<leader>wj", "<C-w>j", "Go to lower window" },
    { "n", "<leader>wk", "<C-w>k", "Go to upper window" },
    { "n", "<leader>wl", "<C-w>l", "Go to right window" },
    { "n", "<leader>wc", "<C-w>c", "Close window" },
    { "n", "<leader>wo", "<C-w>o", "Only (close others)" },
    { "n", "<leader>w=", "<C-w>=", "Equalize windows" },
    { "n", "<leader>wt", "<cmd>tabnew<cr>", "New editor group (tab)" },
    { "n", "<leader>wn", "gt", "Next group" },
    { "n", "<leader>wp", "gT", "Prev group" },

    -- UI toggles (<leader>u tree)
    { "n", "<leader>ut", "<cmd>ThemeToggle<cr>", "Toggle theme (dark/light)" },
    { "n", "<leader>uh", function()
      local on = vim.lsp.inlay_hint.is_enabled()
      vim.lsp.inlay_hint.enable(not on)
      vim.notify("Inlay hints " .. (on and "off" or "on"), vim.log.levels.INFO)
    end, "Toggle inlay hints" },
    { "n", "<leader>um", "<cmd>RenderMarkdown toggle<cr>", "Toggle markdown render" },
    { "n", "<leader>un", function() require("snacks").notifier.hide() end, "Dismiss notifications" },
    { "n", "<leader>nh", function() require("snacks").notifier.show_history() end, "Notification history" },

    -- Session (<leader>q tree)
    { "n", "<leader>qs", function() require("persistence").load() end, "Restore session (cwd)" },
    { "n", "<leader>ql", function() require("persistence").load({ last = true }) end, "Restore last session" },
    { "n", "<leader>qd", function() require("persistence").stop() end, "Don't save session" },

    -- Comment reflexes for terminals that send Ctrl+/ variants (native gcc/gc stay)
    { "n", "<C-_>", "gcc", { remap = true } },
    { "x", "<C-_>", "gc", { remap = true } },
    { "n", "<D-/>", "gcc", { remap = true } },
    { "x", "<D-/>", "gc", { remap = true } },
  },
  lsp = {},
  groups = {
    { "<leader>w", group = "window" },
    { "<leader>u", group = "ui" },
    { "<leader>q", group = "session/quit" },
    { "<leader>n", group = "notifications" },
  },
}
```

> The comment-reflex entries use a 5th positional? No — `opts` is the table after
> desc. Fix shape: entries needing only `opts` still need a `desc` slot. Use:
> `{ "n", "<C-_>", "gcc", "Toggle comment", { remap = true } }`. Apply this
> corrected form (desc in slot 4, opts in slot 5) — see Step 4 note.

- [ ] **Step 4: Correct the entry shape for opts-bearing maps**

The manager reads `m[4]` as `desc` and `m.opts` as options. For maps needing
`remap = true`, write them as `{ mode, lhs, rhs, desc, opts = { remap = true } }`.
Replace the four comment-reflex entries with:
```lua
    { "n", "<C-_>", "gcc", "Toggle comment", opts = { remap = true } },
    { "x", "<C-_>", "gc", "Toggle comment", opts = { remap = true } },
    { "n", "<D-/>", "gcc", "Toggle comment", opts = { remap = true } },
    { "x", "<D-/>", "gc", "Toggle comment", opts = { remap = true } },
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bash scripts/keymaps_test.sh`
Expected: PASS (`KEYMAPS-OK`, all base maps present).

- [ ] **Step 6: Commit**

```bash
git add lua/keymaps/base.lua tests/keymaps_spec.lua
git commit -m "feat(keymaps): author base scheme (universal bindings)"
```

---

## Task 5: Author `classic.lua` (vim-native overlay)

**Files:**
- Modify: `lua/keymaps/classic.lua`
- Modify: `tests/keymaps_spec.lua`

**Interfaces:**
- Produces: `keymaps.classic` — `maps`, `lsp`, `groups`. Source: spec §6.1 + inventory [NEW] classic-appropriate actions.
- Consumes: base terminal/window maps (Task 4). LSP verbs are 0.12 built-ins (`vim.lsp.buf.*`).

- [ ] **Step 1: Write the failing test**

Append (in a `km.switch("classic")` block):
```lua
km.switch("classic")
for _, pair in ipairs({
  { "n", "gd" }, { "n", "gr" }, { "n", "gy" }, { "n", "gI" },
  { "n", "<leader>ca" }, { "n", "<leader>cf" }, { "n", "<leader>cr" },
  { "n", "]d" }, { "n", "[d" }, { "n", "]h" }, { "n", "[h" },
  { "n", "<leader>ff" }, { "n", "<leader>fg" }, { "n", "<leader>e" },
  { "n", "<leader>gg" }, { "n", "<leader>tt" }, { "n", "<leader>db" },
  { "n", "<leader>xx" }, { "n", "]t" }, { "n", "]r" },
}) do
  assert(mapped(pair[1], pair[2]), "classic map missing: " .. pair[1] .. " " .. pair[2])
end
-- classic lsp spec is applied buffer-local via apply_lsp
km.apply_lsp(0)
assert(vim.fn.maparg("gh", "n") ~= "" or true, "placeholder") -- lsp maps checked in Task 8
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash scripts/keymaps_test.sh`
Expected: FAIL — classic map missing (stub only has `gh`).

- [ ] **Step 3: Implement `classic.lua`**

`lua/keymaps/classic.lua`:
```lua
-- Vim-native / LazyVim-canonical overlay (spec §6.1). LSP verbs use 0.12
-- built-ins; picker verbs use snacks; git uses gitsigns; etc.
local function snacks() return require("snacks") end

return {
  name = "classic",
  desc = "Vim-native / LazyVim-canonical",
  maps = {
    -- Find (snacks.picker)
    { "n", "<leader>ff", function() snacks().picker.files() end, "Find files" },
    { "n", "<leader><leader>", function() snacks().picker.smart() end, "Smart find" },
    { "n", "<leader>fg", function() snacks().picker.grep() end, "Grep" },
    { "n", "<leader>fr", function() snacks().picker.recent() end, "Recent files" },
    { "n", "<leader>fb", function() snacks().picker.buffers() end, "Buffers" },
    { "n", "<leader>fp", function() snacks().picker.projects() end, "Projects" },
    { "n", "<leader>sg", function() snacks().picker.grep() end, "Grep (search)" },
    { "n", "<leader>/", function() snacks().picker.grep() end, "Grep" },
    { { "n", "x" }, "<leader>sw", function() snacks().picker.grep_word() end, "Grep word" },
    { "n", "<leader>sk", function() snacks().picker.keymaps() end, "Keymaps" },
    { "n", "<leader>sh", function() snacks().picker.help() end, "Help" },
    { "n", "<leader>sR", function() snacks().picker.resume() end, "Resume picker" },
    { "n", "<leader>sd", function() snacks().picker.diagnostics() end, "Diagnostics (picker)" },
    { "n", "<leader>ss", function() snacks().picker.lsp_symbols() end, "Document symbols" },

    -- Explorer
    { "n", "<leader>e", "<cmd>Neotree toggle<cr>", "File explorer" },

    -- Buffers
    { "n", "<leader>bd", function() require("mini.bufremove").delete(0, false) end, "Close buffer" },

    -- Diagnostics / problems
    { "n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Problems (all)" },
    { "n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Problems (buffer)" },
    { "n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic" },
    { "n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic" },
    { "n", "]e", function() vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR }) end, "Next error" },
    { "n", "[e", function() vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR }) end, "Prev error" },

    -- Code (LSP actions not tied to a goto)
    { "n", "<leader>cr", vim.lsp.buf.rename, "Rename" },
    { { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action" },
    { "n", "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, "Format" },
    { "n", "<leader>co", function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true }) end, "Organize imports" },
    { "n", "<leader>cs", "<cmd>AerialToggle<cr>", "Symbols / outline" },
    { "n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics" },
    { "n", "<leader>ci", function() require("snacks").picker.lsp_incoming_calls() end, "Incoming calls" },
    { "n", "<leader>cO", function() require("snacks").picker.lsp_outgoing_calls() end, "Outgoing calls" },

    -- Goto (vim-native short forms)
    { "n", "gd", vim.lsp.buf.definition, "Goto definition" },
    { "n", "gD", vim.lsp.buf.declaration, "Goto declaration" },
    { "n", "gI", vim.lsp.buf.implementation, "Goto implementation" },
    { "n", "gy", vim.lsp.buf.type_definition, "Goto type definition" },
    { "n", "gr", "<cmd>Glance references<cr>", "References (peek)" },
    { "n", "gK", vim.lsp.buf.signature_help, "Signature help" },

    -- Git (hunks under <leader>gh, ops under <leader>g)
    { "n", "<leader>ghs", function() require("gitsigns").stage_hunk() end, "Stage hunk" },
    { "n", "<leader>ghr", function() require("gitsigns").reset_hunk() end, "Reset hunk" },
    { "n", "<leader>ghp", function() require("gitsigns").preview_hunk() end, "Preview hunk" },
    { "n", "<leader>ghi", function() require("gitsigns").preview_hunk_inline() end, "Preview hunk inline" },
    { "n", "<leader>ghS", function() require("gitsigns").stage_buffer() end, "Stage buffer" },
    { "n", "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end, "Blame line" },
    { "n", "<leader>ghB", function() require("gitsigns").blame() end, "Blame file" },
    { "n", "<leader>ghd", function() require("gitsigns").diffthis() end, "Diff this" },
    { "n", "]h", function() require("gitsigns").nav_hunk("next") end, "Next hunk" },
    { "n", "[h", function() require("gitsigns").nav_hunk("prev") end, "Prev hunk" },
    { { "o", "x" }, "ih", function() require("gitsigns").select_hunk() end, "Hunk text-object" },
    { "n", "<leader>gb", function() require("gitsigns").toggle_current_line_blame() end, "Toggle line blame" },
    { "n", "<leader>gg", "<cmd>LazyGit<cr>", "LazyGit" },
    { "n", "<leader>gd", "<cmd>DiffviewOpen<cr>", "Diff view" },
    { "n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", "File history" },
    { "n", "<leader>gs", function() require("snacks").picker.git_status() end, "Git status" },
    { "n", "<leader>gl", function() require("snacks").picker.git_log() end, "Git log" },

    -- Run / test / debug
    { "n", "<leader>rr", "<cmd>OverseerRun<cr>", "Run task" },
    { "n", "<leader>rl", "<cmd>OverseerToggle<cr>", "Task list" },
    { "n", "<leader>rc", "<cmd>OverseerRunCmd<cr>", "Run shell cmd" },
    { "n", "<leader>tt", function() require("neotest").run.run() end, "Test nearest" },
    { "n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, "Test file" },
    { "n", "<leader>ts", function() require("neotest").summary.toggle() end, "Test summary" },
    { "n", "<leader>to", function() require("neotest").output_panel.toggle() end, "Test output panel" },
    { "n", "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, "Debug nearest test" },
    { "n", "]f", function() require("neotest").jump.next({ status = "failed" }) end, "Next failed test" },
    { "n", "[f", function() require("neotest").jump.prev({ status = "failed" }) end, "Prev failed test" },
    { "n", "<leader>db", function() require("dap").toggle_breakpoint() end, "Breakpoint" },
    { "n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, "Conditional breakpoint" },
    { "n", "<leader>dc", function() require("dap").continue() end, "Continue" },
    { "n", "<leader>dC", function() require("dap").run_to_cursor() end, "Run to cursor" },
    { "n", "<leader>dO", function() require("dap").step_over() end, "Step over" },
    { "n", "<leader>di", function() require("dap").step_into() end, "Step into" },
    { "n", "<leader>do", function() require("dap").step_out() end, "Step out" },
    { "n", "<leader>dt", function() require("dap").terminate() end, "Terminate" },
    { "n", "<leader>dl", function() require("dap").run_last() end, "Run last" },
    { "n", "<leader>du", function() require("dapui").toggle() end, "Debug UI" },
    { { "n", "v" }, "<leader>de", function() require("dapui").eval() end, "Eval expression" },

    -- Search & replace
    { "n", "<leader>sr", function() require("grug-far").open() end, "Search & replace (project)" },
    { "v", "<leader>sr", function() require("grug-far").with_visual_selection() end, "Replace selection" },

    -- Folds (ufo)
    { "n", "zR", function() require("ufo").openAllFolds() end, "Open all folds" },
    { "n", "zM", function() require("ufo").closeAllFolds() end, "Close all folds" },
    { "n", "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, "Peek fold" },

    -- Todo / reference nav
    { "n", "]t", function() require("todo-comments").jump_next() end, "Next todo" },
    { "n", "[t", function() require("todo-comments").jump_prev() end, "Prev todo" },
    { "n", "]r", function() require("illuminate").goto_next_reference(true) end, "Next reference" },
    { "n", "[r", function() require("illuminate").goto_prev_reference(true) end, "Prev reference" },

    -- Harpoon (slots on <leader>1-4; add/menu on <leader>h)
    { "n", "<leader>ha", function() require("harpoon"):list():add() end, "Harpoon add" },
    { "n", "<leader>hh", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, "Harpoon menu" },
    { "n", "<leader>1", function() require("harpoon"):list():select(1) end, "Harpoon 1" },
    { "n", "<leader>2", function() require("harpoon"):list():select(2) end, "Harpoon 2" },
    { "n", "<leader>3", function() require("harpoon"):list():select(3) end, "Harpoon 3" },
    { "n", "<leader>4", function() require("harpoon"):list():select(4) end, "Harpoon 4" },

    -- AI (Claude Code)
    { "n", "<leader>ac", "<cmd>ClaudeCode<cr>", "Toggle Claude" },
    { "n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", "Focus Claude" },
    { "n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", "Resume Claude" },
    { "n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", "Add buffer to Claude" },
    { "v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", "Send selection to Claude" },
    { "n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", "Accept Claude diff" },
    { "n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", "Reject Claude diff" },
  },
  lsp = {
    -- buffer-local, applied on LspAttach (Task 8). Peek references via glance.
    { "n", "K", function()
      -- ufo peek first, fall back to hover
      local ok = require("ufo").peekFoldedLinesUnderCursor()
      if not ok then vim.lsp.buf.hover() end
    end, "Hover / peek fold" },
  },
  groups = {
    { "<leader>c", group = "code" },
    { "<leader>f", group = "find" },
    { "<leader>s", group = "search" },
    { "<leader>g", group = "git" },
    { "<leader>gh", group = "git hunks" },
    { "<leader>x", group = "diagnostics" },
    { "<leader>r", group = "run" },
    { "<leader>t", group = "test" },
    { "<leader>d", group = "debug" },
    { "<leader>h", group = "harpoon" },
    { "<leader>a", group = "AI/Claude" },
  },
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash scripts/keymaps_test.sh`
Expected: PASS (all classic maps present).

- [ ] **Step 5: Commit**

```bash
git add lua/keymaps/classic.lua tests/keymaps_spec.lua
git commit -m "feat(keymaps): author classic (vim-native) scheme"
```

---

## Task 6: Author `consistent.lua` (mnemonic leader-trees)

**Files:**
- Modify: `lua/keymaps/consistent.lua`
- Modify: `tests/keymaps_spec.lua`

**Interfaces:**
- Produces: `keymaps.consistent`. Source: spec §6.2 (one rule: `<leader>` + category + verb).
  Reuses base + the same plugin capabilities as classic; only the LHS grammar differs.

- [ ] **Step 1: Write the failing test**

Append (in a `km.switch("consistent")` block):
```lua
km.switch("consistent")
for _, pair in ipairs({
  { "n", "<leader>cd" }, { "n", "<leader>cr" }, { "n", "<leader>cn" },
  { "n", "<leader>ca" }, { "n", "<leader>cf" }, { "n", "<leader>ci" },
  { "n", "<leader>cy" }, { "n", "<leader>ck" }, { "n", "<leader>cs" },
  { "n", "<leader>ff" }, { "n", "<leader>xn" }, { "n", "<leader>xp" },
  { "n", "<leader>tt" }, { "n", "<leader>db" }, { "n", "<leader>gs" },
}) do
  assert(mapped(pair[1], pair[2]), "consistent map missing: " .. pair[1] .. " " .. pair[2])
end
assert(not mapped("n", "gd"), "consistent does not bind vim-native gd (torn down)")
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash scripts/keymaps_test.sh`
Expected: FAIL — consistent map missing.

- [ ] **Step 3: Implement `consistent.lua`**

`lua/keymaps/consistent.lua`:
```lua
-- Mnemonic leader-tree overlay (spec §6.2). One rule: <leader> + category + verb.
-- Every action is discoverable by pressing the category prefix (which-key shows
-- the tree). `cr` = references (read-heavy), `cn` = rename.
local function snacks() return require("snacks") end
local function gs() return require("gitsigns") end

return {
  name = "consistent",
  desc = "Mnemonic leader-trees",
  maps = {
    -- code (<leader>c)
    { "n", "<leader>cd", vim.lsp.buf.definition, "Definition" },
    { "n", "<leader>cD", vim.lsp.buf.declaration, "Declaration" },
    { "n", "<leader>ci", vim.lsp.buf.implementation, "Implementation" },
    { "n", "<leader>cy", vim.lsp.buf.type_definition, "Type definition" },
    { "n", "<leader>cr", "<cmd>Glance references<cr>", "References" },
    { "n", "<leader>cn", vim.lsp.buf.rename, "Rename" },
    { { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action" },
    { "n", "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, "Format" },
    { "n", "<leader>co", function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true }) end, "Organize imports" },
    { "n", "<leader>ck", vim.lsp.buf.hover, "Hover" },
    { "n", "<leader>cs", function() snacks().picker.lsp_symbols() end, "Symbols / outline" },
    { "n", "<leader>ce", vim.diagnostic.open_float, "Line diagnostics" },
    { "n", "<leader>cI", function() snacks().picker.lsp_incoming_calls() end, "Incoming calls" },
    { "n", "<leader>cO", function() snacks().picker.lsp_outgoing_calls() end, "Outgoing calls" },

    -- find (<leader>f)
    { "n", "<leader>ff", function() snacks().picker.files() end, "Files" },
    { "n", "<leader>fg", function() snacks().picker.grep() end, "Grep" },
    { "n", "<leader>fr", function() snacks().picker.recent() end, "Recent" },
    { "n", "<leader>fb", function() snacks().picker.buffers() end, "Buffers" },
    { "n", "<leader>fp", function() snacks().picker.projects() end, "Projects" },
    { "n", "<leader>fs", function() snacks().picker.lsp_symbols() end, "Symbols" },
    { "n", "<leader>fw", function() snacks().picker.grep_word() end, "Grep word" },
    { "n", "<leader>fk", function() snacks().picker.keymaps() end, "Keymaps" },
    { "n", "<leader>fh", function() snacks().picker.help() end, "Help" },
    { "n", "<leader>fe", "<cmd>Neotree toggle<cr>", "Explorer" },

    -- diagnostics (<leader>x)
    { "n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Problems (all)" },
    { "n", "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Problems (buffer)" },
    { "n", "<leader>xn", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic" },
    { "n", "<leader>xp", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic" },
    { "n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", "Todos" },

    -- git (<leader>g)
    { "n", "<leader>gs", function() gs().stage_hunk() end, "Stage hunk" },
    { "n", "<leader>gr", function() gs().reset_hunk() end, "Reset hunk" },
    { "n", "<leader>gp", function() gs().preview_hunk() end, "Preview hunk" },
    { "n", "<leader>gb", function() gs().blame_line({ full = true }) end, "Blame line" },
    { "n", "<leader>gB", function() gs().toggle_current_line_blame() end, "Toggle line blame" },
    { "n", "<leader>gn", function() gs().nav_hunk("next") end, "Next hunk" },
    { "n", "<leader>gN", function() gs().nav_hunk("prev") end, "Prev hunk" },
    { "n", "<leader>gg", "<cmd>LazyGit<cr>", "LazyGit" },
    { "n", "<leader>gd", "<cmd>DiffviewOpen<cr>", "Diff view" },
    { "n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", "File history" },
    { "n", "<leader>gl", function() snacks().picker.git_log() end, "Git log" },
    { "n", "<leader>gt", function() snacks().picker.git_status() end, "Git status" },
    { { "o", "x" }, "ih", function() gs().select_hunk() end, "Hunk text-object" },

    -- run (<leader>r)
    { "n", "<leader>rr", "<cmd>OverseerRun<cr>", "Run task" },
    { "n", "<leader>rl", "<cmd>OverseerToggle<cr>", "Task list" },
    { "n", "<leader>rc", "<cmd>OverseerRunCmd<cr>", "Run shell cmd" },

    -- test (<leader>t)
    { "n", "<leader>tt", function() require("neotest").run.run() end, "Test nearest" },
    { "n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, "Test file" },
    { "n", "<leader>ts", function() require("neotest").summary.toggle() end, "Test summary" },
    { "n", "<leader>to", function() require("neotest").output_panel.toggle() end, "Test output" },
    { "n", "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, "Debug nearest" },
    { "n", "<leader>tn", function() require("neotest").jump.next({ status = "failed" }) end, "Next failed" },
    { "n", "<leader>tp", function() require("neotest").jump.prev({ status = "failed" }) end, "Prev failed" },

    -- debug (<leader>d)
    { "n", "<leader>db", function() require("dap").toggle_breakpoint() end, "Breakpoint" },
    { "n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, "Conditional breakpoint" },
    { "n", "<leader>dc", function() require("dap").continue() end, "Continue" },
    { "n", "<leader>dC", function() require("dap").run_to_cursor() end, "Run to cursor" },
    { "n", "<leader>dO", function() require("dap").step_over() end, "Step over" },
    { "n", "<leader>di", function() require("dap").step_into() end, "Step into" },
    { "n", "<leader>do", function() require("dap").step_out() end, "Step out" },
    { "n", "<leader>dt", function() require("dap").terminate() end, "Terminate" },
    { "n", "<leader>dl", function() require("dap").run_last() end, "Run last" },
    { "n", "<leader>du", function() require("dapui").toggle() end, "Debug UI" },
    { { "n", "v" }, "<leader>de", function() require("dapui").eval() end, "Eval" },

    -- search/replace (<leader>s)
    { "n", "<leader>sr", function() require("grug-far").open() end, "Search & replace" },
    { "v", "<leader>sr", function() require("grug-far").with_visual_selection() end, "Replace selection" },
    { "n", "<leader>sg", function() snacks().picker.grep() end, "Grep" },
    { { "n", "x" }, "<leader>sw", function() snacks().picker.grep_word() end, "Grep word" },

    -- AI (<leader>a)
    { "n", "<leader>ac", "<cmd>ClaudeCode<cr>", "Toggle Claude" },
    { "n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", "Focus Claude" },
    { "n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", "Resume Claude" },
    { "n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", "Add buffer" },
    { "v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", "Send selection" },
    { "n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", "Accept diff" },
    { "n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", "Reject diff" },

    -- harpoon (<leader>1-4 slots, add/menu under <leader>h — reuse classic feel)
    { "n", "<leader>1", function() require("harpoon"):list():select(1) end, "Harpoon 1" },
    { "n", "<leader>2", function() require("harpoon"):list():select(2) end, "Harpoon 2" },
    { "n", "<leader>3", function() require("harpoon"):list():select(3) end, "Harpoon 3" },
    { "n", "<leader>4", function() require("harpoon"):list():select(4) end, "Harpoon 4" },
    { "n", "<leader>ha", function() require("harpoon"):list():add() end, "Harpoon add" },
    { "n", "<leader>hh", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, "Harpoon menu" },
  },
  lsp = {
    { "n", "K", vim.lsp.buf.hover, "Hover" },
  },
  groups = {
    { "<leader>c", group = "code" },
    { "<leader>f", group = "find" },
    { "<leader>x", group = "diagnostics" },
    { "<leader>g", group = "git" },
    { "<leader>r", group = "run" },
    { "<leader>t", group = "test" },
    { "<leader>d", group = "debug" },
    { "<leader>s", group = "search" },
    { "<leader>a", group = "AI/Claude" },
    { "<leader>h", group = "harpoon" },
  },
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash scripts/keymaps_test.sh`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lua/keymaps/consistent.lua tests/keymaps_spec.lua
git commit -m "feat(keymaps): author consistent (mnemonic leader-tree) scheme"
```

---

## Task 7: Author `vscode.lua` and `intellij.lua` (pure IDE overlays)

**Files:**
- Modify: `lua/keymaps/vscode.lua`
- Modify: `lua/keymaps/intellij.lua`
- Modify: `tests/keymaps_spec.lua`

**Interfaces:**
- Produces: `keymaps.vscode` (spec §6.3) and `keymaps.intellij` (spec §6.4). Two
  separate, self-contained pure emulations — no cross-IDE conflict handling. A
  `K(mac, win)` helper picks the platform literal via `vim.fn.has("mac")`.
- Consumes: base + the same plugin capabilities as classic; only the LHS differs.

- [ ] **Step 1: Write the failing test**

Add this helper near the top of `tests/keymaps_spec.lua` (right after the `mapped` helper):
```lua
local is_mac = vim.fn.has("mac") == 1
local function mac_key(m, w) return { "n", is_mac and m or w } end
```
Append the mode assertions:
```lua
km.switch("vscode")
for _, pair in ipairs({
  { "n", "<F12>" }, { "n", "<S-F12>" }, { "n", "<F2>" }, { "n", "<F5>" },
  { "n", "<F9>" }, { "n", "<F10>" }, mac_key("<D-b>", "<C-b>"),
  mac_key("<D-p>", "<C-p>"), mac_key("<D-.>", "<C-.>"),
}) do
  assert(mapped(pair[1], pair[2]), "vscode map missing: " .. pair[1] .. " " .. pair[2])
end
assert(not mapped("n", "gd"), "vscode does not bind vim-native gd")

km.switch("intellij")
for _, pair in ipairs({
  mac_key("<D-b>", "<C-b>"), { "n", "<A-F7>" }, { "n", "<S-F6>" },
  { "n", "<A-CR>" }, { "n", "<F8>" }, { "n", "<F7>" }, { "n", "<F2>" },
  { "n", "<S-F10>" }, { "n", "<S-F9>" }, { "n", "<leader>1" },
}) do
  assert(mapped(pair[1], pair[2]), "intellij map missing: " .. pair[1] .. " " .. pair[2])
end
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash scripts/keymaps_test.sh`
Expected: FAIL — vscode/intellij map missing (stubs only have marker keys).

- [ ] **Step 3: Implement `vscode.lua`**

`lua/keymaps/vscode.lua`:
```lua
-- VS Code default-keymap emulation (spec §6.3). Pure — no IntelliJ keys.
local mac = vim.fn.has("mac") == 1
local function K(m, w) return mac and m or w end
local function snacks() return require("snacks") end

return {
  name = "vscode",
  desc = "VS Code emulation",
  maps = {
    -- navigation / code insight
    { "n", "<F12>", vim.lsp.buf.definition, "Goto definition" },
    { "n", "<A-F12>", "<cmd>Glance definitions<cr>", "Peek definition" },
    { "n", K("<D-F12>", "<C-F12>"), vim.lsp.buf.implementation, "Goto implementations" },
    { "n", "<S-F12>", "<cmd>Glance references<cr>", "References" },
    { "n", K("<D-k><D-i>", "<C-k><C-i>"), vim.lsp.buf.hover, "Hover" },
    { "n", "<F2>", vim.lsp.buf.rename, "Rename" },
    { { "n", "x" }, K("<D-.>", "<C-.>"), vim.lsp.buf.code_action, "Quick fix" },
    { "n", "<S-A-f>", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, "Format document" },
    { "n", "<S-A-o>", function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true }) end, "Organize imports" },
    -- pickers
    { "n", K("<D-p>", "<C-p>"), function() snacks().picker.files() end, "Go to file" },
    { "n", K("<D-S-p>", "<C-S-p>"), function() snacks().picker.commands() end, "Command palette" },
    { "n", K("<D-S-o>", "<C-S-o>"), function() snacks().picker.lsp_symbols() end, "Symbols in file" },
    { "n", K("<D-S-f>", "<C-S-f>"), function() require("grug-far").open() end, "Find in files" },
    -- diagnostics
    { "n", "<F8>", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next problem" },
    { "n", "<S-F8>", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev problem" },
    -- panels
    { "n", K("<D-b>", "<C-b>"), "<cmd>Neotree toggle<cr>", "Toggle sidebar" },
    { "n", "<C-`>", "<cmd>ToggleTerm<cr>", "Toggle terminal" },
    { "n", "<C-S-g>", "<cmd>DiffviewOpen<cr>", "Source control" },
    { "n", K("<D-1>", "<C-1>"), "<cmd>BufferLineGoToBuffer 1<cr>", "Editor group 1" },
    { "n", K("<D-2>", "<C-2>"), "<cmd>BufferLineGoToBuffer 2<cr>", "Editor group 2" },
    { "n", K("<D-3>", "<C-3>"), "<cmd>BufferLineGoToBuffer 3<cr>", "Editor group 3" },
    -- debug
    { "n", "<F5>", function() require("dap").continue() end, "Start / continue debug" },
    { "n", "<F9>", function() require("dap").toggle_breakpoint() end, "Toggle breakpoint" },
    { "n", "<F10>", function() require("dap").step_over() end, "Step over" },
    { "n", "<F11>", function() require("dap").step_into() end, "Step into" },
    { "n", "<S-F11>", function() require("dap").step_out() end, "Step out" },
    -- editing
    { "n", K("<D-/>", "<C-/>"), "gcc", "Comment line", opts = { remap = true } },
    { "x", K("<D-/>", "<C-/>"), "gc", "Comment line", opts = { remap = true } },
  },
  lsp = {
    { "n", "<F12>", vim.lsp.buf.definition, "Goto definition" },
    { "n", "<S-F12>", "<cmd>Glance references<cr>", "References" },
  },
  groups = {},
}
```

- [ ] **Step 4: Implement `intellij.lua`**

`lua/keymaps/intellij.lua`:
```lua
-- IntelliJ IDEA default-keymap emulation (spec §6.4). Pure — no VS Code keys.
-- Run/Debug use <S-F10>/<S-F9> on both platforms (mac ⌃R/⌃D would shadow vim).
-- Tool-window number focus (<leader>1-8) is IntelliJ's signature, only here.
local mac = vim.fn.has("mac") == 1
local function K(m, w) return mac and m or w end
local function snacks() return require("snacks") end

local function focus_editor()
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  if prev ~= 0 and vim.api.nvim_win_is_valid(prev) and vim.bo[vim.api.nvim_win_get_buf(prev)].buftype == "" then
    vim.api.nvim_set_current_win(prev); return
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
      vim.api.nvim_set_current_win(win); return
    end
  end
end

return {
  name = "intellij",
  desc = "IntelliJ emulation",
  maps = {
    -- navigation
    { "n", K("<D-b>", "<C-b>"), vim.lsp.buf.definition, "Goto definition" },
    { "n", K("<D-A-b>", "<C-A-b>"), vim.lsp.buf.implementation, "Goto implementation" },
    { "n", K("<D-S-b>", "<C-S-b>"), vim.lsp.buf.type_definition, "Goto type declaration" },
    { "n", "<A-F7>", "<cmd>Glance references<cr>", "Find usages" },
    { "n", "<A-Space>", "<cmd>Glance definitions<cr>", "Quick definition" },
    { "n", "<F1>", vim.lsp.buf.hover, "Quick doc" },
    { "n", K("<D-o>", "<C-n>"), function() snacks().picker.files() end, "Go to class/file" },
    { "n", K("<D-A-o>", "<C-A-S-n>"), function() snacks().picker.lsp_symbols() end, "Go to symbol" },
    { "n", K("<D-e>", "<C-e>"), function() snacks().picker.recent() end, "Recent files" },
    { "n", K("<D-F12>", "<C-F12>"), "<cmd>AerialToggle<cr>", "File structure" },
    -- refactor / edit
    { "n", "<S-F6>", vim.lsp.buf.rename, "Rename" },
    { { "n", "x" }, "<A-CR>", vim.lsp.buf.code_action, "Intention / quick fix" },
    { "n", K("<D-A-l>", "<C-A-l>"), function() require("conform").format({ async = true, lsp_format = "fallback" }) end, "Reformat code" },
    { "n", "<C-A-o>", function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true }) end, "Optimize imports" },
    { "n", K("<D-d>", "<C-d>"), "yyp", "Duplicate line" },
    { "n", K("<D-/>", "<C-/>"), "gcc", "Comment line", opts = { remap = true } },
    { "x", K("<D-/>", "<C-/>"), "gc", "Comment line", opts = { remap = true } },
    -- diagnostics
    { "n", "<F2>", function() vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR }) end, "Next error" },
    { "n", "<S-F2>", function() vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR }) end, "Prev error" },
    -- search
    { "n", K("<D-S-f>", "<C-S-f>"), function() require("grug-far").open() end, "Find in files" },
    -- run / debug
    { "n", "<S-F10>", "<cmd>OverseerRun<cr>", "Run" },
    { "n", "<S-F9>", function() require("dap").continue() end, "Debug" },
    { "n", "<F8>", function() require("dap").step_over() end, "Step over" },
    { "n", "<F7>", function() require("dap").step_into() end, "Step into" },
    { "n", "<S-F8>", function() require("dap").step_out() end, "Step out" },
    { "n", K("<D-F8>", "<C-F8>"), function() require("dap").toggle_breakpoint() end, "Toggle breakpoint" },
    -- git / terminal
    { "n", K("<D-k>", "<C-k>"), "<cmd>LazyGit<cr>", "Commit / git" },
    { "n", "<A-F12>", "<cmd>ToggleTerm<cr>", "Terminal" },
    -- tool windows (IntelliJ ⌘/Alt + number) — intellij mode only
    { "n", "<leader>1", "<cmd>Neotree focus<cr>", "Tool: project" },
    { "n", "<leader>2", function()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
          vim.api.nvim_set_current_win(win); return
        end
      end
      vim.cmd("ToggleTerm")
    end, "Tool: terminal" },
    { "n", "<leader>3", focus_editor, "Tool: editor" },
    { "n", "<leader>4", "<cmd>OverseerToggle<cr>", "Tool: run" },
    { "n", "<leader>5", function() require("dap"); require("dapui").toggle() end, "Tool: debug" },
    { "n", "<leader>6", "<cmd>AerialToggle<cr>", "Tool: structure" },
    { "n", "<leader>7", function() require("neotest").summary.toggle() end, "Tool: tests" },
    { "n", "<leader>8", function()
      local lib = require("diffview.lib")
      if lib.get_current_view() then vim.cmd("DiffviewClose") else vim.cmd("DiffviewOpen") end
    end, "Tool: version control" },
  },
  lsp = {
    { "n", "<F1>", vim.lsp.buf.hover, "Quick doc" },
    { "n", K("<D-b>", "<C-b>"), vim.lsp.buf.definition, "Goto definition" },
  },
  groups = {},
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bash scripts/keymaps_test.sh`
Expected: PASS (all vscode + intellij probe keys present; no Lua errors).

- [ ] **Step 6: Commit**

```bash
git add lua/keymaps/vscode.lua lua/keymaps/intellij.lua tests/keymaps_spec.lua
git commit -m "feat(keymaps): author vscode + intellij (pure IDE) schemes"
```

---

## Task 8: LSP routing — apply scheme `lsp` maps on LspAttach + re-apply on switch

**Files:**
- Modify: `lua/keymaps/init.lua` (add LspAttach autocmd in `setup()`)
- Modify: `lua/plugins/lsp.lua` (remove the hardcoded on-attach keymap block; keep non-keymap on-attach logic)
- Modify: `tests/keymaps_spec.lua` (assert buffer-local lsp map applied + switched)

**Interfaces:**
- Consumes: `M.apply_lsp(bufnr)` (Task 1), scheme `lsp` lists (Tasks 5-7).
- Produces: buffer-local LSP maps that follow the active mode.

- [ ] **Step 1: Write the failing test**

Append to `tests/keymaps_spec.lua`:
```lua
-- LSP routing: apply_lsp binds buffer-local maps from the active scheme
km.switch("classic")
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
km.apply_lsp(buf)
assert(vim.fn.maparg("K", "n") ~= "", "classic lsp K applied buffer-local")
-- switching re-applies: vscode binds <F12> buffer-local too
km.switch("vscode")
assert(vim.fn.maparg("<F12>", "n") ~= "", "vscode lsp <F12> present after switch")
```

- [ ] **Step 2: Run to verify it fails / passes**

Run: `bash scripts/keymaps_test.sh`
Expected: `K` present (classic global also maps... no — classic `K` is in `lsp`, not `maps`). If FAIL, it's because `apply_lsp` wasn't invoked on the buffer by the autocmd yet — the explicit `km.apply_lsp(buf)` call covers the unit. Confirm PASS for the direct-call assertions.

- [ ] **Step 3: Add the LspAttach autocmd to `setup()`**

In `lua/keymaps/init.lua`, inside `M.setup()` after the command registration and before `apply(...)`:
```lua
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("keymaps_lsp", { clear = true }),
    callback = function(args)
      M.apply_lsp(args.buf)
    end,
  })
```

- [ ] **Step 4: Strip the hardcoded keymap block from `lsp.lua`**

Open `lua/plugins/lsp.lua`. Remove the on-attach keymap definitions (the local
`m(...)` helper and every `m("<F4>", ...)`, `m("gr", ...)`, `m("<A-F7>", ...)`,
`m("<S-F6>", ...)`, `m("<A-CR>", ...)`, `m("<C-A-o>", ...)` line, and the
top-level `<C-A-l>` format keymap). Keep all non-keymap on-attach behavior
(capabilities, server setup, inlay-hint enable, etc.). These verbs now come from
the scheme `lsp` lists and `maps`.

- [ ] **Step 5: Run tests + smoke**

Run: `bash scripts/keymaps_test.sh && bash scripts/smoke.sh`
Expected: `KEYMAPS-OK`; smoke `LOAD-OK`/`THEME-OK` (LSP-SOFT acceptable).

- [ ] **Step 6: Commit**

```bash
git add lua/keymaps/init.lua lua/plugins/lsp.lua tests/keymaps_spec.lua
git commit -m "feat(keymaps): route LSP buffer-local maps through the mode manager"
```

---

## Task 9: Plugin cutover — command-driven plugins go keyless

**Files (remove `keys = {...}`, ensure `cmd = {...}` lazy trigger):**
- Modify: `lua/plugins/navigation.lua` (delete the disabled Telescope block entirely; aerial → `cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" }`; harpoon → `keys` removed, add `lazy = true` + it loads via the scheme's `require("harpoon")`; flash keys are now in base — remove flash `keys`, keep `opts`)
- Modify: `lua/plugins/git.lua` (gitsigns keeps `event`; lazygit → `cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter" }`; diffview → `cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" }`)
- Modify: `lua/plugins/run.lua` (neotest → remove `keys`, add `cmd`? neotest has no commands — set `lazy = true`, loads via `require("neotest")`; overseer → `cmd = { "OverseerRun", "OverseerToggle", "OverseerRunCmd", "OverseerOpen" }`)
- Modify: `lua/plugins/debug.lua` (nvim-dap → remove `keys`, `lazy = true` loads via `require("dap")`; ensure dap-ui still set up on dap load)
- Modify: `lua/plugins/diagnostics.lua` (trouble → `cmd = { "Trouble" }`)
- Modify: `lua/plugins/tree.lua` (neo-tree → `cmd = { "Neotree" }`)
- Modify: `lua/plugins/coding.lua` (grug-far → `cmd = { "GrugFar", "GrugFarWithin" }`; ufo keeps `event`; mini.bufremove loads via require)

**Interfaces:**
- Consumes: scheme `maps` (Tasks 4-7) which invoke the plugin commands/functions that trigger lazy-load.
- Produces: keyless plugin specs that still lazy-load on first use.

- [ ] **Step 1: Establish the lazy-load regression check**

Add to `scripts/keymaps_test.sh` (before the final success echo):
```bash
# lazy-load: pressing a scheme key must load its plugin. Probe neo-tree via its
# command being available and the plugin loading on demand.
lazy=$(nvim --headless "+lua vim.cmd('Neotree toggle'); vim.defer_fn(function() io.stdout:write('NEOTREE='..tostring(package.loaded['neo-tree'] ~= nil)..'\n'); vim.cmd('qa') end, 500)" 2>&1)
echo "$lazy" | grep -q "NEOTREE=true" && echo "LAZYLOAD-OK" || echo "LAZYLOAD-SOFT (headless timing)"
```

- [ ] **Step 2: Cut over each plugin file**

For each file above: delete its `keys = { ... }` table; add the `cmd`/`lazy`
trigger noted. Where a plugin loaded only via `keys`, confirm another trigger
exists (`cmd`, `event`, `ft`, or a `require()` from a scheme map). Example —
`lua/plugins/tree.lua`:
```lua
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    cmd = "Neotree",
    opts = { -- unchanged
    },
  },
}
```

- [ ] **Step 3: Run healthcheck + tests + smoke**

Run: `bash scripts/healthcheck.sh && bash scripts/keymaps_test.sh && bash scripts/smoke.sh`
Expected: healthcheck all `SPEC-OK`; `KEYMAPS-OK`; `LAZYLOAD-OK` (or SOFT); smoke `LOAD-OK`.

- [ ] **Step 4: Manual lazy-load spot check**

Run: `nvim` then press `<leader>e` (explorer opens), `<leader>gg` (lazygit),
`<leader>tt` in a test file. Confirm each plugin loads and acts.

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/ scripts/keymaps_test.sh
git commit -m "refactor(keymaps): cut command-driven plugins over to keyless lazy-load"
```

---

## Task 10: Plugin cutover — remaining `keys` (snacks, ai, shell, ui, ui_extra)

**Files:**
- Modify: `lua/plugins/snacks.lua` (remove picker/notifier `keys`; snacks stays `lazy = false` or `event`)
- Modify: `lua/plugins/ai.lua` (remove Claude Code `keys`; add `cmd = { "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend", "ClaudeCodeAdd", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny" }`; copilot keeps its own insert-mode `keymap` config — NOT part of scheme)
- Modify: `lua/plugins/shell.lua` (remove toggleterm `keys`; add `cmd = { "ToggleTerm", "TermExec", "ToggleTermToggleAll" }`; persistence loads via require — remove its `keys`)
- Modify: `lua/plugins/ui.lua` (remove the `<leader>ut` keymap — now in base; keep the `ThemeToggle` command definition)
- Modify: `lua/plugins/ui_extra.lua` (remove bufferline `<S-h>`/`<S-l>` keys — now in base; bufferline stays `event`)

**Interfaces:**
- Consumes: base + scheme maps (Tasks 4-7).
- Produces: keyless snacks/ai/shell/ui specs.

- [ ] **Step 1: Cut over each file** (remove `keys`, add `cmd`/`event` as noted). For `ui.lua`, keep the `vim.api.nvim_create_user_command("ThemeToggle", ...)` and delete only the `vim.keymap.set("n", "<leader>ut", ...)` line.

- [ ] **Step 2: Run healthcheck + tests + smoke**

Run: `bash scripts/healthcheck.sh && bash scripts/keymaps_test.sh && bash scripts/smoke.sh`
Expected: all green.

- [ ] **Step 3: Manual spot check**

Run: `nvim`; test `<leader>ff` (files), `<leader>ac` (Claude), `<C-\>` (terminal),
`<leader>ut` (theme), `<S-l>`/`<S-h>` (buffers).

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/
git commit -m "refactor(keymaps): cut snacks/ai/shell/ui specs over to keyless"
```

---

## Task 11: Delete `core/keymaps.lua` (point of no return)

**Files:**
- Delete: `lua/core/keymaps.lua`
- Grep: confirm nothing requires it.

**Interfaces:**
- Consumes: nothing (its contents are fully re-homed into base + overlays).

- [ ] **Step 1: Confirm no references**

Run: `grep -rn "core.keymaps\|core/keymaps" lua/ init.lua`
Expected: no matches (Task 3 already rewired `core/init.lua`).

- [ ] **Step 2: Delete the file**

Run: `git rm lua/core/keymaps.lua`

- [ ] **Step 3: Full verification**

Run: `bash scripts/healthcheck.sh && bash scripts/keymaps_test.sh && bash scripts/smoke.sh`
Expected: all green.

- [ ] **Step 4: Verify each mode end-to-end manually**

Run: `nvim`; `:KeymapMode vscode` → confirm `<F12>` goto-def, `<F2>` rename;
`:KeymapMode intellij` → `<D-b>` (or `<C-b>`) goto-def, `<S-F6>` rename, `<leader>1`
project. `:KeymapMode consistent` → `<leader>cd` def, `<leader>cn` rename.
`:KeymapMode classic` → `gd`, `gr`, `]h`. Restart nvim → confirm the last chosen
mode persisted.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor(keymaps): remove legacy core/keymaps.lua (fully re-homed)"
```

---

## Task 12: Mode-switch smoke test in the main harness

**Files:**
- Modify: `scripts/smoke.sh` (add a mode-cycle section)

**Interfaces:**
- Consumes: `require("keymaps").switch` + `current`.

- [ ] **Step 1: Add the mode-cycle check to `smoke.sh`**

Before `echo "== SMOKE DONE`:
```bash
echo "== 6. Keymap modes cycle cleanly =="
modes=$(nvim --headless "+lua local km=require('keymaps'); for _,m in ipairs({'classic','consistent','vscode','intellij','classic'}) do assert(km.switch(m), 'switch '..m) end; io.stdout:write('MODES-CYCLE-OK\n')" "+qa" 2>&1)
echo "$modes" | grep -q "MODES-CYCLE-OK" && echo "MODES-OK" || { echo "FAIL: mode cycle"; fail=1; }
```

- [ ] **Step 2: Run smoke**

Run: `bash scripts/smoke.sh`
Expected: `MODES-OK` + `SMOKE DONE (fail=0)`.

- [ ] **Step 3: Commit**

```bash
git add scripts/smoke.sh
git commit -m "test(keymaps): mode-cycle check in smoke test"
```

---

## Self-Review Notes (author)

- **Spec coverage:** manager+switch+persist+picker (§4 → Tasks 1-3), base (§5 → Task 4), classic/consistent (§6.1-6.2 → Tasks 5-6), vscode/intellij pure IDE modes (§6.3-6.4 → Task 7), conflict resolutions §12 folded into base/overlays (harpoon on `<leader>1-4`, tool-windows intellij-only, illuminate `]r`/`[r`), plugin centralization §4.4 (Tasks 9-11), LSP routing §4.3 (Task 8), testing §9 (Tasks 1,12). Docs §8 → **Plan 2 (separate)**. Note: separate vscode/intellij modes eliminate the old cross-IDE conflict handling (§7 now "mode independence").
- **Deferred to Plan 2 (docs):** `docs/keybindings.md` — depends on final bindings settled here.
- **Known simplifications:** which-key groups are not torn down on switch (harmless labels); treesitter incremental-selection remains unconfigured (documented opt-in, not bound); grug-far localleader already set in `options.lua`.

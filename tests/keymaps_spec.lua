-- Headless assertions for the keymap mode manager.
-- Run via scripts/keymaps_test.sh. Prints "KEYMAPS-TESTS-PASS" on success,
-- or aborts with an assertion error (non-zero exit) on failure.
local km = require("keymaps")

-- helper: is (mode, lhs) currently mapped globally?
local function mapped(mode, lhs) return vim.fn.maparg(lhs, mode) ~= "" end

local is_mac = vim.fn.has("mac") == 1
local function mac_key(m, w) return { "n", is_mac and m or w } end

-- ensure a clean slate: a leftover persisted mode from a prior run (or a
-- prior switch() call in this same run) must not affect the default-mode
-- assertion below.
os.remove(vim.fn.stdpath("data") .. "/keymap-mode")

-- 1. MODES and default
assert(vim.deep_equal(km.MODES, { "classic", "consistent", "vscode", "intellij" }), "MODES list")

-- 2. setup() applies base + default overlay (classic)
km.setup()
assert(km.current() == "classic", "default mode is classic, got " .. tostring(km.current()))
assert(mapped("n", "<Esc>"), "base <Esc> applied")
assert(mapped("n", "<leader>ff"), "classic marker applied")

-- base coverage (present in every mode)
for _, pair in ipairs({
  { "n", "<C-h>" },
  { "n", "<C-l>" },
  { "n", "<C-s>" },
  { "v", "<C-c>" },
  { "n", "<A-Up>" },
  { "n", "<S-l>" },
  { "n", "<S-h>" },
  { "n", "<C-\\>" },
  { "n", "<leader>ut" },
  { "n", "<leader>uh" },
  { "n", "s" },
  { "n", "<leader>wv" },
  { "n", "<leader>qs" },
}) do
  assert(mapped(pair[1], pair[2]), "base map missing: " .. pair[1] .. " " .. pair[2])
end

-- 3. switch() tears down previous overlay and applies the new one
assert(km.switch("vscode") == true, "switch to vscode returns true")
assert(km.current() == "vscode", "current is vscode")
assert(mapped("n", "<F12>"), "vscode marker applied after switch")
assert(not mapped("n", "<leader>ff"), "classic marker torn down after switch")
assert(mapped("n", "<Esc>"), "base survives switch")

-- 4. switch to consistent
assert(km.switch("consistent") == true, "switch to consistent")
assert(mapped("n", "<leader>cd"), "consistent marker applied")
assert(not mapped("n", "<F12>"), "vscode marker torn down")

-- 4b. switch to intellij applies its marker
assert(km.switch("intellij") == true, "switch to intellij")
assert(mapped("n", "<A-F7>"), "intellij marker applied")

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

-- 8. pick() is callable without throwing (headless: vim.ui.select is a no-op)
assert(pcall(function() vim.cmd("KeymapMode") end), ":KeymapMode (no arg) does not error")

-- 9. manager is initialized by core (command exists after full startup)
-- Tested separately in scripts/keymaps_test.sh via CORE-WIRED-OK check
-- (cannot assert here as spec itself calls km.setup())

km.switch("classic")
for _, pair in ipairs({
  { "n", "gd" },
  { "n", "gr" },
  { "n", "gy" },
  { "n", "gI" },
  { "n", "<leader>ca" },
  { "n", "<leader>cf" },
  { "n", "<leader>cr" },
  { "n", "]d" },
  { "n", "[d" },
  { "n", "]h" },
  { "n", "[h" },
  { "n", "<leader>ff" },
  { "n", "<leader>fg" },
  { "n", "<leader>e" },
  { "n", "<leader>gg" },
  { "n", "<leader>tt" },
  { "n", "<leader>db" },
  { "n", "<leader>xx" },
  { "n", "]t" },
  { "n", "]r" },
}) do
  assert(mapped(pair[1], pair[2]), "classic map missing: " .. pair[1] .. " " .. pair[2])
end
-- LSP routing: apply_lsp binds buffer-local maps from the active scheme
km.switch("classic")
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
km.apply_lsp(buf)
assert(vim.fn.maparg("K", "n") ~= "", "classic lsp K applied buffer-local")
-- switching re-applies: vscode binds <F12> buffer-local too
km.switch("vscode")
assert(vim.fn.maparg("<F12>", "n") ~= "", "vscode lsp <F12> present after switch")

-- 10. consistent scheme: mnemonic leader-trees (spec §6.2)
km.switch("consistent")
for _, pair in ipairs({
  -- cD/ce/xb are consistent-only lhs (classic does not bind them), so they
  -- discriminate a real consistent-only switch better than lhs classic
  -- also happens to bind (e.g. plain cd/ff/tt/db/ca/cf are mapped by both
  -- schemes, just to different actions in some cases).
  { "n", "<leader>cD" },
  { "n", "<leader>cr" },
  { "n", "<leader>cn" },
  { "n", "<leader>ca" },
  { "n", "<leader>cf" },
  { "n", "<leader>ci" },
  { "n", "<leader>cy" },
  { "n", "<leader>ck" },
  { "n", "<leader>cs" },
  { "n", "<leader>ce" },
  { "n", "<leader>xn" },
  { "n", "<leader>xp" },
  { "n", "<leader>xb" },
  { "n", "<leader>db" },
  { "n", "<leader>gs" },
}) do
  assert(mapped(pair[1], pair[2]), "consistent map missing: " .. pair[1] .. " " .. pair[2])
end
assert(not mapped("n", "gd"), "consistent does not bind vim-native gd (torn down)")

-- 11. vscode scheme: VS Code default-keymap emulation (spec §6.3)
km.switch("vscode")
for _, pair in ipairs({
  { "n", "<F12>" },
  { "n", "<S-F12>" },
  { "n", "<F2>" },
  { "n", "<F5>" },
  { "n", "<F9>" },
  { "n", "<F10>" },
  mac_key("<D-b>", "<C-b>"),
  mac_key("<D-p>", "<C-p>"),
  mac_key("<D-.>", "<C-.>"),
}) do
  assert(mapped(pair[1], pair[2]), "vscode map missing: " .. pair[1] .. " " .. pair[2])
end
assert(not mapped("n", "gd"), "vscode does not bind vim-native gd")

-- 12. intellij scheme: IntelliJ default-keymap emulation (spec §6.4)
km.switch("intellij")
for _, pair in ipairs({
  mac_key("<D-b>", "<C-b>"),
  { "n", "<A-F7>" },
  { "n", "<S-F6>" },
  { "n", "<A-CR>" },
  { "n", "<F8>" },
  { "n", "<F7>" },
  { "n", "<F2>" },
  { "n", "<S-F10>" },
  { "n", "<S-F9>" },
  { "n", "<leader>1" },
}) do
  assert(mapped(pair[1], pair[2]), "intellij map missing: " .. pair[1] .. " " .. pair[2])
end

io.stdout:write("KEYMAPS-TESTS-PASS\n")

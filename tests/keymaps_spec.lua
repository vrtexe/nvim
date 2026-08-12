-- Headless assertions for the keymap mode manager.
-- Run via scripts/keymaps_test.sh. Prints "KEYMAPS-TESTS-PASS" on success,
-- or aborts with an assertion error (non-zero exit) on failure.
local km = require("keymaps")

-- helper: is (mode, lhs) currently mapped globally?
local function mapped(mode, lhs) return vim.fn.maparg(lhs, mode) ~= "" end

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

-- 8. pick() is callable without throwing (headless: vim.ui.select is a no-op)
assert(pcall(function() vim.cmd("KeymapMode") end), ":KeymapMode (no arg) does not error")

io.stdout:write("KEYMAPS-TESTS-PASS\n")

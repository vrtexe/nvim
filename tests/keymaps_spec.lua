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
assert(mapped("n", "<F5>"), "vscode marker applied after switch")
assert(not mapped("n", "<leader>ghs"), "classic-only marker torn down after switch")
assert(mapped("n", "<Esc>"), "base survives switch")

-- 4. switch to consistent
assert(km.switch("consistent") == true, "switch to consistent")
assert(mapped("n", "<leader>xn"), "consistent marker applied")
assert(not mapped("n", "<F5>"), "vscode marker torn down")

-- 4b. switch to intellij applies its marker
assert(km.switch("intellij") == true, "switch to intellij")
assert(mapped("n", "<S-F10>"), "intellij marker applied")

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
  { "n", "<leader>cf" },
  { "n", "<leader>cd" },
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

-- LSP routing: apply_lsp binds the shared navigation (base) plus the scheme's
-- own LSP keys buffer-local; a switch replaces the scheme's keys.
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
km.apply_lsp(buf)
local function buf_mapped(lhs) return vim.fn.maparg(lhs, "n", false, true).buffer == 1 end
for _, lhs in ipairs({ "gd", "gD", "grr", "K", "<leader>ca", "<leader>cr", "gI", "gy" }) do
  assert(buf_mapped(lhs), "classic lsp map missing: " .. lhs)
end
km.switch("vscode")
assert(buf_mapped("<F12>"), "vscode lsp <F12> applied after switch")
assert(buf_mapped("gd"), "shared gd survives switch")
assert(not buf_mapped("gy"), "classic-only lsp gy removed after switch to vscode")

-- 10. consistent scheme: mnemonic leader-trees (spec §6.2), same <leader>c
-- letters as classic, no navigation in the tree
km.switch("consistent")
for _, pair in ipairs({
  { "n", "<leader>cf" },
  { "n", "<leader>cs" },
  { "n", "<leader>cd" },
  { "n", "<leader>xn" },
  { "n", "<leader>xp" },
  { "n", "<leader>xb" },
  { "n", "<leader>db" },
  { "n", "<leader>gs" },
}) do
  assert(mapped(pair[1], pair[2]), "consistent map missing: " .. pair[1] .. " " .. pair[2])
end
assert(buf_mapped("<leader>cr") and vim.fn.maparg("<leader>cr", "n", false, true).desc == "Rename", "cr is rename")
for _, lhs in ipairs({ "<leader>cD", "<leader>cn", "<leader>cy", "<leader>ck", "<leader>ce" }) do
  assert(not mapped("n", lhs), "consistent no longer binds " .. lhs)
end

-- 11. vscode scheme: VS Code chords on top of the consistent tree (spec §6.3)
km.switch("vscode")
for _, pair in ipairs({
  { "n", "<F5>" },
  { "n", "<F9>" },
  { "n", "<F10>" },
  mac_key("<D-b>", "<C-b>"),
  mac_key("<D-p>", "<C-p>"),
  { "n", "<leader>tt" },
  { "n", "<leader>gs" },
  { "n", "<leader>ac" },
}) do
  assert(mapped(pair[1], pair[2]), "vscode map missing: " .. pair[1] .. " " .. pair[2])
end
for _, lhs in ipairs({ "<F12>", "<S-F12>", "<F2>", is_mac and "<D-.>" or "<C-.>" }) do
  assert(buf_mapped(lhs), "vscode lsp map missing: " .. lhs)
end
assert(not mapped("n", "<A-F7>"), "vscode does not bind IntelliJ keys")

-- 12. intellij scheme: IntelliJ chords on top of the consistent tree (spec §6.4)
km.switch("intellij")
for _, pair in ipairs({
  { "n", "<F8>" },
  { "n", "<F7>" },
  { "n", "<F2>" },
  { "n", "<S-F10>" },
  { "n", "<S-F9>" },
  { "n", "<leader>tt" },
  { "n", "<leader>ac" },
}) do
  assert(mapped(pair[1], pair[2]), "intellij map missing: " .. pair[1] .. " " .. pair[2])
end
for _, lhs in ipairs({ is_mac and "<D-b>" or "<C-b>", "<A-F7>", "<S-F6>", "<A-CR>" }) do
  assert(buf_mapped(lhs), "intellij lsp map missing: " .. lhs)
end
assert(vim.fn.maparg("<leader>1", "n", false, true).desc == "Tool: project", "tool windows replace harpoon slots")
assert(not mapped("n", "<F5>"), "intellij does not bind VS Code keys")

-- 13. No (mode, lhs) twice in one layer, and no key that is also the start of a
-- longer one (that makes Neovim wait timeoutlen, the old bare `gr` bug).
local function raw(lhs) return vim.keycode((lhs:gsub("<[Ll]eader>", vim.g.mapleader))) end
for _, name in ipairs(km.MODES) do
  km.switch(name)
  km.apply_lsp(buf)
  local live = {}
  for _, mode in ipairs({ "n", "x", "o" }) do
    live[mode] = {}
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
      live[mode][#live[mode] + 1] = m.lhsraw
    end
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
      live[mode][#live[mode] + 1] = m.lhsraw
    end
  end
  for _, layer in ipairs(km.layers(name)) do
    local seen = {}
    for _, entry in ipairs(vim.list_extend(vim.list_extend({}, layer.maps), layer.lsp or {})) do
      local modes = type(entry[1]) == "table" and entry[1] or { entry[1] }
      for _, mode in ipairs(modes) do
        local key = mode .. " " .. entry[2]
        assert(not seen[key], name .. "/" .. layer.name .. ": duplicate " .. key)
        seen[key] = true
        local r = raw(entry[2])
        for _, other in ipairs(live[mode] or {}) do
          assert(
            other == r or other:sub(1, #r) ~= r,
            name .. "/" .. layer.name .. ": " .. key .. " is a prefix of " .. vim.fn.keytrans(other)
          )
        end
      end
    end
  end
end

io.stdout:write("KEYMAPS-TESTS-PASS\n")

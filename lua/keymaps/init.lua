local M = {}

M.MODES = { "classic", "consistent", "vscode", "intellij" }
local STATE_FILE = vim.fn.stdpath("data") .. "/keymap-mode"

M._active = nil
M._global = {} -- list of { mode, lhs } applied globally (for teardown)
M._lsp = {} -- active scheme's lsp spec (list of entries)
M._lsp_bufs = {} -- bufnr -> list of { mode, lhs } applied buffer-local

local function is_mode(name) return vim.tbl_contains(M.MODES, name) end

local function base() return require("keymaps.base") end

local function overlay(name) return require("keymaps." .. name) end

-- Apply a list of { mode, lhs, rhs, desc, opts? } entries. Record each
-- concrete (mode, lhs) pair into `sink` for later teardown. `extra` merges
-- into opts (e.g. { buffer = bufnr }).
local function apply_maps(list, sink, extra)
  for _, m in ipairs(list) do
    local mode, lhs, rhs, desc = m[1], m[2], m[3], m[4]
    local opts = vim.tbl_extend("force", { desc = desc, silent = true }, m.opts or {}, extra or {})
    local ok, err = pcall(vim.keymap.set, mode, lhs, rhs, opts)
    if not ok then
      vim.notify(
        "KeymapMode: failed to set [" .. tostring(mode) .. "] " .. tostring(lhs) .. ": " .. tostring(err),
        vim.log.levels.WARN
      )
    end
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
  if not groups or vim.tbl_isempty(groups) then return end
  local ok, wk = pcall(require, "which-key")
  if ok and wk.add then pcall(wk.add, groups) end
end

-- Apply the active scheme's LSP maps to a buffer (buffer-local). Records the
-- pairs so a mode switch can remove them. Public so the LspAttach autocmd
-- (Task 8) and tests can call it.
function M.apply_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  -- remove any previously-applied lsp maps in this buffer first
  if M._lsp_bufs[bufnr] then del_maps(M._lsp_bufs[bufnr], { buffer = bufnr }) end
  M._lsp_bufs[bufnr] = {}
  apply_maps(M._lsp, M._lsp_bufs[bufnr], { buffer = bufnr })
end

-- Layers applied for a mode, in order: base, the overlay it extends (if any),
-- then the overlay itself. Later layers win on the same {mode, lhs}.
local function layers(name)
  local ov = overlay(name)
  local list = { base() }
  if ov.extends then list[#list + 1] = overlay(ov.extends) end
  list[#list + 1] = ov
  return list
end

M.layers = layers

local function apply(name)
  M._global = {}
  M._lsp = {}
  for _, layer in ipairs(layers(name)) do
    apply_maps(layer.maps, M._global)
    vim.list_extend(M._lsp, layer.lsp or {})
    register_groups(layer.groups)
  end
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
  if not f then return nil end
  local s = (f:read("*a") or ""):gsub("^%s+", ""):gsub("%s+$", "")
  f:close()
  return is_mode(s) and s or nil
end

function M.current() return M._active end

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
  local current = M._active or "?"
  local ok, Snacks = pcall(require, "snacks")
  if ok and Snacks and Snacks.picker then
    Snacks.picker.select(M.MODES, {
      prompt = "Keymap mode (current: " .. current .. ")",
      format_item = function(item) return item == current and (item .. "  (current)") or item end,
    }, function(choice)
      if choice then M.switch(choice) end
    end)
  else
    vim.ui.select(M.MODES, { prompt = "Keymap mode (current: " .. current .. ")" }, function(choice)
      if choice then M.switch(choice) end
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
    complete = function() return M.MODES end,
    desc = "Switch keybinding mode",
  })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("keymaps_lsp", { clear = true }),
    callback = function(args) M.apply_lsp(args.buf) end,
  })
  apply(read_persisted() or "classic")
end

return M

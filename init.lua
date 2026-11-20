require("core") -- options + keymaps (both homes)

if not vim.g.vscode then -- TERMINAL HOME ONLY
  require("config.lazy")
end

vim.g.neovide_cursor_trail_size = 0.0
vim.g.neovide_cursor_animation_length = 0.1

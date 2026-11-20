require("core.options")
require("core.autocmds")
if not vim.g.vscode then require("keymaps").setup() end

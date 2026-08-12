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

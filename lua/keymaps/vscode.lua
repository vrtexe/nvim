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

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
    {
      "n",
      "<S-A-f>",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      "Format document",
    },
    {
      "n",
      "<S-A-o>",
      function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true }) end,
      "Organize imports",
    },
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

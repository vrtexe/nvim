-- IntelliJ IDEA default-keymap emulation (spec §6.4). Pure — no VS Code keys.
-- Run/Debug use <S-F10>/<S-F9> on both platforms (mac ⌃R/⌃D would shadow vim).
-- Tool-window number focus (<leader>1-8) is IntelliJ's signature, only here.
local mac = vim.fn.has("mac") == 1
local function K(m, w) return mac and m or w end
local function snacks() return require("snacks") end

local function focus_editor()
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  if prev ~= 0 and vim.api.nvim_win_is_valid(prev) and vim.bo[vim.api.nvim_win_get_buf(prev)].buftype == "" then
    vim.api.nvim_set_current_win(prev)
    return
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
      vim.api.nvim_set_current_win(win)
      return
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
    {
      "n",
      K("<D-A-l>", "<C-A-l>"),
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      "Reformat code",
    },
    {
      "n",
      "<C-A-o>",
      function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true }) end,
      "Optimize imports",
    },
    { "n", K("<D-d>", "<C-d>"), "yyp", "Duplicate line" },
    { "n", K("<D-/>", "<C-/>"), "gcc", "Comment line", opts = { remap = true } },
    { "x", K("<D-/>", "<C-/>"), "gc", "Comment line", opts = { remap = true } },
    -- diagnostics
    {
      "n",
      "<F2>",
      function() vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR }) end,
      "Next error",
    },
    {
      "n",
      "<S-F2>",
      function() vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR }) end,
      "Prev error",
    },
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
    {
      "n",
      "<leader>2",
      function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
            vim.api.nvim_set_current_win(win)
            return
          end
        end
        vim.cmd("ToggleTerm")
      end,
      "Tool: terminal",
    },
    { "n", "<leader>3", focus_editor, "Tool: editor" },
    { "n", "<leader>4", "<cmd>OverseerToggle<cr>", "Tool: run" },
    {
      "n",
      "<leader>5",
      function()
        require("dap")
        require("dapui").toggle()
      end,
      "Tool: debug",
    },
    { "n", "<leader>6", "<cmd>AerialToggle<cr>", "Tool: structure" },
    { "n", "<leader>7", function() require("neotest").summary.toggle() end, "Tool: tests" },
    {
      "n",
      "<leader>8",
      function()
        local lib = require("diffview.lib")
        if lib.get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      "Tool: version control",
    },
  },
  lsp = {
    { "n", "<F1>", vim.lsp.buf.hover, "Quick doc" },
    { "n", K("<D-b>", "<C-b>"), vim.lsp.buf.definition, "Goto definition" },
  },
  groups = {},
}

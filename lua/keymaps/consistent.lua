-- Mnemonic leader-tree overlay (spec §6.2). One rule: <leader> + category + verb.
-- Every action is discoverable by pressing the category prefix (which-key shows
-- the tree). `cr` = references (read-heavy), `cn` = rename.
local function snacks() return require("snacks") end
local function gs() return require("gitsigns") end

return {
  name = "consistent",
  desc = "Mnemonic leader-trees",
  maps = {
    -- code (<leader>c)
    { "n", "<leader>cd", vim.lsp.buf.definition, "Definition" },
    { "n", "<leader>cD", vim.lsp.buf.declaration, "Declaration" },
    { "n", "<leader>ci", vim.lsp.buf.implementation, "Implementation" },
    { "n", "<leader>cy", vim.lsp.buf.type_definition, "Type definition" },
    { "n", "<leader>cr", "<cmd>Glance references<cr>", "References" },
    { "n", "<leader>cn", vim.lsp.buf.rename, "Rename" },
    { { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action" },
    {
      "n",
      "<leader>cf",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      "Format",
    },
    {
      "n",
      "<leader>co",
      function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true }) end,
      "Organize imports",
    },
    { "n", "<leader>ck", vim.lsp.buf.hover, "Hover" },
    { "n", "<leader>cs", function() snacks().picker.lsp_symbols() end, "Symbols / outline" },
    { "n", "<leader>ce", vim.diagnostic.open_float, "Line diagnostics" },
    { "n", "<leader>cI", function() snacks().picker.lsp_incoming_calls() end, "Incoming calls" },
    { "n", "<leader>cO", function() snacks().picker.lsp_outgoing_calls() end, "Outgoing calls" },

    -- find (<leader>f)
    { "n", "<leader>ff", function() snacks().picker.files() end, "Files" },
    { "n", "<leader>fg", function() snacks().picker.grep() end, "Grep" },
    { "n", "<leader>fr", function() snacks().picker.recent() end, "Recent" },
    { "n", "<leader>fb", function() snacks().picker.buffers() end, "Buffers" },
    { "n", "<leader>fp", function() snacks().picker.projects() end, "Projects" },
    { "n", "<leader>fs", function() snacks().picker.lsp_symbols() end, "Symbols" },
    { "n", "<leader>fw", function() snacks().picker.grep_word() end, "Grep word" },
    { "n", "<leader>fk", function() snacks().picker.keymaps() end, "Keymaps" },
    { "n", "<leader>fh", function() snacks().picker.help() end, "Help" },
    { "n", "<leader>fe", "<cmd>Neotree toggle<cr>", "Explorer" },

    -- diagnostics (<leader>x)
    { "n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Problems (all)" },
    { "n", "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Problems (buffer)" },
    { "n", "<leader>xn", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic" },
    { "n", "<leader>xp", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic" },
    { "n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", "Todos" },

    -- git (<leader>g)
    { "n", "<leader>gs", function() gs().stage_hunk() end, "Stage hunk" },
    { "n", "<leader>gr", function() gs().reset_hunk() end, "Reset hunk" },
    { "n", "<leader>gp", function() gs().preview_hunk() end, "Preview hunk" },
    { "n", "<leader>gb", function() gs().blame_line({ full = true }) end, "Blame line" },
    { "n", "<leader>gB", function() gs().toggle_current_line_blame() end, "Toggle line blame" },
    { "n", "<leader>gn", function() gs().nav_hunk("next") end, "Next hunk" },
    { "n", "<leader>gN", function() gs().nav_hunk("prev") end, "Prev hunk" },
    { "n", "<leader>gg", "<cmd>LazyGit<cr>", "LazyGit" },
    { "n", "<leader>gd", "<cmd>DiffviewOpen<cr>", "Diff view" },
    { "n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", "File history" },
    { "n", "<leader>gl", function() snacks().picker.git_log() end, "Git log" },
    { "n", "<leader>gt", function() snacks().picker.git_status() end, "Git status" },
    { { "o", "x" }, "ih", function() gs().select_hunk() end, "Hunk text-object" },

    -- run (<leader>r)
    { "n", "<leader>rr", "<cmd>OverseerRun<cr>", "Run task" },
    { "n", "<leader>rl", "<cmd>OverseerToggle<cr>", "Task list" },
    { "n", "<leader>rc", "<cmd>OverseerRunCmd<cr>", "Run shell cmd" },

    -- test (<leader>t)
    { "n", "<leader>tt", function() require("neotest").run.run() end, "Test nearest" },
    { "n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, "Test file" },
    { "n", "<leader>ts", function() require("neotest").summary.toggle() end, "Test summary" },
    { "n", "<leader>to", function() require("neotest").output_panel.toggle() end, "Test output" },
    { "n", "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, "Debug nearest" },
    { "n", "<leader>tn", function() require("neotest").jump.next({ status = "failed" }) end, "Next failed" },
    { "n", "<leader>tp", function() require("neotest").jump.prev({ status = "failed" }) end, "Prev failed" },

    -- debug (<leader>d)
    { "n", "<leader>db", function() require("dap").toggle_breakpoint() end, "Breakpoint" },
    {
      "n",
      "<leader>dB",
      function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
      "Conditional breakpoint",
    },
    { "n", "<leader>dc", function() require("dap").continue() end, "Continue" },
    { "n", "<leader>dC", function() require("dap").run_to_cursor() end, "Run to cursor" },
    { "n", "<leader>dO", function() require("dap").step_over() end, "Step over" },
    { "n", "<leader>di", function() require("dap").step_into() end, "Step into" },
    { "n", "<leader>do", function() require("dap").step_out() end, "Step out" },
    { "n", "<leader>dt", function() require("dap").terminate() end, "Terminate" },
    { "n", "<leader>dl", function() require("dap").run_last() end, "Run last" },
    { "n", "<leader>du", function() require("dapui").toggle() end, "Debug UI" },
    { { "n", "v" }, "<leader>de", function() require("dapui").eval() end, "Eval" },

    -- search/replace (<leader>s)
    { "n", "<leader>sr", function() require("grug-far").open() end, "Search & replace" },
    { "v", "<leader>sr", function() require("grug-far").with_visual_selection() end, "Replace selection" },
    { "n", "<leader>sg", function() snacks().picker.grep() end, "Grep" },
    { { "n", "x" }, "<leader>sw", function() snacks().picker.grep_word() end, "Grep word" },

    -- AI (<leader>a)
    { "n", "<leader>ac", "<cmd>ClaudeCode<cr>", "Toggle Claude" },
    { "n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", "Focus Claude" },
    { "n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", "Resume Claude" },
    { "n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", "Add buffer" },
    { "v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", "Send selection" },
    { "n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", "Accept diff" },
    { "n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", "Reject diff" },

    -- harpoon (<leader>1-4 slots, add/menu under <leader>h — reuse classic feel)
    { "n", "<leader>1", function() require("harpoon"):list():select(1) end, "Harpoon 1" },
    { "n", "<leader>2", function() require("harpoon"):list():select(2) end, "Harpoon 2" },
    { "n", "<leader>3", function() require("harpoon"):list():select(3) end, "Harpoon 3" },
    { "n", "<leader>4", function() require("harpoon"):list():select(4) end, "Harpoon 4" },
    { "n", "<leader>ha", function() require("harpoon"):list():add() end, "Harpoon add" },
    {
      "n",
      "<leader>hh",
      function()
        local h = require("harpoon")
        h.ui:toggle_quick_menu(h:list())
      end,
      "Harpoon menu",
    },
  },
  lsp = {
    { "n", "K", vim.lsp.buf.hover, "Hover" },
  },
  groups = {
    { "<leader>c", group = "code" },
    { "<leader>f", group = "find" },
    { "<leader>x", group = "diagnostics" },
    { "<leader>g", group = "git" },
    { "<leader>r", group = "run" },
    { "<leader>t", group = "test" },
    { "<leader>d", group = "debug" },
    { "<leader>s", group = "search" },
    { "<leader>a", group = "AI/Claude" },
    { "<leader>h", group = "harpoon" },
  },
}

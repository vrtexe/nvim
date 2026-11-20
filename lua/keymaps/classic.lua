-- Vim-native / LazyVim-canonical overlay (spec §6.1). LSP verbs use 0.12
-- built-ins; picker verbs use snacks; git uses gitsigns; etc.
local function snacks() return require("snacks") end

return {
  name = "classic",
  desc = "Vim-native / LazyVim-canonical",
  maps = {
    -- Find (snacks.picker)
    { "n", "<leader>ff", function() snacks().picker.files() end, "Find files" },
    { "n", "<leader><leader>", function() snacks().picker.smart() end, "Smart find" },
    { "n", "<leader>fg", function() snacks().picker.grep() end, "Grep" },
    { "n", "<leader>fr", function() snacks().picker.recent() end, "Recent files" },
    { "n", "<leader>fb", function() snacks().picker.buffers() end, "Buffers" },
    { "n", "<leader>fp", function() snacks().picker.projects() end, "Projects" },
    { "n", "<leader>sg", function() snacks().picker.grep() end, "Grep (search)" },
    { "n", "<leader>/", function() snacks().picker.grep() end, "Grep" },
    { { "n", "x" }, "<leader>sw", function() snacks().picker.grep_word() end, "Grep word" },
    { "n", "<leader>sk", function() snacks().picker.keymaps() end, "Keymaps" },
    { "n", "<leader>sh", function() snacks().picker.help() end, "Help" },
    { "n", "<leader>sR", function() snacks().picker.resume() end, "Resume picker" },
    { "n", "<leader>sd", function() snacks().picker.diagnostics() end, "Diagnostics (picker)" },
    { "n", "<leader>ss", function() snacks().picker.lsp_symbols() end, "Document symbols" },

    -- Explorer
    { "n", "<leader>e", "<cmd>Neotree toggle<cr>", "File explorer" },

    -- Buffers
    { "n", "<leader>bd", function() require("mini.bufremove").delete(0, false) end, "Close buffer" },

    -- Diagnostics / problems
    { "n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Problems (all)" },
    { "n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Problems (buffer)" },
    { "n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic" },
    { "n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic" },
    {
      "n",
      "]e",
      function() vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR }) end,
      "Next error",
    },
    {
      "n",
      "[e",
      function() vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR }) end,
      "Prev error",
    },

    -- Code: actions that work without a language server. LSP actions and the
    -- gI/gy/gK aliases live in `lsp` below; gd/gD/grr/K come from base.
    {
      "n",
      "<leader>cf",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      "Format",
    },
    { "n", "<leader>cs", "<cmd>AerialToggle<cr>", "Symbols / outline" },
    { "n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics" },

    -- Git (hunks under <leader>gh, ops under <leader>g)
    { "n", "<leader>ghs", function() require("gitsigns").stage_hunk() end, "Stage hunk" },
    { "n", "<leader>ghr", function() require("gitsigns").reset_hunk() end, "Reset hunk" },
    { "n", "<leader>ghp", function() require("gitsigns").preview_hunk() end, "Preview hunk" },
    { "n", "<leader>ghi", function() require("gitsigns").preview_hunk_inline() end, "Preview hunk inline" },
    { "n", "<leader>ghS", function() require("gitsigns").stage_buffer() end, "Stage buffer" },
    { "n", "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end, "Blame line" },
    { "n", "<leader>ghB", function() require("gitsigns").blame() end, "Blame file" },
    { "n", "<leader>ghd", function() require("gitsigns").diffthis() end, "Diff this" },
    { "n", "]h", function() require("gitsigns").nav_hunk("next") end, "Next hunk" },
    { "n", "[h", function() require("gitsigns").nav_hunk("prev") end, "Prev hunk" },
    { { "o", "x" }, "ih", function() require("gitsigns").select_hunk() end, "Hunk text-object" },
    { "n", "<leader>gb", function() require("gitsigns").toggle_current_line_blame() end, "Toggle line blame" },
    { "n", "<leader>gg", "<cmd>LazyGit<cr>", "LazyGit" },
    { "n", "<leader>gd", "<cmd>DiffviewOpen<cr>", "Diff view" },
    { "n", "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", "File history" },
    { "n", "<leader>gs", function() require("snacks").picker.git_status() end, "Git status" },
    { "n", "<leader>gl", function() require("snacks").picker.git_log() end, "Git log" },

    -- Run / test / debug
    { "n", "<leader>rr", "<cmd>OverseerRun<cr>", "Run task" },
    { "n", "<leader>rl", "<cmd>OverseerToggle<cr>", "Task list" },
    { "n", "<leader>rc", "<cmd>OverseerRunCmd<cr>", "Run shell cmd" },
    { "n", "<leader>tt", function() require("neotest").run.run() end, "Test nearest" },
    { "n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, "Test file" },
    { "n", "<leader>ts", function() require("neotest").summary.toggle() end, "Test summary" },
    { "n", "<leader>to", function() require("neotest").output_panel.toggle() end, "Test output panel" },
    { "n", "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, "Debug nearest test" },
    { "n", "]f", function() require("neotest").jump.next({ status = "failed" }) end, "Next failed test" },
    { "n", "[f", function() require("neotest").jump.prev({ status = "failed" }) end, "Prev failed test" },
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
    { { "n", "v" }, "<leader>de", function() require("dapui").eval() end, "Eval expression" },

    -- Search & replace
    { "n", "<leader>sr", function() require("grug-far").open() end, "Search & replace (project)" },
    { "v", "<leader>sr", function() require("grug-far").with_visual_selection() end, "Replace selection" },

    -- Folds (ufo)
    { "n", "zR", function() require("ufo").openAllFolds() end, "Open all folds" },
    { "n", "zM", function() require("ufo").closeAllFolds() end, "Close all folds" },
    { "n", "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, "Peek fold" },

    -- Todo / reference nav
    { "n", "]t", function() require("todo-comments").jump_next() end, "Next todo" },
    { "n", "[t", function() require("todo-comments").jump_prev() end, "Prev todo" },
    { "n", "]r", function() require("illuminate").goto_next_reference(true) end, "Next reference" },
    { "n", "[r", function() require("illuminate").goto_prev_reference(true) end, "Prev reference" },

    -- Harpoon (slots on <leader>1-4; add/menu on <leader>h)
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
    { "n", "<leader>1", function() require("harpoon"):list():select(1) end, "Harpoon 1" },
    { "n", "<leader>2", function() require("harpoon"):list():select(2) end, "Harpoon 2" },
    { "n", "<leader>3", function() require("harpoon"):list():select(3) end, "Harpoon 3" },
    { "n", "<leader>4", function() require("harpoon"):list():select(4) end, "Harpoon 4" },

    -- AI (Claude Code)
    { "n", "<leader>ac", "<cmd>ClaudeCode<cr>", "Toggle Claude" },
    { "n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", "Focus Claude" },
    { "n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", "Resume Claude" },
    { "n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", "Add buffer to Claude" },
    { "v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", "Send selection to Claude" },
    { "n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", "Accept Claude diff" },
    { "n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", "Reject Claude diff" },
    { "n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", "Continue last session" },
    { "n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", "Select Claude model" },
  },
  lsp = {
    { { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action" },
    { "n", "<leader>cr", vim.lsp.buf.rename, "Rename" },
    {
      "n",
      "<leader>co",
      function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true }) end,
      "Organize imports",
    },
    { "n", "<leader>ci", function() require("snacks").picker.lsp_incoming_calls() end, "Incoming calls" },
    { "n", "<leader>cO", function() require("snacks").picker.lsp_outgoing_calls() end, "Outgoing calls" },
    { "n", "gI", vim.lsp.buf.implementation, "Goto implementation" },
    { "n", "gy", vim.lsp.buf.type_definition, "Goto type definition" },
    { "n", "gK", vim.lsp.buf.signature_help, "Signature help" },
  },
  groups = {
    { "<leader>c", group = "code" },
    { "<leader>f", group = "find" },
    { "<leader>s", group = "search" },
    { "<leader>g", group = "git" },
    { "<leader>gh", group = "git hunks" },
    { "<leader>x", group = "diagnostics" },
    { "<leader>r", group = "run" },
    { "<leader>t", group = "test" },
    { "<leader>d", group = "debug" },
    { "<leader>h", group = "harpoon" },
    { "<leader>a", group = "AI/Claude" },
  },
}

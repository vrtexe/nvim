return {
  -- Claude Code: talks the same WebSocket "IDE" protocol as the official VS Code
  -- extension. Runs the `claude` CLI in a terminal split; proposed edits open in a
  -- native Neovim diff you accept with :w (or <leader>aa) and reject with :q (or <leader>ad).
  -- Requires the `claude` CLI on your PATH (already installed).
  {
    "coder/claudecode.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSend",
      "ClaudeCodeAdd",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeSelectModel",
      "ClaudeCodeStatus",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude session" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last session" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      -- In neo-tree (your explorer), <leader>as mentions the file under the cursor
      { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file to Claude", ft = { "neo-tree", "netrw" } },
      -- Diff review (also available as :w to accept / :q to reject inside the diff)
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude's diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Claude's diff" },
    },
    opts = {
      terminal = {
        provider = "native", -- no snacks.nvim installed; native split works fully
        split_side = "right",
        split_width_percentage = 0.35,
      },
      diff_opts = {
        layout = "vertical", -- "vertical" | "horizontal" | "unified" (VS Code-style)
      },
    },
  },

  {
    "zbirenbaum/copilot.lua",
    enabled = false, -- fully disabled: won't load, no keychain/auth prompt.
    -- To re-enable Copilot: set enabled = true (and run :Copilot auth).
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      -- Copilot inline completions disabled for now.
      -- To re-enable: set suggestion.enabled = true and auto_trigger = true.
      suggestion = {
        enabled = false,
        auto_trigger = false,
        keymap = { accept = "<C-l>", next = "<C-]>", dismiss = "<C-e>" },
      },
      panel = { enabled = false },
    },
  },
}

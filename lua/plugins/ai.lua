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
    opts = {
      terminal = {
        provider = "auto", -- picks snacks.terminal (installed) for a nicer window
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

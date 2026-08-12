-- snacks.nvim — folke's QoL bundle. Only the modules below are enabled.
-- Loaded eagerly (lazy=false, priority=1000) because notifier/bigfile/quickfile
-- must be active from startup, and other plugins (claudecode) rely on Snacks.terminal.
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      notifier = { enabled = true }, -- toast-style notifications (LSP progress, messages)
      input = { enabled = true }, -- floating vim.ui.input prompts (rename, etc.)
      quickfile = { enabled = true }, -- render the file before plugins load
      bigfile = { enabled = true }, -- disable heavy features on very large files
      terminal = { enabled = true }, -- used as Claude Code's window provider
      picker = { enabled = true }, -- fuzzy finder (replaces Telescope)
    },
  },
}

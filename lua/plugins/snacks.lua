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
    keys = {
      -- Finder — mirrors the old Telescope bindings 1:1 so muscle memory carries over.
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader><leader>", function() Snacks.picker.files() end, desc = "Search everywhere" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      -- Cmd+Shift+N (only reaches nvim if Ghostty forwards Cmd; see docs/ghostty-keybinds.md)
      { "<D-N>", function() Snacks.picker.files() end, desc = "Find files (Cmd+Shift+N)" },
      { "<D-n>", function() Snacks.picker.files() end, desc = "Find files (Cmd+Shift+N)" },
      -- Notification history / dismiss
      { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification history" },
      { "<leader>nd", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
    },
  },
}

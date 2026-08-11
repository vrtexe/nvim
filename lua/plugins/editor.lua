return {
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "kylechui/nvim-surround", event = "VeryLazy", version = "*", opts = {} },
  { "mg979/vim-visual-multi", event = "BufReadPost" }, -- Ctrl+N multi-cursor
  { "folke/todo-comments.nvim", event = "BufReadPost", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
  -- Animated smooth scrolling for <C-d>/<C-u>/<C-f>/<C-b>/zz/gg/G etc.
  -- { "karb94/neoscroll.nvim", event = "VeryLazy", opts = { easing = "sine" } },
  -- Animated cursor trail (the caret glides between positions).
  -- Disabled: too jumpy in the terminal. To re-enable a *calm* version, set
  -- enabled = true and use the opts below (snappy, no small-move jitter).
  -- {
  --   "sphamba/smear-cursor.nvim",
  --   enabled = false,
  --   event = "VeryLazy",
  --   opts = {
  --     stiffness = 0.9,
  --     trailing_stiffness = 0.7,
  --     distance_stop_animating = 0.5, -- don't animate tiny moves (kills jitter)
  --   },
  -- },
}

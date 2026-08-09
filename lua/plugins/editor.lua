return {
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "kylechui/nvim-surround", event = "VeryLazy", version = "*", opts = {} },
  { "mg979/vim-visual-multi", event = "BufReadPost" },  -- Ctrl+N multi-cursor
  { "folke/todo-comments.nvim", event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
  -- Animated smooth scrolling for <C-d>/<C-u>/<C-f>/<C-b>/zz/gg/G etc.
  { "karb94/neoscroll.nvim", event = "VeryLazy", opts = { easing = "sine" } },
}

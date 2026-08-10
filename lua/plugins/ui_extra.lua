return {
  { "nvim-lualine/lualine.nvim", event = "VeryLazy",
    opts = { options = { theme = "auto", globalstatus = true } } },

  -- scope.nvim scopes buffers to tab pages, so each tab page acts like a VS Code
  -- "editor group": bufferline then shows only that group's tabs.
  { "tiagovla/scope.nvim", event = "VeryLazy", opts = {} },

  { "akinsho/bufferline.nvim", event = "VeryLazy",
    dependencies = { "tiagovla/scope.nvim" },
    opts = { options = { diagnostics = "nvim_lsp", separator_style = "slant" } },
    keys = {
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer/tab" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer/tab" },
    } },

  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  { "utilyre/barbecue.nvim", event = "VeryLazy",
    dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
    opts = { attach_navic = true } },
}

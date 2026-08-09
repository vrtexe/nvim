return {
  { "nvim-lualine/lualine.nvim", event = "VeryLazy",
    opts = { options = { theme = "auto", globalstatus = true } } },

  { "akinsho/bufferline.nvim", event = "VeryLazy",
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

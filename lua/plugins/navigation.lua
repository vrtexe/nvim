return {
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    opts = {},
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = true,
    config = function() require("harpoon"):setup() end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
  },

  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { theme = "hyper", config = { project = { enable = true } } },
  },
}

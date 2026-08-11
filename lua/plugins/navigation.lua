return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader><leader>", "<cmd>Telescope find_files<cr>", desc = "Search everywhere" },
      -- Cmd+Shift+N (only reaches nvim if Ghostty forwards Cmd; see docs/ghostty-keybinds.md)
      { "<D-N>", "<cmd>Telescope find_files<cr>", desc = "Find files (Cmd+Shift+N)" },
      { "<D-n>", "<cmd>Telescope find_files<cr>", desc = "Find files (Cmd+Shift+N)" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    },
    config = function()
      require("telescope").setup({})
      pcall(require("telescope").load_extension, "projects")
    end,
  },

  {
    "stevearc/aerial.nvim",
    cmd = "AerialToggle",
    opts = {},
    keys = { { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Outline" } },
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      {
        "<leader>hh",
        function()
          local h = require("harpoon")
          h.ui:toggle_quick_menu(h:list())
        end,
        desc = "Harpoon menu",
      },
    },
    config = function() require("harpoon"):setup() end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = { { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" } },
  },

  { "ahmedkhalf/project.nvim", event = "VeryLazy", main = "project_nvim", opts = {} },

  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { theme = "hyper", config = { project = { enable = true } } },
  },
}

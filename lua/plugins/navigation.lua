-- Moving around a project: explorer, outline, harpoon, flash, dashboard, sessions.
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

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    init = function()
      -- VS Code-style: launching on a directory (`nvim .`) cds into the project
      -- and opens the tree as a left sidebar. Deferred so it runs after startup.
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          local a = vim.fn.argv(0)
          if type(a) == "string" and a ~= "" and vim.fn.isdirectory(a) == 1 then
            vim.schedule(function()
              pcall(vim.cmd.cd, a)
              pcall(function() require("neo-tree.command").execute({ action = "show", position = "left", dir = a }) end)
            end)
          end
        end,
      })
    end,
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_current",
        -- Show dotfiles by default (gitignored files stay hidden — toggle with H).
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
    },
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },
}

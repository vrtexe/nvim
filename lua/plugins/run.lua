return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-go",
      "mrcjkb/rustaceanvim",
    },
    lazy = true,
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest"),
          require("neotest-go"),
          require("rustaceanvim.neotest"),
        },
      })
    end,
  },

  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerRunCmd", "OverseerOpen" },
    opts = {},
  },
}

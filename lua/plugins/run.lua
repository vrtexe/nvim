return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      { "fredrikaverpil/neotest-golang", version = "*" },
      "rcasia/neotest-java",
      "mrcjkb/rustaceanvim",
    },
    lazy = true,
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest"),
          require("neotest-golang")({}),
          require("neotest-java")({}),
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

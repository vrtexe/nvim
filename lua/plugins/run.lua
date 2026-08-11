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
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Test nearest" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
    },
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
    cmd = { "OverseerRun", "OverseerToggle" },
    keys = {
      { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Run task/build" },
      { "<leader>rl", "<cmd>OverseerToggle<cr>", desc = "Task list" },
    },
    opts = {},
  },
}

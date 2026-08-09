return {
  { "akinsho/toggleterm.nvim", cmd = "ToggleTerm",
    keys = { { "<C-\\>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Terminal" } },
    opts = { direction = "horizontal", size = 15 } },
  { "folke/persistence.nvim", event = "BufReadPre", opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
    } },
}

return {
  { "akinsho/toggleterm.nvim", cmd = "ToggleTerm",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Terminal" },
      { "<M-F12>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Terminal (Option+F12)" },
    },
    opts = { direction = "horizontal", size = 15 } },
  { "folke/persistence.nvim", event = "BufReadPre", opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
    } },
}

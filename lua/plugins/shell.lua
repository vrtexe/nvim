return {
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Terminal" },
      { "<M-F12>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Terminal (Option+F12)" },
      -- Terminal "tabs": Option+1/2/3 switch between persistent terminals
      { "<M-1>", "<cmd>1ToggleTerm direction=horizontal<cr>", mode = { "n", "t" }, desc = "Terminal 1" },
      { "<M-2>", "<cmd>2ToggleTerm direction=horizontal<cr>", mode = { "n", "t" }, desc = "Terminal 2" },
      { "<M-3>", "<cmd>3ToggleTerm direction=horizontal<cr>", mode = { "n", "t" }, desc = "Terminal 3" },
      { "<M-t>", "<cmd>ToggleTerm direction=float<cr>", mode = { "n", "t" }, desc = "Float terminal" },
    },
    opts = { direction = "horizontal", size = 15 },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
    },
  },
}

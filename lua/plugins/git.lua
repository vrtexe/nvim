return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = { current_line_blame = true }, -- inline blame like GitLens
    keys = {
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame line" },
      { "]c", "<cmd>Gitsigns next_hunk<cr>", desc = "Next hunk" },
      { "[c", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev hunk" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage (accept) hunk" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset (reject) hunk" },
      { "<leader>gS", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage whole buffer" },
    },
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff all working changes" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    },
  },
}

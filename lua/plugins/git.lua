return {
  { "lewis6991/gitsigns.nvim", event = "BufReadPre",
    opts = { current_line_blame = true },  -- inline blame like GitLens
    keys = {
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame line" },
      { "]c", "<cmd>Gitsigns next_hunk<cr>", desc = "Next hunk" },
      { "[c", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev hunk" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage hunk" },
    } },
  { "kdheepak/lazygit.nvim", cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } } },
  { "sindrets/diffview.nvim", cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = { { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" } } },
}

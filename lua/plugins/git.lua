return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = { current_line_blame = true }, -- inline blame like GitLens
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  },
}

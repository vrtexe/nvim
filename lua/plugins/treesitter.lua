return {
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    branch = "master",  -- classic API (nvim-treesitter.configs); `main` branch is the incompatible rewrite
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "bash", "json", "yaml",
        "markdown", "html", "css", "javascript", "typescript", "tsx",
        "svelte", "sql", "dockerfile", "go", "gomod", "rust", "c", "cpp",
        "java", "kotlin" },
      highlight = { enable = true },
      indent = { enable = true },
    } },
  { "HiPhish/rainbow-delimiters.nvim", event = "BufReadPost" },
  { "lukas-reineke/indent-blankline.nvim", name = "ibl", main = "ibl",
    event = "BufReadPost", opts = {} },
  { "RRethy/vim-illuminate", event = "BufReadPost" },
}

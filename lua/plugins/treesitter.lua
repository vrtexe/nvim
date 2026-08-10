local PARSERS = {
  "lua", "vim", "vimdoc", "bash", "json", "yaml", "markdown", "markdown_inline",
  "html", "css", "javascript", "typescript", "tsx", "svelte", "sql",
  "dockerfile", "go", "gomod", "rust", "c", "cpp", "java", "kotlin",
}

return {
  -- nvim-treesitter `main` branch (the rewrite): required for Neovim 0.12.
  -- The archived `master` branch crashes 0.12's highlighter ("attempt to call
  -- method 'range'"). New API: install() for parsers, vim.treesitter.start() for
  -- highlighting. Indentation stays on Neovim's built-in filetype indenters.
  { "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,          -- upstream: do NOT lazy-load this plugin
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(PARSERS)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          -- start treesitter highlighting when a parser exists for this ft
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end },

  -- Auto-close and auto-rename HTML/JSX/TSX/Svelte/Vue tags
  { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },
  { "HiPhish/rainbow-delimiters.nvim", event = "BufReadPost" },
  { "lukas-reineke/indent-blankline.nvim", name = "ibl", main = "ibl",
    event = "BufReadPost", opts = {} },
  { "RRethy/vim-illuminate", event = "BufReadPost" },
}

-- Coding batch — editing/LSP/UI enhancements added on top of the base config.
-- Grouped in one file so the batch is easy to review or revert as a unit.
return {
  -- Lua LSP awareness of the Neovim API + installed plugins. Makes editing THIS
  -- config sane: no false `vim`/`Snacks` "undefined global" diagnostics, and
  -- completion for plugin modules. Blink source wired in completion.lua.
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },

  -- Extended text objects: af/if (function), aa/ia (argument), plus smarter
  -- bracket/quote search. No overlap with nvim-surround/autopairs.
  { "echasnovski/mini.ai", version = "*", event = "VeryLazy", opts = {} },

  -- Toggle a list/args between single-line and multi-line with `gS`.
  { "echasnovski/mini.splitjoin", version = "*", event = "VeryLazy", opts = {} },

  -- Close a buffer while keeping the window/split layout intact (plain :bd
  -- also closes the split). No setup() needed — just the function.
  {
    "echasnovski/mini.bufremove",
    version = "*",
    lazy = true,
  },

  -- Modern code folding (treesitter/indent providers). Fold options live in
  -- core/options.lua (foldlevel=99 so files open unfolded).
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    config = function()
      require("ufo").setup({
        provider_selector = function() return { "treesitter", "indent" } end,
      })
    end,
  },

  -- Peek panel for references (bound to gr/A-F7 in lsp.lua). VS Code-style
  -- "Find All References" with live preview; gd stays the fast jump.
  { "dnlhc/glance.nvim", cmd = "Glance", opts = {} },

  -- Render markdown in-buffer (headings, code blocks, tables). markdown +
  -- markdown_inline parsers are already in the treesitter list.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- Project-wide find & replace UI (VS Code search panel).
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = {},
  },
}

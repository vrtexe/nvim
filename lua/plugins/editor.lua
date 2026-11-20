-- Editing: pairs, surround, multi-cursor, text objects, folds, search & replace.
return {
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "kylechui/nvim-surround", event = "VeryLazy", version = "*", opts = {} },
  { "mg979/vim-visual-multi", event = "BufReadPost" }, -- Ctrl+N multi-cursor
  { "folke/todo-comments.nvim", event = "BufReadPost", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
  -- Animated smooth scrolling for <C-d>/<C-u>/<C-f>/<C-b>/zz/gg/G etc.
  -- { "karb94/neoscroll.nvim", event = "VeryLazy", opts = { easing = "sine" } },
  -- Animated cursor trail (the caret glides between positions).
  -- Disabled: too jumpy in the terminal. To re-enable a *calm* version, set
  -- enabled = true and use the opts below (snappy, no small-move jitter).
  -- {
  --   "sphamba/smear-cursor.nvim",
  --   enabled = false,
  --   event = "VeryLazy",
  --   opts = {
  --     stiffness = 0.9,
  --     trailing_stiffness = 0.7,
  --     distance_stop_animating = 0.5, -- don't animate tiny moves (kills jitter)
  --   },
  -- },

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

  -- Peek panel for references (grr / Alt+F7 / Shift+F12, see lua/keymaps). VS Code-style
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

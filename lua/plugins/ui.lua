return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "projekt0n/github-nvim-theme",
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = { styles = { comments = "italic", keywords = "NONE" } },
      })

      -- Dark/light pair for :ThemeToggle. Startup uses the dark one.
      local DARK, LIGHT = "github_dark", "github_light"

      -- Custom syntax palette — dark-background colors, so applied in dark mode
      -- only; light mode keeps the theme's own defaults. Reapplied on every
      -- ColorScheme event so it survives toggling / any :colorscheme change.
      local function apply_palette()
        if vim.o.background ~= "dark" then return end
        local set = function(groups, opts)
          for _, g in ipairs(groups) do vim.api.nvim_set_hl(0, g, opts) end
        end
        set({ "@string", "@string.documentation" }, { fg = "#CAFFBF" })
        set({
          "@keyword", "@keyword.function", "@keyword.operator", "@keyword.return",
          "@keyword.conditional", "@keyword.repeat", "@keyword.exception", "@keyword.import",
          "@conditional", "@repeat", "@exception",
        }, { fg = "#F97583" })
        set({
          "@variable", "@variable.member", "@property", "@field",
          "@parameter", "@variable.parameter",
        }, { fg = "#EBF2FF" })
        set({ "@type", "@type.definition", "@constructor" }, { fg = "#BDB2FF" })
        set({ "@number", "@number.float", "@float" }, { fg = "#C8E7FF" })
        set({
          "@function", "@function.call", "@function.method",
          "@function.method.call", "@function.builtin",
        }, { fg = "#FFD6A5" })
        set({ "@comment" }, { fg = "#569c45", italic = true })
        -- Special group -> blue (this/self, language constants, primitives,
        -- escapes, markdown headings/links).
        set({
          "@variable.builtin", "@constant", "@constant.builtin", "@boolean",
          "@type.builtin", "@string.escape",
          "@markup.heading", "@markup.heading.1", "@markup.heading.2", "@markup.heading.3",
          "@markup.heading.4", "@markup.heading.5", "@markup.heading.6",
          "@markup.link", "@markup.link.label", "@markup.link.url",
        }, { fg = "#79B8FF" })
      end

      -- Rainbow bracket-pair colors (VS Code editorBracketHighlight.foreground1-6).
      -- Applied in both light and dark; rainbow-delimiters cycles these groups
      -- by nesting depth (see the highlight list in treesitter.lua).
      local function apply_bracket_colors()
        local colors = { "#FFD700", "#DA70D6", "#87CEFA", "#FFA07A", "#66CDAA", "#FF69B4" }
        for i, c in ipairs(colors) do
          vim.api.nvim_set_hl(0, "RainbowDelimiter" .. i, { fg = c })
        end
      end

      -- Reapply overrides after any colorscheme loads (fires synchronously
      -- during :colorscheme, so it runs for the startup theme too).
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          apply_bracket_colors()
          apply_palette()
        end,
      })

      vim.cmd.colorscheme(DARK)

      vim.api.nvim_create_user_command("ThemeToggle", function()
        vim.cmd.colorscheme(vim.o.background == "dark" and LIGHT or DARK)
      end, { desc = "Toggle GitHub theme (dark/light)" })
    end,
  },
}

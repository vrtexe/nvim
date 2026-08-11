-- Leaders must be set before lazy/keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local o = vim.opt
o.clipboard = "unnamedplus" -- macOS system clipboard
o.number = true -- absolute line numbers (user preference)
o.relativenumber = false
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.autoindent = true -- fallback: keep indent for filetypes w/o indentexpr
-- No smartindent: it fights the real per-filetype `indentexpr` (over-indents).
o.wrap = false
o.signcolumn = "yes" -- stable gutter for diagnostics/git
o.termguicolors = true
o.ignorecase = true
o.smartcase = true
o.undofile = true
o.splitright = true
o.splitbelow = true
o.scrolloff = 6
o.smoothscroll = true -- smooth scroll over wrapped lines (native 0.10+)
o.updatetime = 250
o.timeoutlen = 400 -- which-key popup delay

-- Inline diagnostics: gutter signs + end-of-line virtual text (REQUIRED)
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  -- Nerd Font glyphs in the gutter (needs a Nerd Font in the terminal — you have one).
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

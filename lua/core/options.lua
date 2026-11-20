-- Leaders must be set before lazy/keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local o = vim.opt
o.clipboard = "unnamedplus" -- macOS system clipboard
o.number = true -- with relativenumber: current line absolute, the rest relative (as in IntelliJ)
o.relativenumber = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.autoindent = true -- fallback: keep indent for filetypes w/o indentexpr
-- No smartindent: it fights the real per-filetype `indentexpr` (over-indents).
o.wrap = false
o.signcolumn = "yes" -- stable gutter for diagnostics/git
-- Folding (nvim-ufo): open files fully unfolded; ufo supplies fold text/handling.
o.foldcolumn = "0" -- no fold-column gutter (set "1" to show fold markers)
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true
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

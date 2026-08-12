-- Minimal chrome for embedded use: launch nvim as `NVIM_MINIMAL=1 nvim ...`
-- (e.g. from inside a TUI app) to drop the top bars — editor tabs (bufferline)
-- and the breadcrumb "name above" (barbecue) — while keeping the footer statusline.
local function full_ui() return vim.env.NVIM_MINIMAL ~= "1" end

return {
  -- Footer statusline: kept even in minimal mode.
  { "nvim-lualine/lualine.nvim", event = "VeryLazy", opts = { options = { theme = "auto", globalstatus = true } } },

  -- scope.nvim scopes buffers to tab pages, so each tab page acts like a VS Code
  -- "editor group": bufferline then shows only that group's tabs.
  { "tiagovla/scope.nvim", enabled = full_ui, event = "VeryLazy", opts = {} },

  {
    "akinsho/bufferline.nvim",
    enabled = full_ui,
    event = "VeryLazy",
    dependencies = { "tiagovla/scope.nvim" },
    opts = { options = { diagnostics = "nvim_lsp", separator_style = "thick" } },
    keys = {
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer/tab" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer/tab" },
    },
  },

  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- Breadcrumb "name above" the window: off in minimal mode.
  {
    "utilyre/barbecue.nvim",
    enabled = full_ui,
    event = "VeryLazy",
    dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
    opts = { attach_navic = true },
  },
}

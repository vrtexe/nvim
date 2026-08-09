return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "projekt0n/github-nvim-theme",
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = { styles = { comments = "italic", keywords = "NONE" } },
      })
      vim.cmd.colorscheme("github_dark")
      -- Darcula/Dracula-style: push identifiers toward neutral foreground
      local fg = "#c9d1d9"
      for _, g in ipairs({ "@variable", "@property", "@field", "@parameter",
                           "@variable.member", "@variable.parameter" }) do
        vim.api.nvim_set_hl(0, g, { fg = fg })
      end
    end,
  },
}

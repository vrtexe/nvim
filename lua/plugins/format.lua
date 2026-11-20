-- Formatting (conform, on demand) and linting (nvim-lint) beside the LSP servers.
return {
  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo", -- format keymaps load it via require()
    opts = {
      format_on_save = false, -- user preference: OFF
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        go = { "gofmt" },
        rust = { "rustfmt" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = "BufReadPost",
    config = function()
      local lint = require("lint")
      -- JS/TS linting is handled by the eslint LSP; nvim-lint only covers extras
      -- (e.g. hadolint for Dockerfiles). Keeping eslint_d here would double-lint.
      lint.linters_by_ft = { dockerfile = { "hadolint" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        callback = function()
          -- Only run linters whose executable is actually installed (avoid ENOENT)
          local run = {}
          for _, name in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
            local l = lint.linters[name]
            local cmd = type(l) == "function" and l().cmd or (type(l) == "table" and l.cmd)
            if cmd and vim.fn.executable(cmd) == 1 then run[#run + 1] = name end
          end
          if #run > 0 then lint.try_lint(run) end
        end,
      })
    end,
  },
}

return {
  { "williamboman/mason.nvim", cmd = "Mason", opts = {} },
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

  { "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "SmiteshP/nvim-navic",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local servers = { "lua_ls", "ts_ls", "svelte", "tailwindcss", "html",
        "cssls", "jsonls", "eslint", "gopls", "clangd",
        "kotlin_language_server", "dockerls", "sqls" }
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = servers })

      local caps = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = caps })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local b = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, b)
          end
          local function m(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = b, desc = desc })
          end
          m("gd", vim.lsp.buf.definition, "Go to definition")
          m("<F4>", vim.lsp.buf.definition, "Go to definition")
          m("gi", vim.lsp.buf.implementation, "Go to implementation")
          m("gr", vim.lsp.buf.references, "Find references")
          m("<A-F7>", vim.lsp.buf.references, "Find references")
          m("K", vim.lsp.buf.hover, "Hover docs")
          m("<S-F6>", vim.lsp.buf.rename, "Rename")
          m("<A-CR>", vim.lsp.buf.code_action, "Code action")
          m("<C-A-o>", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" } }, apply = true })
          end, "Organize imports")
        end,
      })

      for _, s in ipairs(servers) do vim.lsp.enable(s) end
    end,
  },

  { "stevearc/conform.nvim", event = "BufWritePre",
    keys = { { "<C-A-l>", function() require("conform").format({ lsp_fallback = true }) end,
              mode = { "n", "v" }, desc = "Reformat (IntelliJ)" } },
    opts = {
      format_on_save = false,   -- user preference: OFF
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettier" }, css = { "prettier" }, html = { "prettier" },
        json = { "prettier" }, go = { "gofmt" }, rust = { "rustfmt" },
      },
    } },

  { "mfussenegger/nvim-lint", event = "BufReadPost",
    config = function()
      require("lint").linters_by_ft = { javascript = { "eslint_d" },
        typescript = { "eslint_d" }, dockerfile = { "hadolint" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        callback = function() require("lint").try_lint() end })
    end },
}

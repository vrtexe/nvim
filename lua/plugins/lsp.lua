return {
  { "williamboman/mason.nvim", cmd = "Mason", opts = {} },
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "SmiteshP/nvim-navic",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local servers = {
        "lua_ls",
        "ts_ls",
        "svelte",
        "tailwindcss",
        "html",
        "cssls",
        "jsonls",
        "eslint",
        "gopls",
        "clangd",
        "kotlin_language_server",
        "dockerls",
        "sqls",
        "bashls",
      }
      require("mason").setup()
      -- automatic_enable enables ONLY installed servers (and enables each as its
      -- install completes). Do NOT manually vim.lsp.enable() the whole list —
      -- that force-spawns servers mason hasn't installed yet ("failed to spawn").
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = true,
      })

      local caps = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = caps })

      -- Svelte cross-file auto-import: teach ts_ls about .svelte via the TS Svelte
      -- plugin (bundled with the svelte-language-server mason package) and let
      -- ts_ls attach to .svelte buffers too, so component imports are suggested.
      local svelte_ts_plugin = vim.fn.stdpath("data")
        .. "/mason/packages/svelte-language-server/node_modules/typescript-svelte-plugin"
      if vim.uv.fs_stat(svelte_ts_plugin) then
        vim.lsp.config("ts_ls", {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
            "svelte",
          },
          init_options = {
            plugins = {
              {
                name = "typescript-svelte-plugin",
                location = svelte_ts_plugin,
                languages = { "svelte" },
              },
            },
          },
        })
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local b = ev.buf
          -- Breadcrumbs (navic) are attached by barbecue (attach_navic=true).
          -- Attaching here too warns when a 2nd client (e.g. svelte + ts_ls) attaches.
          local function m(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = b, desc = desc }) end
          m("gd", vim.lsp.buf.definition, "Go to definition")
          m("<F4>", vim.lsp.buf.definition, "Go to definition")
          m("gi", vim.lsp.buf.implementation, "Go to implementation")
          -- Peek panel (glance.nvim) instead of the quickfix dump. gd stays a jump.
          m("gr", "<cmd>Glance references<cr>", "Find references (peek)")
          m("<A-F7>", "<cmd>Glance references<cr>", "Find references (peek)")
          m("K", vim.lsp.buf.hover, "Hover docs")
          m("<S-F6>", vim.lsp.buf.rename, "Rename")
          m("<A-CR>", vim.lsp.buf.code_action, "Code action")
          m(
            "<C-A-o>",
            function()
              vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" } },
                apply = true,
              })
            end,
            "Organize imports"
          )
        end,
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      {
        "<C-A-l>",
        function() require("conform").format({ lsp_fallback = true }) end,
        mode = { "n", "v" },
        desc = "Reformat (IntelliJ)",
      },
    },
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

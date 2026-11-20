return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        -- handlers = {} registers every installed adapter with its default config.
        opts = { ensure_installed = { "codelldb", "delve" }, handlers = {} },
      },
    },
    lazy = true,
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end

      -- JS/TS/Svelte through js-debug-adapter (installed by lsp.lua). mason-nvim-dap
      -- has no default config for it.
      for _, kind in ipairs({ "node", "chrome" }) do
        dap.adapters["pwa-" .. kind] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = { command = "js-debug-adapter", args = { "${port}" } },
        }
      end
      local node = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to process",
          processId = require("dap.utils").pick_process,
        },
      }
      local chrome = {
        type = "pwa-chrome",
        request = "launch",
        name = "Chrome: localhost:5173 (Vite)",
        url = "http://localhost:5173",
        webRoot = "${workspaceFolder}",
      }
      for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[ft] = vim.list_extend(vim.deepcopy(node), { chrome })
      end
      dap.configurations.svelte = { chrome }
    end,
  },
}

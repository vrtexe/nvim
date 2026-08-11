return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      { "jay-babu/mason-nvim-dap.nvim", opts = { ensure_installed = { "codelldb", "delve" } } },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<F8>", function() require("dap").step_over() end, desc = "Step over" },
      { "<F7>", function() require("dap").step_into() end, desc = "Step into" },
      { "<S-F8>", function() require("dap").step_out() end, desc = "Step out" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
    end,
  },
}

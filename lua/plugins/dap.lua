return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap   = require("dap")
          local dapui = require("dapui")

          dapui.setup({
            icons = { expanded = "", collapsed = "", current_frame = "" },
            mappings = {
              expand = { "<CR>", "<2-LeftMouse>" },
              open   = "o",
              remove = "d",
              edit   = "e",
              repl   = "r",
              toggle = "t",
            },
            layouts = {
              {
                elements = {
                  { id = "scopes",      size = 0.25 },
                  { id = "breakpoints", size = 0.25 },
                  { id = "stacks",      size = 0.25 },
                  { id = "watches",     size = 0.25 },
                },
                size     = 40,
                position = "left",
              },
              {
                elements = {
                  { id = "repl",    size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                size     = 10,
                position = "bottom",
              },
            },
            floating = { border = "rounded" },
          })

          -- Auto-open/close DAP UI when session starts/ends
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = { commented = true },
      },
    },
    keys = {
      -- IntelliJ debug keybindings
      { "<F5>",   function() require("dap").continue() end,          desc = "Debug: Continue (F5)" },
      { "<F8>",   function() require("dap").step_over() end,         desc = "Debug: Step Over (F8)" },
      { "<F7>",   function() require("dap").step_into() end,         desc = "Debug: Step Into (F7)" },
      { "<S-F8>", function() require("dap").step_out() end,          desc = "Debug: Step Out (Shift+F8)" },
      { "<F9>",   function() require("dap").toggle_breakpoint() end,  desc = "Debug: Toggle Breakpoint (F9)" },
      { "<C-F2>", function() require("dap").terminate() end,          desc = "Debug: Stop (Ctrl+F2)" },
      {
        "<S-F9>",
        function() require("dap").continue() end,
        desc = "Debug: Start (Shift+F9)",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Debug: Conditional breakpoint",
      },
      {
        "<leader>dl",
        function()
          require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = "Debug: Log point",
      },
      { "<leader>dr", function() require("dap").repl.open() end,   desc = "Debug: REPL" },
      { "<leader>du", function() require("dapui").toggle() end,     desc = "Debug: Toggle UI" },
    },
    config = function()
      local dap = require("dap")

      -- Signs
      vim.fn.sign_define("DapBreakpoint",          { text = "🔴", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapLogPoint",            { text = "🔵", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk",   linehl = "DapStoppedLine" })

      -- Python (debugpy via Mason)
      dap.adapters.python = {
        type    = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
        args    = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type    = "python",
          request = "launch",
          name    = "Launch file",
          program = "${file}",
          pythonPath = function()
            return vim.fn.exepath("python3") or "python"
          end,
        },
      }

      -- Go (go-debug-adapter / delve via Mason)
      dap.adapters.go = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/go-debug-adapter",
          args    = { "--port", "${port}" },
        },
      }
      dap.configurations.go = {
        { type = "go", name = "Debug file",    request = "launch", program = "${file}" },
        { type = "go", name = "Debug package", request = "launch", program = "${fileDirname}" },
      }
    end,
  },
}

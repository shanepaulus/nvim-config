return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",      desc = "Symbols (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list" },
      -- IntelliJ: F2 → next error / Shift+F2 → prev error
      {
        "<F2>",
        function()
          require("trouble").next({ skip_groups = true, jump = true })
        end,
        desc = "Next error (F2)",
      },
      {
        "<S-F2>",
        function()
          require("trouble").prev({ skip_groups = true, jump = true })
        end,
        desc = "Prev error (Shift+F2)",
      },
    },
    opts = {
      use_diagnostic_signs = true,
      modes = {
        diagnostics = {
          auto_open   = false,
          auto_close  = true,
          auto_preview = true,
          auto_fold   = false,
        },
      },
    },
  },
}

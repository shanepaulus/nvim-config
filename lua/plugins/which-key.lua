return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 300,
      icons = { mappings = true },
      spec = {
        { "<leader>f", group = "Find/File" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>d", group = "Debug" },
        { "<leader>j", group = "Java" },
        { "<leader>t", group = "Terminal/Test" },
        { "<leader>u", group = "UI" },
        { "<leader>x", group = "Diagnostics" },
        { "<leader>c", group = "Code" },
      },
    },
  },
}

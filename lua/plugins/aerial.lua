return {
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      -- IntelliJ: Ctrl+F12 → File structure popup (aerial provides a sidebar version)
      { "<leader>co", "<cmd>AerialToggle<cr>", desc = "Code outline (Aerial)" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
      layout = {
        max_width  = { 40, 0.2 },
        width      = nil,
        min_width  = 10,
        default_direction = "prefer_right",
        placement = "window",
      },
      show_guides = true,
      guides = {
        mid_item   = "├─",
        last_item  = "└─",
        nested_top = "│ ",
        whitespace = "  ",
      },
      filter_kind = {
        "Class", "Constructor", "Enum", "Function", "Interface",
        "Module", "Method", "Struct",
      },
      icons = {},
      nav = {
        border   = "rounded",
        max_height = 0.9,
        min_height = { 10, 0.1 },
        max_width  = 0.45,
        min_width  = { 0.05, 10 },
        win_opts   = { cursorline = true, winblend = 10 },
        autojump   = false,
        preview    = false,
        keymaps = {
          ["<CR>"]  = "actions.jump",
          ["<2-LeftMouse>"] = "actions.jump",
          ["<C-v>"] = "actions.jump_vsplit",
          ["<C-s>"] = "actions.jump_split",
          ["h"]     = "actions.left",
          ["l"]     = "actions.right",
          ["<esc>"] = "actions.close",
        },
      },
      attach_mode = "window",
    },
    config = function(_, opts)
      require("aerial").setup(opts)
    end,
  },
}

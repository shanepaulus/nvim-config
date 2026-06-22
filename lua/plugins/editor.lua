return {
  -- Auto-close brackets, quotes, etc. (IntelliJ default behavior)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua        = { "string" },
        javascript = { "template_string" },
        java       = false,
      },
    },
    config = function(_, opts)
      local autopairs = require("nvim-autopairs")
      autopairs.setup(opts)
      -- Integrate with nvim-cmp: add closing bracket after confirm
      local ok, cmp = pcall(require, "cmp")
      if ok then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- Surround motions (ys, cs, ds)
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Multiple cursors — Ctrl+D: select next occurrence (like IntelliJ/VSCode)
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "BufReadPost",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"]         = "<C-d>",
        ["Find Subword Under"] = "<C-d>",
        ["Select All"]         = "<C-S-l>",
        ["Add Cursor Down"]    = "<C-S-Down>",
        ["Add Cursor Up"]      = "<C-S-Up>",
      }
      vim.g.VM_theme = "iceblue"
      vim.g.VM_highlight_matches = "underline"
    end,
  },

  -- Comment toggling (Ctrl+/)
  {
    "numToStr/Comment.nvim",
    event = "BufReadPost",
    opts = {
      toggler  = { line = "gcc", block = "gbc" },
      opleader = { line = "gc",  block = "gb" },
      extra = {
        above = "gcO",
        below = "gco",
        eol   = "gcA",
      },
    },
  },

  -- JSON schema auto-detection (package.json, tsconfig.json, GitHub Actions, etc.)
  { "b0o/schemastore.nvim", lazy = true },

  -- Cycle through word alternatives: true↔false, &&↔||, public↔private↔protected, etc.
  -- IntelliJ keymap: Shift+Alt+Up/Down/Left/Right/Enter
  {
    "AndrewRadev/switch.vim",
    event = "BufReadPost",
    init = function()
      vim.g.switch_mapping = ""
      vim.g.switch_custom_definitions = {
        { "true", "false" },
        { "yes", "no" },
        { "on", "off" },
        { "&&", "||" },
        { "==", "!=" },
        { "public", "private", "protected" },
        { "extends", "implements" },
      }
    end,
    keys = {
      { "<S-A-CR>",    "<cmd>Switch<cr>",        mode = { "n", "i" }, desc = "Switch (apply) (Shift+Alt+Enter)" },
      { "<S-A-Down>",  "<cmd>Switch<cr>",         mode = { "n", "i" }, desc = "Switch next (Shift+Alt+Down)" },
      { "<S-A-Up>",    "<cmd>SwitchReverse<cr>",  mode = { "n", "i" }, desc = "Switch prev (Shift+Alt+Up)" },
      { "<S-A-Right>", "<cmd>Switch<cr>",         mode = { "n", "i" }, desc = "Switch next (Shift+Alt+Right)" },
      { "<S-A-Left>",  "<cmd>SwitchReverse<cr>",  mode = { "n", "i" }, desc = "Switch prev (Shift+Alt+Left)" },
    },
  },
}

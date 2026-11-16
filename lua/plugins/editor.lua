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

  -- Multiple carets, IntelliJ keys: Alt+J select next occurrence,
  -- Alt+Shift+J unselect it, Ctrl+Alt+Shift+J select all occurrences.
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "BufReadPost",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"]         = "<A-j>",
        ["Find Subword Under"] = "<A-j>",
        ["Remove Last Region"] = "<A-S-j>",
        ["Select All"]         = "<C-A-S-j>",
        -- VM defaults these to Ctrl+Up/Down, IntelliJ's scroll keys
        ["Add Cursor Down"]    = "",
        ["Add Cursor Up"]      = "",
        -- free Shift+Left/Right for plain text selection (options.lua keymodel)
        ["Select l"]           = "",
        ["Select h"]           = "",
      }
      vim.g.VM_theme = "iceblue"
      vim.g.VM_highlight_matches = "underline"
    end,
    -- Same maps VM creates from VM_maps, re-set with descriptions for F1/which-key.
    config = function()
      local map = function(mode, lhs, plug, desc)
        vim.keymap.set(mode, lhs, plug, { remap = true, desc = desc })
      end
      map("n", "<A-j>",     "<Plug>(VM-Find-Under)",         "Select next occurrence (Alt+J)")
      map("x", "<A-j>",     "<Plug>(VM-Find-Subword-Under)", "Select next occurrence (Alt+J)")
      map("n", "<C-A-S-j>", "<Plug>(VM-Select-All)",         "Select all occurrences (Ctrl+Alt+Shift+J)")
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
  -- Shift+Alt+Enter (Shift+Alt+arrows are IntelliJ's move line / switch tab)
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
      { "<S-A-CR>", "<cmd>Switch<cr>", mode = { "n", "i" }, desc = "Switch (apply) (Shift+Alt+Enter)" },
    },
  },
}

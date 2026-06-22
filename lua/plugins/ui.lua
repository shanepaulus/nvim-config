return {
  -- Shane Paulus colorscheme (converted from IntelliJ Shane_Paulus_Theme.icls)
  {
    name = "shane_paulus",
    dir = vim.fn.stdpath("config"),
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("shane_paulus")
    end,
  },

  -- Icons (dependency for neo-tree, lualine, bufferline, etc.)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- UI component library (dependency for noice, neo-tree)
  { "MunifTanjim/nui.nvim", lazy = true },

  -- Notification system
  {
    "rcarriga/nvim-notify",
    lazy = true,
    opts = {
      timeout = 3000,
      render = "default",
      stages = "fade",
      background_colour = "#222222",
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width  = function() return math.floor(vim.o.columns * 0.75) end,
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- Enhanced cmdline / search / notification UI (IntelliJ-like floating inputs)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        signature = { enabled = false },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- Status line with custom Shane Paulus palette
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local sp = {
        normal   = { a = { fg = "#222222", bg = "#a7ec21", gui = "bold" },
                     b = { fg = "#cfbfad", bg = "#3C3F41" },
                     c = { fg = "#cfbfad", bg = "#26292B" } },
        insert   = { a = { fg = "#222222", bg = "#20c9fb", gui = "bold" },
                     b = { fg = "#cfbfad", bg = "#3C3F41" },
                     c = { fg = "#cfbfad", bg = "#26292B" } },
        visual   = { a = { fg = "#222222", bg = "#c48cff", gui = "bold" },
                     b = { fg = "#cfbfad", bg = "#3C3F41" },
                     c = { fg = "#cfbfad", bg = "#26292B" } },
        replace  = { a = { fg = "#222222", bg = "#ff007f", gui = "bold" },
                     b = { fg = "#cfbfad", bg = "#3C3F41" },
                     c = { fg = "#cfbfad", bg = "#26292B" } },
        command  = { a = { fg = "#222222", bg = "#f7c070", gui = "bold" },
                     b = { fg = "#cfbfad", bg = "#3C3F41" },
                     c = { fg = "#cfbfad", bg = "#26292B" } },
        inactive = { a = { fg = "#808080", bg = "#26292B" },
                     b = { fg = "#808080", bg = "#26292B" },
                     c = { fg = "#808080", bg = "#26292B" } },
      }
      return {
        options = {
          theme = sp,
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
          component_separators = "|",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },

  -- Buffer tabs (IntelliJ editor tabs)
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-Tab>",   "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer (Ctrl+Tab)" },
      { "<C-S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer (Ctrl+Shift+Tab)" },
      { "<C-F4>", "<cmd>bdelete<cr>", desc = "Close buffer (Ctrl+F4)" },
      { "<C-q>",  "<cmd>bdelete<cr>", desc = "Close buffer (Ctrl+Q)" },
    },
    opts = {
      options = {
        mode = "buffers",
        numbers = "none",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = { error = " ", warning = " " }
          return (diag.error and icons.error .. diag.error .. " " or "")
            .. (diag.warning and icons.warning .. diag.warning or "")
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thin",
      },
    },
  },

  -- Indent guides (IntelliJ indent visualization)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble",
                      "lazy", "mason", "notify" },
      },
    },
  },
}

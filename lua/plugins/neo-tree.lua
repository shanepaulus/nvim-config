return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    -- Alt+1: focus sidebar if open, close if already focused (IntelliJ Alt+1 behaviour)
    keys = {
      {
        "<A-1>",
        function()
          local state = require("neo-tree.sources.manager").get_state("filesystem")
          local wins = vim.api.nvim_list_wins()
          for _, w in ipairs(wins) do
            if vim.api.nvim_win_get_buf(w) == (state.bufnr or -1) then
              if vim.api.nvim_get_current_win() == w then
                vim.cmd("Neotree close")
              else
                vim.api.nvim_set_current_win(w)
              end
              return
            end
          end
          vim.cmd("Neotree focus")
        end,
        desc = "Focus/toggle file explorer (Alt+1)",
      },
    },
    opts = {
      close_if_last_window = false,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
      sort_case_insensitive = true,
      default_component_configs = {
        container = { enable_character_fade = true },
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          with_expanders = true,
        },
        icon = {
          folder_closed = "",
          folder_open   = "",
          folder_empty  = "",
          default       = "",
          highlight     = "NeoTreeFileIcon",
        },
        modified = { symbol = "" },
        name = { trailing_slash = false, use_git_status_colors = true },
        git_status = {
          symbols = {
            added     = "",
            modified  = "",
            deleted   = "",
            renamed   = "➜",
            untracked = "★",
            ignored   = "◌",
            unstaged  = "✗",
            staged    = "✓",
            conflict  = "",
          },
        },
      },
      window = {
        position = "left",
        width = 35,
        mapping_options = { noremap = true, nowait = true },
        mappings = {
          ["<space>"] = "toggle_node",
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["l"] = "open",
          ["h"] = "close_node",
          ["t"] = "open_tabnew",
          ["v"] = "open_vsplit",
          ["s"] = "open_split",
          ["P"] = { "toggle_preview", config = { use_float = true } },
          ["a"] = { "add", config = { show_path = "none" } },
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy",
          ["m"] = "move",
          ["R"] = "refresh",
          ["I"] = "toggle_hidden",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true, leave_dirs_open = false },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_default",
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { ".git", "node_modules" },
          never_show = { ".DS_Store", "thumbs.db" },
        },
      },
      buffers = {
        follow_current_file = { enabled = true },
      },
      git_status = {
        window = { position = "float" },
      },
    },
  },
}

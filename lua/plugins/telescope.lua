return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
    keys = {
      -- Find file (Ctrl+P — Ctrl+Shift+N is intercepted by the terminal)
      { "<C-p>", "<cmd>Telescope find_files<cr>",
        mode = { "n", "i" }, desc = "Find file (Ctrl+P)" },
      -- IntelliJ: Ctrl+Shift+N → Find File (kept for terminals that pass it through)
      { "<C-S-n>", "<cmd>Telescope find_files<cr>",
        mode = { "n", "i" }, desc = "Find file (Ctrl+Shift+N)" },
      -- IntelliJ: Ctrl+Shift+F → Search in project
      { "<C-S-f>", "<cmd>Telescope live_grep<cr>",
        mode = { "n", "i" }, desc = "Search in project (Ctrl+Shift+F)" },
      -- IntelliJ: Ctrl+E → Recent files
      { "<C-e>", "<cmd>Telescope oldfiles<cr>",
        mode = { "n", "i" }, desc = "Recent files (Ctrl+E)" },
      -- IntelliJ: Ctrl+Shift+O → Go to symbol (workspace)
      { "<C-S-o>", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
        mode = { "n", "i" }, desc = "Go to symbol (Ctrl+Shift+O)" },
      -- IntelliJ: Ctrl+N → Go to class (document symbols)
      { "<C-n>", "<cmd>Telescope lsp_document_symbols<cr>",
        mode = { "n" }, desc = "Document symbols (Ctrl+N)" },
      -- Git files
      { "<leader>fg", "<cmd>Telescope git_files<cr>",        desc = "Git files" },
      -- Grep current word
      { "<leader>fw", "<cmd>Telescope grep_string<cr>",      desc = "Grep word under cursor" },
      -- Command history
      { "<leader>fc", "<cmd>Telescope command_history<cr>",  desc = "Command history" },
      -- Buffers
      { "<leader>fb", "<cmd>Telescope buffers<cr>",          desc = "Open buffers" },
      -- Diagnostics
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",      desc = "Diagnostics" },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        file_ignore_patterns = {
          "%.git/", "node_modules/", "target/", "build/",
          "%.class$", "%.jar$", "%.war$", "%.ear$",
        },
        mappings = {
          i = {
            ["<C-k>"] = "move_selection_previous",
            ["<C-j>"] = "move_selection_next",
            ["<esc>"] = "close",
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },
}

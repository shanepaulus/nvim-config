return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",  -- main branch is a rewrite requiring Neovim 0.12+; master supports 0.11
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    opts = {
      ensure_installed = {
        "java", "go", "python", "javascript", "typescript", "tsx",
        "vue", "scss", "graphql",
        "html", "css", "json", "yaml", "xml", "bash", "lua",
        "markdown", "markdown_inline", "query", "regex", "vim", "vimdoc",
        "dockerfile", "toml", "groovy",
        "c", "cpp", "rust", "ruby", "php", "sql", "hcl", "make", "cmake", "proto",
      },
      -- Any filetype not in the list above still gets highlighting: this
      -- installs its parser on first open instead of leaving the buffer
      -- with no highlighting at all (the actual root cause of "syntax only
      -- works on certain files" — ensure_installed alone only covers the
      -- languages listed above).
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = "<C-space>",
          node_incremental  = "<C-space>",
          scope_incremental = false,
          node_decremental  = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next     = { ["<leader>a"] = "@parameter.inner" },
          swap_previous = { ["<leader>A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- Auto-close/rename HTML/JSX/Vue tags (IntelliJ/WebStorm behavior: typing
  -- <div> appends </div>, editing the opening tag renames the closing one)
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}

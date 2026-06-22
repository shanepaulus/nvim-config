return {
  -- Git signs in gutter (added/modified/deleted lines)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      sign_priority = 6,
      update_debounce = 100,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- Navigate hunks
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Prev hunk")

        -- Stage / reset / undo
        map({ "n", "v" }, "<leader>gs",  gs.stage_hunk,    "Stage hunk")
        map({ "n", "v" }, "<leader>gr",  gs.reset_hunk,    "Reset hunk")
        map("n",          "<leader>gS",  gs.stage_buffer,  "Stage buffer")
        map("n",          "<leader>gu",  gs.undo_stage_hunk, "Undo stage hunk")
        map("n",          "<leader>gR",  gs.reset_buffer,  "Reset buffer")

        -- Diff & blame
        map("n", "<leader>gd",  gs.diffthis, "Diff this")
        map("n", "<leader>gD",  function() gs.diffthis("~") end, "Diff this ~")
        map("n", "<leader>gb",  function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>gtd", gs.toggle_deleted, "Toggle deleted")

        -- Text objects
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- LazyGit: full git TUI (requires lazygit binary — see prerequisites)
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
    cmd = { "LazyGit" },
  },
}

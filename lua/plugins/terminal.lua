return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- IntelliJ: Alt+4 → Terminal panel · Ctrl+Alt+T → New terminal tab
    -- Registered as commands (defined in config()) so the very first keypress
    -- reliably lazy-loads the plugin before dispatching (same pattern as
    -- neo-tree/telescope's <cmd>...<cr> lazy-keys).
    keys = {
      { "<A-4>",   "<cmd>TermTogglePanel<cr>", mode = { "n", "i", "t" }, desc = "Toggle terminal panel (Alt+4)" },
      { "<C-A-t>", "<cmd>TermNewTab<cr>",      mode = { "n", "i", "t" }, desc = "New terminal tab (Ctrl+Alt+T)" },
    },
    -- also lazy-load if any of these are typed directly as commands
    cmd = { "ToggleTerm", "TermTogglePanel", "TermNewTab", "MavenRun", "GradleRun" },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 20
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      -- open_mapping intentionally omitted: <A-4> is fully handled by our
      -- own TermTogglePanel command (below) so it stays aware of tabs.
      hide_numbers     = true,
      shade_terminals  = true,
      shading_factor   = 2,
      start_in_insert  = true,
      insert_mappings  = true,
      terminal_mappings = true,
      persist_size     = true,
      persist_mode     = true,
      direction        = "horizontal",
      close_on_exit    = true,
      shell            = vim.o.shell,
      float_opts = {
        border   = "curved",
        winblend = 0,
      },
    },
    config = function(_, opts)
      local term_mod = require("toggleterm.terminal")
      local Terminal = term_mod.Terminal

      -- ── "Tabs": numbered horizontal-split terminals, one visible at a time ──
      -- (Maven/Gradle floats below are separate — direction == "float" is
      -- excluded from tab bookkeeping so they never get folded into the strip.)

      local function tab_ids()
        local ids = {}
        for _, t in ipairs(term_mod.get_all(true)) do
          if t.direction == "horizontal" then table.insert(ids, t.id) end
        end
        table.sort(ids)
        return ids
      end

      local function visible_tab_id()
        for _, t in ipairs(term_mod.get_all(true)) do
          if t.direction == "horizontal" and t:is_open() then return t.id end
        end
        return nil
      end

      local function show_only_tab(id)
        for _, t in ipairs(term_mod.get_all(true)) do
          if t.direction == "horizontal" and t.id ~= id and t:is_open() then
            t:close()
          end
        end
        term_mod.get_or_create_term(id, nil, "horizontal"):open()
      end

      local function toggle_panel()
        local id = visible_tab_id()
        if id then
          term_mod.get(id):close()
        else
          local ids = tab_ids()
          show_only_tab(ids[#ids] or 1)
        end
      end

      local function new_tab()
        local ids = tab_ids()
        show_only_tab((ids[#ids] or 0) + 1)
      end

      local function cycle_tab(step)
        local ids = tab_ids()
        if #ids == 0 then
          new_tab()
          return
        end
        local current = visible_tab_id()
        local idx = 1
        if current then
          for i, id in ipairs(ids) do
            if id == current then idx = i end
          end
        end
        local next_id = ids[((idx - 1 + step) % #ids) + 1]
        show_only_tab(next_id)
        vim.notify(("Terminal %d/%d"):format(next_id, #ids), vim.log.levels.INFO, { title = "Terminal" })
      end

      -- Closes THIS terminal's window/process/buffer only — never touches
      -- editor file buffers, since a terminal is always its own buffer+window.
      local function close_terminal(term)
        local was_tab = term.direction == "horizontal"
        term:shutdown()
        if was_tab then
          local ids = tab_ids()
          if #ids > 0 then show_only_tab(ids[#ids]) end
        end
      end

      local function resize_terminal(term, delta)
        if term:is_split() and term.window and vim.api.nvim_win_is_valid(term.window) then
          local current = vim.api.nvim_win_get_height(term.window)
          term:resize(math.max(5, current + delta))
        end
      end

      vim.api.nvim_create_user_command("TermTogglePanel", toggle_panel, {})
      vim.api.nvim_create_user_command("TermNewTab", new_tab, {})

      -- Buffer-local keys set on every terminal (tabs AND Maven/Gradle floats):
      --   Ctrl+F4          close this terminal (mirrors global "close buffer")
      --   Ctrl+Up/Down     resize this terminal's split
      -- Tab-only (excludes floats):
      --   Ctrl+Tab / Ctrl+Shift+Tab   cycle tabs (mirrors global buffer-tab keys,
      --                               but shadowed here since focus is in a terminal)
      opts.on_open = function(term)
        local map = function(modes, lhs, rhs, desc)
          vim.keymap.set(modes, lhs, rhs, { buffer = term.bufnr, desc = desc, silent = true })
        end
        map({ "n", "t" }, "<C-F4>",  function() close_terminal(term) end,        "Close terminal tab (Ctrl+F4)")
        map({ "n", "t" }, "<C-Up>",   function() resize_terminal(term, 5) end,   "Increase terminal height (Ctrl+Up)")
        map({ "n", "t" }, "<C-Down>", function() resize_terminal(term, -5) end,  "Decrease terminal height (Ctrl+Down)")
        if term.direction == "horizontal" then
          map({ "n", "t" }, "<C-Tab>",   function() cycle_tab(1) end,  "Next terminal tab (Ctrl+Tab)")
          map({ "n", "t" }, "<C-S-Tab>", function() cycle_tab(-1) end, "Prev terminal tab (Ctrl+Shift+Tab)")
        end
      end

      require("toggleterm").setup(opts)

      -- Maven terminal (Shift+F10 outside Java ftplugin)
      local maven_term = Terminal:new({
        cmd = "mvn compile",
        direction = "float",
        close_on_exit = false,
      })

      vim.api.nvim_create_user_command("MavenRun", function(args)
        maven_term.cmd = "mvn " .. (args.args ~= "" and args.args or "compile")
        maven_term:toggle()
      end, { nargs = "?" })

      -- Gradle terminal
      local gradle_term = Terminal:new({
        cmd = "gradle build",
        direction = "float",
        close_on_exit = false,
      })

      vim.api.nvim_create_user_command("GradleRun", function(args)
        gradle_term.cmd = "./gradlew " .. (args.args ~= "" and args.args or "build")
        gradle_term:toggle()
      end, { nargs = "?" })
    end,
  },
}

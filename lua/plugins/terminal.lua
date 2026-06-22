return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      -- IntelliJ: Alt+4 → Terminal panel
      { "<A-4>", "<cmd>ToggleTerm<cr>", mode = { "n", "i" }, desc = "Toggle terminal (Alt+4)" },
      { "<A-4>", "<cmd>ToggleTerm<cr>", mode = "t",          desc = "Toggle terminal (Alt+4)" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 20
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping     = [[<A-4>]],
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
      require("toggleterm").setup(opts)

      -- Helper: run a command in a floating terminal
      local Terminal = require("toggleterm.terminal").Terminal

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

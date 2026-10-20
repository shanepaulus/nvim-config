return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },
    keys = (function()
      local format = function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end
      local keys = {
        -- IntelliJ: Ctrl+Alt+L → Reformat code
        { "<C-A-l>", format, mode = { "n", "i", "v" }, desc = "Format file (Ctrl+Alt+L)" },
      }
      if require("config.util").is_mac() then
        -- mac IntelliJ: ⌥⌘L → Reformat code
        table.insert(keys, { "<D-A-l>", format, mode = { "n", "i", "v" }, desc = "Format file (⌥⌘L)" })
      end
      return keys
    end)(),
    opts = {
      formatters_by_ft = {
        java       = { "google-java-format" },
        go         = { "goimports" },
        python     = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact   = { "prettier" },
        javascriptreact   = { "prettier" },
        vue        = { "prettier" },
        -- Svelte/Astro use the project's Prettier plugins (see README).
        svelte     = { "prettier" },
        astro      = { "prettier" },
        html       = { "prettier" },
        css        = { "prettier" },
        scss       = { "prettier" },
        less       = { "prettier" },
        json       = { "prettier" },
        jsonc      = { "prettier" },
        yaml       = { "prettier" },
        graphql    = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        handlebars = { "prettier" },
        xml        = { "prettier" },
        lua        = { "stylua" },
        sh         = { "shfmt" },
        bash       = { "shfmt" },
      },
      format_on_save = {
        timeout_ms   = 3000,
        lsp_format = "fallback",
      },
      formatters = {
        ["google-java-format"] = {
          -- AOSP style = 4-space indent (matches IntelliJ default, not Google's 2-space)
          prepend_args = { "--aosp" },
        },
        shfmt = {
          prepend_args = { "-i", "4" },
        },
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
      },
    },
  },
}

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },
    keys = {
      -- IntelliJ: Ctrl+Alt+L → Reformat code
      {
        "<C-A-l>",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "i", "v" },
        desc = "Format file (Ctrl+Alt+L)",
      },
    },
    opts = {
      formatters_by_ft = {
        java       = { "google-java-format" },
        go         = { "goimports" },
        python     = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact   = { "prettier" },
        javascriptreact   = { "prettier" },
        html       = { "prettier" },
        css        = { "prettier" },
        json       = { "prettier" },
        yaml       = { "prettier" },
        xml        = { "prettier" },
        lua        = { "stylua" },
        sh         = { "shfmt" },
        bash       = { "shfmt" },
      },
      format_on_save = {
        timeout_ms   = 3000,
        lsp_fallback = true,
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

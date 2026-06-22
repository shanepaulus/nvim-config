return {
  -- Mason: installs/manages LSP servers, formatters, DAP adapters
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed   = "✓",
          package_pending     = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Bridge: mason ↔ lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "jdtls",      -- Java (binary used by ftplugin/java.lua, NOT configured here)
        "gopls",      -- Go
        "pyright",    -- Python
        "ts_ls",      -- TypeScript / JavaScript
        -- "volar",   -- Vue 3 (add back if needed; name may vary by mason-lspconfig version)
        "html",       -- HTML
        "cssls",      -- CSS
        "tailwindcss",-- Tailwind CSS
        "jsonls",     -- JSON
        "yamlls",     -- YAML
        "lemminx",    -- XML (Maven pom.xml, Spring XML configs)
        "lua_ls",     -- Lua (editing this config)
        "bashls",     -- Bash / Shell
      },
      -- Disabled: we call vim.lsp.enable() manually below (and Java uses ftplugin/java.lua).
      -- automatic_enable = true would auto-start jdtls via lspconfig AND nvim-jdtls → conflict.
      automatic_enable = false,
    },
  },

  -- Mason tool installer: formatters + DAP adapters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Formatters
        "google-java-format",
        "prettier",
        "black",
        "goimports",
        "stylua",
        "shfmt",
        -- DAP adapters
        "java-debug-adapter",
        "java-test",
        "debugpy",
        "go-debug-adapter",
        "js-debug-adapter",
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- Core LSP configuration (all non-Java LSPs) — Neovim 0.11+ API
  -- Java goes in ftplugin/java.lua via nvim-jdtls
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Diagnostic icons (IntelliJ-like gutter symbols)
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      vim.diagnostic.config({
        virtual_text = { prefix = "●", source = "if_many" },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Shared on_attach: keymaps for every LSP buffer
      -- (Java gets these PLUS extras in ftplugin/java.lua)
      local on_attach = function(_, bufnr)
        local map = function(lhs, rhs, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        local tb = require("telescope.builtin")

        map("<C-b>",   vim.lsp.buf.definition,                  "Go to definition (Ctrl+B)")
        map("<C-b>",   vim.lsp.buf.definition,                  "Go to definition (Ctrl+B)", "i")
        map("<C-A-b>", vim.lsp.buf.implementation,              "Go to implementation (Ctrl+Alt+B)")
        map("<C-A-b>", vim.lsp.buf.implementation,              "Go to implementation (Ctrl+Alt+B)", "i")
        map("<A-F7>",  tb.lsp_references,                       "Find usages (Alt+F7)")
        map("<C-S-i>", vim.lsp.buf.hover,                       "Hover documentation (Ctrl+Shift+I)")
        map("<C-S-i>", vim.lsp.buf.hover,                       "Hover documentation (Ctrl+Shift+I)", "i")
        map("<A-CR>",  vim.lsp.buf.code_action,                 "Code action (Alt+Enter)")
        map("<A-CR>",  vim.lsp.buf.code_action,                 "Code action (Alt+Enter)", "i")
        map("<S-F6>",  vim.lsp.buf.rename,                      "Rename symbol (Shift+F6)")
        map("<C-F12>", tb.lsp_document_symbols,                 "File structure (Ctrl+F12)")
        map("<C-S-o>", tb.lsp_dynamic_workspace_symbols,        "Workspace symbols (Ctrl+Shift+O)")
        map("<C-S-o>", tb.lsp_dynamic_workspace_symbols,        "Workspace symbols (Ctrl+Shift+O)", "i")

        vim.keymap.set("i", "<C-S-p>", vim.lsp.buf.signature_help,
          { buffer = bufnr, desc = "LSP: Signature help" })

        vim.api.nvim_create_autocmd("CursorHold", {
          buffer = bufnr,
          callback = function()
            vim.diagnostic.open_float(nil, { focus = false })
          end,
        })
      end

      -- Apply shared capabilities + on_attach to ALL servers enabled below
      vim.lsp.config("*", {
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Server-specific settings (merged on top of lspconfig defaults)
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            analyses    = { unusedparams = true },
            staticcheck = true,
            gofumpt     = true,
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas  = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            keyOrdering = false,
            format      = { enable = true },
            validate    = true,
            schemaStore = { enable = false, url = "" },
            schemas     = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime     = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace   = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Enable all non-Java servers (Java uses ftplugin/java.lua via nvim-jdtls)
      vim.lsp.enable({
        "gopls",
        "pyright",
        "ts_ls",
        -- "volar",  -- Vue 3: commented out (see ensure_installed above)
        "html",
        "cssls",
        "tailwindcss",
        "jsonls",
        "yamlls",
        "lemminx",
        "lua_ls",
        "bashls",
      })
    end,
  },

  -- nvim-jdtls installed here (Mason downloads it); configured in ftplugin/java.lua
  { "mfussenegger/nvim-jdtls", ft = "java" },
}

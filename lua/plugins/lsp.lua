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
    opts = function()
      local ensure_installed = {
        "jdtls",      -- Java (binary used by ftplugin/java.lua, NOT configured here)
        "gopls",      -- Go
        "basedpyright", -- Python (pyright fork: adds the library index pyright lacks)
        "ts_ls",      -- TypeScript / JavaScript
        "vue_ls",     -- Vue 3 (hybrid mode, bridges to ts_ls for .vue TS support)
        "html",       -- HTML
        "cssls",      -- CSS
        "tailwindcss",-- Tailwind CSS
        "jsonls",     -- JSON
        "yamlls",     -- YAML
        "lemminx",    -- XML (Maven pom.xml, Spring XML configs)
        "lua_ls",     -- Lua (editing this config)
        "bashls",     -- Bash / Shell
      }

      -- Launched from a desktop launcher rather than a terminal, Neovim never
      -- sources the shell rc that puts a user-local .NET SDK on PATH, so the
      -- `dotnet` probe below would fail and C# would silently lose its LSP in
      -- exactly the sessions that are hardest to debug. Add the standard
      -- install locations ourselves when they exist and dotnet is not already
      -- resolvable (~/.dotnet is used by dotnet-install.sh on both Linux and
      -- macOS; /usr/local/share/dotnet is the macOS installer's location).
      if vim.fn.executable("dotnet") ~= 1 then
        for _, dir in ipairs({
          vim.fn.expand("~/.dotnet"),
          "/usr/local/share/dotnet",
        }) do
          if vim.fn.isdirectory(dir) == 1 then
            vim.env.PATH = vim.env.PATH .. ":" .. dir
            vim.env.DOTNET_ROOT = vim.env.DOTNET_ROOT or dir
            break
          end
        end
      end

      -- roslyn-language-server's Mason installer shells out to `dotnet` to
      -- fetch its nuget package. Without the .NET SDK on PATH the install
      -- fails every single startup, and mason-lspconfig surfaces that as a
      -- vim.notify ERROR each time — so only ask for it when it can actually
      -- install. Install the .NET SDK and restart Neovim to pick this up.
      if vim.fn.executable("dotnet") == 1 then
        table.insert(ensure_installed, "roslyn_ls")
      end

      return {
        ensure_installed = ensure_installed,
        -- Disabled: we call vim.lsp.enable() manually below (and Java uses ftplugin/java.lua).
        -- automatic_enable = true would auto-start jdtls via lspconfig AND nvim-jdtls → conflict.
        automatic_enable = false,
      }
    end,
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

      -- IntelliJ-style navigation: a single target is jumped to directly; several
      -- open a small filterable popup AT THE CURSOR instead of Neovim's default
      -- quickfix list at the bottom of the screen. Results from every attached
      -- client are merged by vim.lsp.buf.* and de-duplicated here, since e.g.
      -- .vue buffers have both vue_ls and ts_ls answering with the same location
      -- (which would otherwise show a "choice" of two identical entries).
      -- telescope.builtin.lsp_implementations is not used: on the pinned 0.1.x
      -- branch it requests each client separately (two pickers with two
      -- servers) and calls LSP util functions deprecated in Neovim 0.12.
      local function goto_or_pick(title)
        return function(list)
          local items, seen = {}, {}
          for _, item in ipairs(list.items) do
            local key = string.format("%s:%d:%d", item.filename, item.lnum, item.col)
            if not seen[key] then
              seen[key] = true
              table.insert(items, item)
            end
          end

          if #items == 1 then
            local item = items[1]
            local b = item.bufnr or vim.fn.bufadd(item.filename)
            vim.cmd("normal! m'") -- jumplist, so Alt+Left / ⌘[ returns here
            vim.bo[b].buflisted = true
            vim.api.nvim_win_set_buf(0, b)
            vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(item.col - 1, 0) })
            vim.cmd("normal! zv")
            return
          end

          if vim.fn.mode() ~= "n" then
            vim.cmd("stopinsert")
          end
          local pickers      = require("telescope.pickers")
          local finders      = require("telescope.finders")
          local make_entry   = require("telescope.make_entry")
          local conf         = require("telescope.config").values
          local opts = require("telescope.themes").get_cursor({
            previewer   = false,
            path_display = { "tail" },
            fname_width = 32,
            trim_text   = true,
            layout_config = {
              width  = math.min(110, vim.o.columns - 4),
              height = math.min(#items + 4, 16),
            },
          })
          pickers.new(opts, {
            prompt_title = string.format("%s (%d)", title, #items),
            finder = finders.new_table({
              results     = items,
              entry_maker = make_entry.gen_from_quickfix(opts),
            }),
            sorter = conf.generic_sorter(opts),
            push_cursor_on_edit   = true,
            push_tagstack_on_edit = true,
          }):find()
        end
      end

      local goto_definition = function()
        vim.lsp.buf.definition({ on_list = goto_or_pick("Choose Definition") })
      end
      local goto_implementation = function()
        vim.lsp.buf.implementation({ on_list = goto_or_pick("Choose Implementation") })
      end

      -- Shared keymaps for EVERY LSP buffer, via LspAttach rather than a shared
      -- on_attach. vim.lsp.config("*", { on_attach = ... }) is the LOWEST-priority
      -- layer: nvim-lspconfig's own lsp/<server>.lua files sit above it, and
      -- basedpyright, ts_ls and roslyn_ls each define their own on_attach, which
      -- silently replaced ours — Python, JS/TS/Vue and C# had no Ctrl+B/⌘B/⌥⌘B/
      -- Alt+F7/... at all. jdtls (ftplugin/java.lua) is started outside
      -- vim.lsp.config too. An LspAttach autocmd fires for every client no matter
      -- how it was configured or started, so these can't be overridden.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("shared_lsp_keymaps", { clear = true }),
        callback = function(event)
          local bufnr = event.buf
          local map = function(lhs, rhs, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
          end

          local tb = require("telescope.builtin")

          map("<C-b>",   goto_definition,                         "Go to definition (Ctrl+B)")
          map("<C-b>",   goto_definition,                         "Go to definition (Ctrl+B)", "i")
          map("<C-A-b>", goto_implementation,                     "Go to implementation (Ctrl+Alt+B)")
          map("<C-A-b>", goto_implementation,                     "Go to implementation (Ctrl+Alt+B)", "i")
          map("<A-F7>",  tb.lsp_references,                       "Find usages (Alt+F7)")
          map("<C-S-i>", vim.lsp.buf.hover,                       "Hover documentation (Ctrl+Shift+I)")
          map("<C-S-i>", vim.lsp.buf.hover,                       "Hover documentation (Ctrl+Shift+I)", "i")
          map("<A-CR>",  vim.lsp.buf.code_action,                 "Code action (Alt+Enter)")
          map("<A-CR>",  vim.lsp.buf.code_action,                 "Code action (Alt+Enter)", "i")
          map("<S-F6>",  vim.lsp.buf.rename,                      "Rename symbol (Shift+F6)")
          map("<C-F12>", tb.lsp_document_symbols,                 "File structure (Ctrl+F12)")
          map("<C-S-o>", tb.lsp_dynamic_workspace_symbols,        "Workspace symbols (Ctrl+Shift+O)")
          map("<C-S-o>", tb.lsp_dynamic_workspace_symbols,        "Workspace symbols (Ctrl+Shift+O)", "i")
          map("<C-S-p>", vim.lsp.buf.signature_help,              "Signature help", "i")

          -- mac IntelliJ equivalents (stock macOS keymap); ⌥F7 find usages matches already
          if require("config.util").is_mac() then
            map("<D-b>",   goto_definition,     "Go to definition (⌘B)")
            map("<D-b>",   goto_definition,     "Go to definition (⌘B)", "i")
            map("<D-A-b>", goto_implementation, "Go to implementation (⌥⌘B)")
            map("<D-A-b>", goto_implementation, "Go to implementation (⌥⌘B)", "i")
            map("<D-y>",   vim.lsp.buf.hover,          "Quick definition (⌘Y)")
          end

          -- Several clients can attach to one buffer (e.g. .vue: vue_ls + ts_ls +
          -- tailwindcss) — a per-buffer group keeps this to a single autocmd.
          vim.api.nvim_create_autocmd("CursorHold", {
            group = vim.api.nvim_create_augroup("lsp_diag_float_" .. bufnr, { clear = true }),
            buffer = bufnr,
            callback = function()
              vim.diagnostic.open_float(nil, { focus = false })
            end,
          })
        end,
      })

      -- Apply shared capabilities to ALL servers enabled below
      vim.lsp.config("*", {
        capabilities = capabilities,
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

      -- ts_ls must also attach to .vue files: vue_ls runs in hybrid mode and
      -- forwards TS requests (imports, types, etc.) to whichever ts_ls/vtsls
      -- client is attached to the same buffer.
      --
      -- Attaching is necessary but NOT sufficient. Plain tsserver cannot parse a
      -- single-file component at all, so without @vue/typescript-plugin loaded it
      -- answers every request about a .vue buffer with nothing: no completion, no
      -- auto-import, no types — while both servers still report as attached, which
      -- makes it look like a completion bug rather than a missing plugin.
      -- Mason ships the plugin inside the vue-language-server package; tsserver
      -- resolves it by name from `location`.
      local vue_ls_path = vim.fn.stdpath("data")
        .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

      local ts_ls_opts = {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
      }
      -- Guarded: on a fresh install Mason may not have fetched vue-language-server
      -- yet, and pointing tsserver at a missing plugin makes it fail to start for
      -- every JS/TS file, not just Vue ones.
      if vim.fn.isdirectory(vue_ls_path) == 1 then
        ts_ls_opts.init_options = {
          plugins = {
            {
              name      = "@vue/typescript-plugin",
              location  = vue_ls_path,
              languages = { "vue" },
            },
          },
        }
      end
      vim.lsp.config("ts_ls", ts_ls_opts)

      -- Python uses basedpyright, not pyright. Stock pyright only offers
      -- auto-imports for symbols it has already parsed, so `Path` never suggests
      -- `from pathlib import Path` — the stdlib/library index that makes
      -- auto-import work in Pylance is closed-source and absent from pyright.
      -- basedpyright is the drop-in fork that ships that index (`indexing`).
      -- Its default typeCheckingMode is "recommended", which floods an ordinary
      -- project with strictness errors, so pin it back to "standard".
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              autoImportCompletions  = true,
              indexing               = true,
              useLibraryCodeForTypes = true,
              typeCheckingMode       = "standard",
              diagnosticMode         = "openFilesOnly",
            },
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
        "basedpyright",
        "ts_ls",
        "vue_ls",
        "html",
        "cssls",
        "tailwindcss",
        "jsonls",
        "yamlls",
        "lemminx",
        "lua_ls",
        "bashls",
        "roslyn_ls",
      })
    end,
  },

  -- nvim-jdtls installed here (Mason downloads it); configured in ftplugin/java.lua
  { "mfussenegger/nvim-jdtls", ft = "java" },
}

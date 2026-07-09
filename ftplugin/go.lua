-- Go-specific keymaps on top of the shared LSP on_attach in lua/plugins/lsp.lua.
-- gopls needs no custom startup (unlike jdtls), so this only adds extra
-- code-action bindings once gopls attaches to a Go buffer.

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("go_lsp_keymaps", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "gopls" or vim.bo[event.buf].filetype ~= "go" then
      return
    end

    local map = function(lhs, rhs, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = "Go: " .. desc })
    end

    -- IntelliJ: Alt+Insert → Generate (closest gopls equivalent: fill struct / rewrite)
    local fill_struct = function()
      vim.lsp.buf.code_action({ context = { only = { "refactor.rewrite" } }, apply = true })
    end
    map("<A-Insert>", fill_struct, "Fill struct / rewrite (Alt+Insert)")
    map("<A-Insert>", fill_struct, "Fill struct / rewrite (Alt+Insert)", "i")

    -- IntelliJ: Ctrl+Alt+O → Optimize / organize imports
    -- (goimports also runs on save; this is for on-demand use mid-edit)
    local organize_imports = function()
      vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
    end
    map("<C-A-o>", organize_imports, "Organize imports (Ctrl+Alt+O)")
    map("<C-A-o>", organize_imports, "Organize imports (Ctrl+Alt+O)", "i")

    -- Extract refactorings (no direct IntelliJ equivalent, via <leader>g)
    local extract = function()
      vim.lsp.buf.code_action({ context = { only = { "refactor.extract" } }, apply = true })
    end
    map("<leader>gv", extract, "Extract variable")
    map("<leader>gv", extract, "Extract variable", "v")
    map("<leader>gf", extract, "Extract function", "v")
  end,
})

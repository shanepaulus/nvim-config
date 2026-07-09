local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Flash highlight on yank (IntelliJ-like confirmation flash)
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Resize splits when the terminal window is resized
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Restore cursor to last position when opening a file
autocmd("BufReadPost", {
  group = augroup("last_cursor_pos", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close certain utility filetypes with 'q' (like IntelliJ Escape closes tool windows)
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = {
    "help", "lspinfo", "man", "notify", "qf",
    "startuptime", "checkhealth",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-create parent directories when saving a new file to a non-existent path
autocmd("BufWritePre", {
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Java: 4-space indent (explicit, matches google-java-format --aosp)
autocmd("FileType", {
  group = augroup("ft_java", { clear = true }),
  pattern = "java",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Go: tabs, not spaces (gofmt/goimports convention)
autocmd("FileType", {
  group = augroup("ft_go", { clear = true }),
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Web files: 2-space indent (standard web convention)
autocmd("FileType", {
  group = augroup("ft_web", { clear = true }),
  pattern = { "html", "css", "javascript", "typescript", "typescriptreact",
              "javascriptreact", "json", "yaml", "lua", "xml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Text files: word wrap + spell check
autocmd("FileType", {
  group = augroup("ft_text", { clear = true }),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Typing in YAML must indent like an IDE: Enter after `key:` indents one
-- level, Enter after a comment does NOT start another comment, and typing
-- `:` never re-indents the line being typed.
--
--   nvim --headless -i NONE -c "luafile tests/yaml_typing.lua"
--
-- Exits non-zero if any check fails.

local failed = 0
local function out(s) io.stdout:write(s .. "\n") end

local file = vim.fn.tempname() .. ".yml"
vim.fn.writefile({ "server:", "  port: 8080" }, file)
vim.cmd.edit(file)

-- Lines after typing `keys` (insert-mode keys, <Esc> appended) at end of line 2.
local function type_after(keys)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "server:", "  port: 8080" })
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  vim.api.nvim_feedkeys(vim.keycode("A" .. keys .. "<Esc>"), "tx", false)
  return vim.api.nvim_buf_get_lines(0, 2, -1, false)
end

local function check(name, got, want)
  if vim.deep_equal(got, want) then
    out("PASS  " .. name)
  else
    failed = failed + 1
    out(("FAIL  %s: expected %s, got %s"):format(name, vim.inspect(want), vim.inspect(got)))
  end
end

check("Enter after `key:` indents one level",
  type_after("<CR>servlet:<CR>path: /api"),
  { "  servlet:", "    path: /api" })
check("Enter after a comment does not continue it",
  type_after("<CR># note<CR>address: 0.0.0.0"),
  { "  # note", "  address: 0.0.0.0" })
check("Enter after a value keeps the sibling indent",
  type_after("<CR>address: 0.0.0.0"),
  { "  address: 0.0.0.0" })
check("Dedent to top level, typing `:` keeps column 0",
  type_after("<CR><BS>spring:"),
  { "spring:" })

vim.cmd(failed == 0 and "qa!" or "cq")

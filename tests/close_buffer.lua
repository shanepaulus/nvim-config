-- Ctrl+F4 closes the current file but keeps the editor window, so an open
-- file explorer never expands to fill the screen.
--
--   nvim --headless -i NONE -c "luafile tests/close_buffer.lua"
--
-- Exits non-zero if any check fails.

local failed = 0
local function out(s) io.stdout:write(s .. "\n") end
local function check(name, fn)
  local ok, err = pcall(fn)
  if ok then
    out("PASS  " .. name)
  else
    failed = failed + 1
    out("FAIL  " .. name .. ": " .. tostring(err))
  end
end
local function eq(a, b, what)
  if a ~= b then error(string.format("%s: expected %s, got %s", what, vim.inspect(b), vim.inspect(a)), 0) end
end
local function press(k)
  require("lazy").load({ plugins = { "bufferline.nvim" } })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(k, true, false, true), "x", false)
end
local function name() return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t") end

local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
for _, f in ipairs({ "a.txt", "b.txt" }) do
  vim.fn.writefile({ f }, dir .. "/" .. f)
  vim.cmd.edit(dir .. "/" .. f)
end

-- Stand-in for the explorer sidebar: a fixed-width left split.
vim.cmd("topleft vertical 30new")
local sidebar = vim.api.nvim_get_current_win()
vim.cmd.wincmd("l")
local editor = vim.api.nvim_get_current_win()

check("Ctrl+F4 keeps the editor window and shows another file", function()
  press("<C-F4>")
  eq(vim.api.nvim_win_is_valid(editor), true, "editor window still open")
  eq(vim.api.nvim_win_get_width(sidebar), 30, "sidebar width")
  eq(name(), "a.txt", "file shown")
end)

check("Ctrl+F4 on the last file keeps the editor window", function()
  vim.api.nvim_set_current_win(editor)
  press("<C-F4>")
  eq(vim.api.nvim_win_is_valid(editor), true, "editor window still open")
  eq(vim.api.nvim_win_get_width(sidebar), 30, "sidebar width")
end)

vim.fn.delete(dir, "rf")
vim.cmd(failed == 0 and "qa!" or "cq")

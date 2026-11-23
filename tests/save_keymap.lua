-- Ctrl+S must save without leaving insert mode (IntelliJ-like).
--
--   nvim --headless -i NONE -c "luafile tests/save_keymap.lua"
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

local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
local file = dir .. "/sample.txt"
vim.fn.writefile({ "hello" }, file)

check("<C-s> in insert mode saves and stays in insert mode", function()
  vim.cmd("edit " .. file)
  -- Record the mode right after <C-s>, then <Esc> so feedkeys can return.
  local keys = vim.api.nvim_replace_termcodes(
    "A world<C-s><Cmd>lua _G.mode_after_save = vim.api.nvim_get_mode().mode<CR><Esc>",
    true, false, true
  )
  vim.api.nvim_feedkeys(keys, "mx", false)
  local mode = _G.mode_after_save
  if mode ~= "i" then error("expected mode 'i', got '" .. mode .. "'", 0) end
  local saved = vim.fn.readfile(file)[1]
  if saved ~= "hello world" then error("file not saved, got: " .. tostring(saved), 0) end
end)

vim.fn.delete(dir, "rf")
out(failed == 0 and "ALL PASS" or (failed .. " FAILED"))
vim.cmd(failed == 0 and "qa!" or "cq")

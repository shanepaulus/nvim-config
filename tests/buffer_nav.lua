-- Alt+Left/Right move between open buffers in tab-bar order;
-- Ctrl+Alt+Left/Right walk the jumplist.
--
--   nvim --headless -i NONE -c "luafile tests/buffer_nav.lua"
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
-- bufferline computes tab order while drawing the tabline, which headless
-- nvim never does on its own: load it and draw once before each keypress.
local function draw_tabline()
  require("lazy").load({ plugins = { "bufferline.nvim" } })
  vim.api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true })
end
local function press(k)
  draw_tabline()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(k, true, false, true), "x", false)
end
local function name() return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t") end

local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
for _, f in ipairs({ "a.txt", "b.txt", "c.txt" }) do
  vim.fn.writefile({ f, "2", "3", "4", "5" }, dir .. "/" .. f)
  vim.cmd.edit(dir .. "/" .. f)
end
vim.cmd.edit(dir .. "/b.txt") -- tabs: a b c, current b; jumplist: ... c -> b

check("Alt+Left moves to the tab on the left", function()
  press("<A-Left>")
  eq(name(), "a.txt", "buffer")
end)

check("Alt+Right moves to the tab on the right", function()
  vim.cmd.edit(dir .. "/b.txt")
  press("<A-Right>")
  eq(name(), "c.txt", "buffer")
end)

check("Ctrl+Alt+Left/Right walk the jumplist", function()
  vim.cmd.edit(dir .. "/a.txt")
  vim.cmd("normal! 4G") -- in-file jump: lands in jumplist
  press("<C-A-Left>")
  eq(vim.fn.line("."), 1, "line after jump back")
  press("<C-A-Right>")
  eq(vim.fn.line("."), 4, "line after jump forward")
end)

vim.fn.delete(dir, "rf")
vim.cmd(failed == 0 and "qa!" or "cq")

-- Terminal palette in the shane_paulus colorscheme: bright black (color 8)
-- must be readable on the editor background — zsh-autosuggestions draws its
-- ghost text in that color inside nvim terminals.
--
--   nvim --headless -i NONE -c "luafile tests/terminal_colors.lua"
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

vim.cmd.colorscheme("shane_paulus")

check("bright black (autosuggestion ghost text) is readable gray", function()
  eq(vim.g.terminal_color_8, "#808080", "terminal_color_8")
end)

vim.cmd(failed == 0 and "qa!" or "cq")

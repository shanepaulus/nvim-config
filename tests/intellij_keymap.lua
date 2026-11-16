-- Keys must match the IntelliJ keymap in use: "XWin Proper Redo"
-- (stock "Default for XWin" + Redo on Ctrl+Y / Shift+Alt+Backspace,
-- Delete Line unbound). Checks each key's mapping description, in a real
-- Java buffer with jdtls attached so LSP/Java maps are included.
--
--   nvim --headless -i NONE -c "luafile tests/intellij_keymap.lua"
--
-- Starts jdtls, so it takes ~30s. Exits non-zero on failure.

local failed = 0
local function out(s) io.stdout:write(s .. "\n") end

local dir = vim.fn.resolve(vim.fn.tempname()) .. "/src/com/acme"
vim.fn.mkdir(dir, "p")
vim.fn.writefile({ "package com.acme;", "", "public class A {}" }, dir .. "/A.java")
vim.cmd.edit(dir .. "/A.java")
vim.wait(60000, function() return #vim.lsp.get_clients({ bufnr = 0, name = "jdtls" }) > 0 end, 200)
vim.wait(1000)

-- { modes, key, pattern the description must match (plain, case-insensitive) }
local expected = {
  -- editing
  { "ni",  "<C-z>",       "undo" },
  { "ni",  "<A-BS>",      "undo" },
  { "ni",  "<C-S-z>",     "redo" },
  { "ni",  "<C-y>",       "redo" },
  { "ni",  "<S-A-BS>",    "redo" },
  { "niv", "<A-S-Up>",    "move line up" },
  { "niv", "<A-S-Down>",  "move line down" },
  { "niv", "<C-S-Up>",    "move statement up" },
  { "niv", "<C-S-Down>",  "move statement down" },
  { "niv", "<C-S-j>",     "join lines" },
  { "nv",  "<C-S-u>",     "toggle case" },
  { "ni",  "<S-CR>",      "start new line" },
  { "ni",  "<C-A-CR>",    "new line before" },
  { "nv",  "<C-A-i>",     "auto-indent" },
  { "i",   "<C-BS>",      "delete to word start" },
  { "i",   "<C-Del>",     "delete to word end" },
  { "ni",  "<C-Up>",      "scroll up" },
  { "ni",  "<C-Down>",    "scroll down" },
  -- treesitter incremental selection; its descriptions are its own
  { "n",   "<C-w>",       "selecting nodes" },
  { "i",   "<C-w>",       "extend selection" },
  { "x",   "<C-w>",       "increment selection" },
  { "x",   "<C-S-w>",     "shrink selection" },
  { "n",   "<A-Up>",      "previous method" },
  { "n",   "<A-Down>",    "next method" },
  -- multiple carets
  { "n",   "<A-j>",       "select next occurrence" },
  { "n",   "<C-A-S-j>",   "select all occurrences" },
  -- find / replace
  { "ni",  "<C-f>",       "find in file" },
  { "ni",  "<C-r>",       "replace in file" },
  { "n",   "<F3>",        "find next" },
  { "n",   "<C-l>",       "find next" },
  { "n",   "<S-F3>",      "find previous" },
  { "n",   "<C-S-l>",     "find previous" },
  { "n",   "<C-F3>",      "find word at caret" },
  { "ni",  "<C-S-f>",     "find in files" },
  { "ni",  "<C-S-r>",     "replace in files" },
  -- navigation
  { "n",   "<C-n>",       "go to class" },
  { "ni",  "<C-S-n>",     "go to file" },
  { "ni",  "<C-A-S-n>",   "go to symbol" },
  { "ni",  "<C-S-a>",     "find action" },
  { "ni",  "<C-e>",       "recent files" },
  { "ni",  "<C-S-e>",     "recent locations" },
  { "ni",  "<C-S-BS>",    "last edit location" },
  { "n",   "<S-A-Left>",  "previous tab" },
  { "n",   "<S-A-Right>", "next tab" },
  { "n",   "<C-S-F4>",    "close" },
  -- code insight (LSP)
  { "ni",  "<C-q>",       "quick documentation" },
  { "ni",  "<C-p>",       "parameter info" },
  { "ni",  "<C-S-p>",     "type info" },
  { "ni",  "<C-S-i>",     "quick definition" },
  { "ni",  "<C-S-b>",     "type declaration" },
  { "n",   "<C-h>",       "type hierarchy" },
  { "n",   "<C-A-7>",     "show usages" },
  { "n",   "<C-S-F7>",    "highlight usages" },
  { "ni",  "<C-F1>",      "error description" },
  { "n",   "<F4>",        "jump to source" },
  { "nv",  "<C-A-S-t>",   "refactor this" },
  -- Java
  { "ni",  "<C-i>",       "implement methods" },
  { "ni",  "<C-o>",       "override methods" },
  { "nv",  "<C-A-v>",     "introduce variable" },
  { "nv",  "<C-A-m>",     "extract method" },
  { "nv",  "<C-A-c>",     "introduce constant" },
  { "nv",  "<C-A-f>",     "introduce field" },
  { "nv",  "<C-A-p>",     "introduce parameter" },
  { "nv",  "<C-A-n>",     "inline" },
  { "n",   "<F6>",        "move" },
  { "n",   "<C-F6>",      "change signature" },
  { "n",   "<C-u>",       "super method" },
  { "ni",  "<C-S-t>",     "go to test" },
  { "ni",  "<A-Insert>",  "generate" },
  -- run / debug
  { "n",   "<S-F10>",     "run" },
  { "n",   "<C-S-F10>",   "run" },
  { "n",   "<S-F9>",      "debug" },
  { "n",   "<F9>",        "resume" },
  { "n",   "<C-F8>",      "toggle line breakpoint" },
  { "n",   "<C-S-F8>",    "view breakpoints" },
  { "n",   "<S-F7>",      "step into" },
  { "n",   "<A-F9>",      "run to cursor" },
  { "n",   "<A-F8>",      "evaluate" },
  { "n",   "<C-F5>",      "rerun" },
  -- tool windows
  { "n",   "<A-F12>",     "terminal" },
  { "n",   "<A-4>",       "run" },
  { "n",   "<A-5>",       "debug" },
  { "n",   "<A-6>",       "problems" },
  { "n",   "<A-7>",       "structure" },
  { "n",   "<A-9>",       "version control" },
  { "n",   "<A-0>",       "commit" },
}

-- Keys the active IntelliJ keymap leaves unbound: must not be mapped.
local unbound = {
  { "ni", "<C-S-d>" }, -- Delete Line was unbound in "XWin Proper Redo"
  { "n",  "<F5>" },
  { "n",  "<A-k>" },
}

local function desc(mode, lhs)
  local m = vim.fn.maparg(lhs, mode, false, true)
  return m and m.desc or nil
end

for _, e in ipairs(expected) do
  for mode in e[1]:gmatch(".") do
    local d = desc(mode, e[2])
    if d and d:lower():find(e[3], 1, true) then
      out("PASS  " .. mode .. " " .. e[2] .. " → " .. d)
    else
      failed = failed + 1
      out("FAIL  " .. mode .. " " .. e[2] .. ": want '" .. e[3] .. "', got " .. tostring(d))
    end
  end
end

for _, e in ipairs(unbound) do
  for mode in e[1]:gmatch(".") do
    local d = desc(mode, e[2])
    if d then
      failed = failed + 1
      out("FAIL  " .. mode .. " " .. e[2] .. " should be unbound, got " .. d)
    else
      out("PASS  " .. mode .. " " .. e[2] .. " unbound")
    end
  end
end

out(failed == 0 and "ALL PASS" or (failed .. " FAILED"))
for _, c in ipairs(vim.lsp.get_clients()) do c:stop(true) end
vim.fn.delete(vim.fn.fnamemodify(dir, ":h:h:h"), "rf")
vim.cmd(failed == 0 and "qa!" or "cq")

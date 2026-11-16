-- Alt+Enter must behave like IntelliJ: offer the quick fixes for EVERY
-- error on the cursor line, not just the one under the cursor, and applying
-- "Add unimplemented methods" must generate the missing override.
--
--   nvim --headless -i NONE -c "luafile tests/java_quickfix.lua"
--
-- Starts a real jdtls, so it takes ~30s. Exits non-zero on failure.

local failed = 0
local function out(s) io.stdout:write(s .. "\n") end
local function check(name, ok, detail)
  if ok then
    out("PASS  " .. name)
  else
    failed = failed + 1
    out("FAIL  " .. name .. (detail and (": " .. detail) or ""))
  end
end

local dir = vim.fn.resolve(vim.fn.tempname()) .. "/src/com/acme"
vim.fn.mkdir(dir, "p")
vim.fn.writefile({
  "package com.acme;",
  "",
  "public abstract sealed class Shape permits Circle {",
  "    public abstract void describe();",
  "}",
}, dir .. "/Shape.java")
vim.fn.writefile({ "package com.acme;", "", "public final class Circle extends Shape {", "    public void describe() {}", "}" }, dir .. "/Circle.java")
vim.fn.writefile({ "package com.acme;", "", "public class Triangle extends Shape {}" }, dir .. "/Triangle.java")

vim.cmd.edit(dir .. "/Triangle.java")
vim.wait(90000, function() return #vim.diagnostic.get(0) >= 3 end, 200)

-- Cursor on `public`: no diagnostic starts here, but the line has errors.
vim.api.nvim_win_set_cursor(0, { 3, 0 })
local titles, pick
vim.ui.select = function(items, opts, on_choice)
  titles = vim.tbl_map(opts.format_item, items)
  if pick then
    for i, t in ipairs(titles) do
      if t == pick then return on_choice(items[i], i) end
    end
  end
end
vim.api.nvim_feedkeys(vim.keycode("<M-CR>"), "x", false)
vim.wait(20000, function() return titles ~= nil end)
titles = titles or {}

local function has(t) return vim.tbl_contains(titles, t) end
check("Alt+Enter offers 'Add unimplemented methods' anywhere on the line",
  has("Add unimplemented methods"), vim.inspect(titles))
check("Alt+Enter offers fixes for other errors on the line",
  has("Declare 'Triangle' as permitted subtype of 'Shape'"), vim.inspect(titles))

titles, pick = nil, "Add unimplemented methods"
vim.api.nvim_feedkeys(vim.keycode("<M-CR>"), "x", false)
local text = ""
vim.wait(20000, function()
  text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  return text:find("describe") ~= nil
end, 200)
check("applying it generates the override", text:find("public void describe%(%)") ~= nil, text)

-- Ctrl+I (Implement Methods) on a fresh copy: no menu, implements every
-- abstract method straight away like IntelliJ's pre-selected dialog.
vim.fn.writefile({ "package com.acme;", "", "public final class Square extends Shape {}" }, dir .. "/Square.java")
vim.cmd.edit(dir .. "/Square.java")
vim.wait(30000, function() return #vim.diagnostic.get(0) >= 1 end, 200)
vim.api.nvim_win_set_cursor(0, { 3, 0 })
vim.api.nvim_feedkeys(vim.keycode("<C-i>"), "x", false)
vim.wait(20000, function()
  text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  return text:find("describe") ~= nil
end, 200)
check("Ctrl+I implements the abstract methods", text:find("public void describe%(%)") ~= nil, text)

for _, c in ipairs(vim.lsp.get_clients()) do c:stop(true) end
vim.fn.delete(vim.fn.fnamemodify(dir, ":h:h:h"), "rf")
vim.cmd(failed == 0 and "qa!" or "cq")

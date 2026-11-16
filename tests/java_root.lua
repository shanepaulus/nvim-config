-- jdtls must start for a plain Java folder (no build file, no .git).
-- The root is the source root implied by the file's `package` line, so a
-- file in <dir>/com/acme/ declaring `package com.acme;` gets root <dir>.
-- Using the file's own directory instead makes jdtls report
--   The declared package "com.acme" does not match the expected package ""
--
--   nvim --headless -i NONE -c "luafile tests/java_root.lua"
--
-- Exits non-zero on failure.

local failed = 0
local function out(s) io.stdout:write(s .. "\n") end

local function root_for(dir, rel, lines)
  local file = dir .. "/" .. rel
  vim.fn.mkdir(vim.fn.fnamemodify(file, ":h"), "p")
  vim.fn.writefile(lines, file)
  vim.cmd.edit(file)
  local client = vim.wait(5000, function()
    return #vim.lsp.get_clients({ bufnr = 0, name = "jdtls" }) > 0
  end) and vim.lsp.get_clients({ bufnr = 0, name = "jdtls" })[1]
  return client and client.config.root_dir or "no client"
end

local function check(name, got, want)
  if got == want then
    out("PASS  " .. name)
  else
    failed = failed + 1
    out("FAIL  " .. name .. ": expected " .. want .. ", got " .. tostring(got))
  end
end

local dir = vim.fn.resolve(vim.fn.tempname())
check("default package: root is the file's folder",
  root_for(dir .. "/a", "Demo.java", { "public class Demo {}" }), dir .. "/a")

check("packaged file: root is the source root above the package dirs",
  root_for(dir .. "/b", "src/com/acme/Demo.java", { "package com.acme;", "", "public class Demo {}" }),
  dir .. "/b/src")

for _, c in ipairs(vim.lsp.get_clients()) do c:stop(true) end
vim.fn.delete(dir, "rf")
vim.cmd(failed == 0 and "qa!" or "cq")

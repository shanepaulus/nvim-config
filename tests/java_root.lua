-- jdtls must start for a plain Java folder (no build file, no .git),
-- using the file's own directory as the project root.
--
--   nvim --headless -i NONE -c "luafile tests/java_root.lua"
--
-- Exits non-zero on failure.

local function out(s) io.stdout:write(s .. "\n") end

local dir = vim.fn.resolve(vim.fn.tempname())
vim.fn.mkdir(dir, "p")
local file = dir .. "/Demo.java"
vim.fn.writefile({ "public class Demo {}" }, file)

vim.cmd.edit(file)

local client = vim.wait(5000, function()
  return #vim.lsp.get_clients({ bufnr = 0, name = "jdtls" }) > 0
end) and vim.lsp.get_clients({ bufnr = 0, name = "jdtls" })[1]

local ok = client and client.config.root_dir == dir
if ok then
  out("PASS  jdtls starts for loose Java folder with root " .. dir)
else
  out("FAIL  jdtls root: expected " .. dir .. ", got "
    .. tostring(client and client.config.root_dir or "no client"))
end

for _, c in ipairs(vim.lsp.get_clients()) do c:stop(true) end
vim.fn.delete(dir, "rf")
vim.cmd(ok and "qa!" or "cq")

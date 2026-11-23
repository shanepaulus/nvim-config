-- Java format-on-save must keep anonymous classes / lambdas compact
-- (IntelliJ-like), not google-java-format's deep rectangle wrapping.
--
--   nvim --headless -i NONE -c "luafile tests/java_format.lua"
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
local file = dir .. "/Main.java"
vim.fn.writefile({
  "public class Main {",
  "public static void main(String[] args) {",
  "Thread thread = new Thread(new Runnable() {",
  "@Override",
  "public void run() {",
  "// body",
  "}",
  "});",
  "}",
  "}",
}, file)

check("anonymous class stays on the declaration line, 4-space indent", function()
  vim.cmd("edit " .. file)
  require("lazy").load({ plugins = { "conform.nvim" } })
  require("conform").format({ bufnr = 0, async = false, timeout_ms = 10000, lsp_format = "never" })
  local got = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local want = {
    "public class Main {",
    "    public static void main(String[] args) {",
    "        Thread thread = new Thread(new Runnable() {",
    "            @Override",
    "            public void run() {",
    "                // body",
    "            }",
    "        });",
    "    }",
    "}",
  }
  if not vim.deep_equal(got, want) then
    error("got:\n" .. table.concat(got, "\n"), 0)
  end
end)

vim.fn.delete(dir, "rf")
out(failed == 0 and "ALL PASS" or (failed .. " FAILED"))
vim.cmd(failed == 0 and "qa!" or "cq")

-- Accepting a Java method completion with Enter leaves you in insert mode with
-- the cursor inside the parentheses (IntelliJ behaviour). It must not drop into
-- select mode on a guessed `null` argument.
--
--   nvim --headless -i NONE -c "luafile tests/java_completion.lua"
--
-- Needs jdtls installed via Mason. Exits non-zero on failure.

local dir = vim.fn.tempname()
vim.fn.mkdir(dir .. "/src/demo", "p")
vim.fn.writefile({
  "package demo;",
  "",
  "import java.util.ArrayList;",
  "import java.util.List;",
  "",
  "public class Demo {",
  "    private final List<Runnable> tasks = new ArrayList<>();",
  "",
  "    public void executeAll() {",
  "        ",
  "    }",
  "}",
}, dir .. "/src/demo/Demo.java")
vim.fn.system({ "git", "init", "-q", dir })
vim.cmd("cd " .. dir)
vim.cmd("edit src/demo/Demo.java")

local function out(s) io.stdout:write(s .. "\n") end
local function keys(s) vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s, true, false, true), "t", false) end
local function finish(ok, msg)
  out((ok and "PASS  " or "FAIL  ") .. "Enter on method completion: " .. msg)
  vim.cmd(ok and "qa!" or "cq")
end

local function verify()
  local line = vim.api.nvim_get_current_line()
  local col  = vim.api.nvim_win_get_cursor(0)[2]
  local mode = vim.api.nvim_get_mode().mode
  local state = string.format("line=%q col=%d mode=%s", line, col, mode)
  if mode ~= "i" then return finish(false, "expected insert mode, " .. state) end
  if line:sub(col, col) ~= "(" then return finish(false, "expected cursor after '(', " .. state) end
  finish(true, state)
end

local function pick()
  local cmp = require("cmp")
  local entries = cmp.get_entries() or {}
  local target
  for i, e in ipairs(entries) do
    if e:get_completion_item().label == "forEach" then target = i break end
  end
  if not target then return finish(false, "forEach not offered (" .. #entries .. " entries)") end
  for _ = 1, target - 1 do keys("<C-n>") end
  vim.defer_fn(function()
    keys("<CR>")
    vim.defer_fn(verify, 4000)
  end, 1500)
end

local function wait_jdtls(n)
  if #vim.lsp.get_clients({ name = "jdtls", bufnr = 0 }) > 0 then
    vim.defer_fn(function()
      keys("<Esc>10GA")
      vim.defer_fn(function()
        keys("this.tasks.forE")
        vim.defer_fn(pick, 7000)
      end, 2000)
    end, 20000)
  elseif n > 0 then
    vim.defer_fn(function() wait_jdtls(n - 1) end, 1000)
  else
    finish(false, "jdtls never attached")
  end
end
vim.defer_fn(function() wait_jdtls(90) end, 1000)

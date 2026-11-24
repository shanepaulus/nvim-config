-- Completion is disabled in Kubernetes manifests, kept in other YAML.
--
--   nvim --headless -i NONE -c "luafile tests/k8s.lua"
--
-- Exits non-zero if any check fails.

local failed = 0
local function out(s) io.stdout:write(s .. "\n") end
local function check(name, lines, want)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local got = require("config.util").is_k8s_manifest(buf)
  if got == want then
    out("PASS  " .. name)
  else
    failed = failed + 1
    out(string.format("FAIL  %s: expected %s, got %s", name, want, got))
  end
end

check("deployment", { "apiVersion: apps/v1", "kind: Deployment", "metadata:", "  name: x" }, true)
check("comment header", { "# license", "---", "kind: Service", "apiVersion: v1" }, true)
check("compose file", { "services:", "  web:", "    image: nginx" }, false)
check("kind only", { "kind: something" }, false)
check("nested keys", { "spec:", "  apiVersion: v1", "  kind: Pod" }, false)
check("empty", { "" }, false)

-- cmp must honour it for yaml buffers
local cmp = require("cmp")
local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(buf)
vim.bo[buf].filetype = "yaml"
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "apiVersion: v1", "kind: Pod" })
local function cmp_enabled()
  local enabled = require("cmp.config").get().enabled
  if type(enabled) == "function" then enabled = enabled() end
  return enabled
end
local function check_cmp(name, want)
  local got = cmp_enabled()
  if got == want then
    out("PASS  " .. name)
  else
    failed = failed + 1
    out(string.format("FAIL  %s: expected %s, got %s", name, want, got))
  end
end

check_cmp("cmp disabled in manifest", false)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "services:", "  web: {}" })
check_cmp("cmp enabled in other yaml", true)

vim.cmd(failed == 0 and "qa!" or "cq")

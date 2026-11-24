local M = {}

-- True on macOS; NVIM_MAC_KEYS=1 forces it on for testing the mac maps elsewhere
function M.is_mac()
  return vim.fn.has("mac") == 1 or vim.env.NVIM_MAC_KEYS == "1"
end

-- True when the buffer looks like a Kubernetes manifest: top-level `apiVersion:`
-- and `kind:` keys within the first 200 lines.
function M.is_k8s_manifest(buf)
  local api, kind = false, false
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 200, false)) do
    api  = api  or line:match("^apiVersion:") ~= nil
    kind = kind or line:match("^kind:") ~= nil
    if api and kind then return true end
  end
  return false
end

return M

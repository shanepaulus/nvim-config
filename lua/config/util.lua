local M = {}

-- True on macOS; NVIM_MAC_KEYS=1 forces it on for testing the mac maps elsewhere
function M.is_mac()
  return vim.fn.has("mac") == 1 or vim.env.NVIM_MAC_KEYS == "1"
end

return M

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend",
      "ClaudeCodeAdd", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny",
    },
    opts = {},
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>",           desc = "Claude: Toggle" },
      { "<leader>cc", "<cmd>ClaudeCodeSend<cr>",       mode = "v", desc = "Claude: Send selection" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>",      desc = "Claude: Focus" },
      { "<leader>ca", "<cmd>ClaudeCodeAdd %<cr>",      desc = "Claude: Add current file" },
      { "<leader>ca", "<cmd>ClaudeCodeAdd<cr>",        mode = "v", desc = "Claude: Add selection" },
      { "<leader>cy", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: Accept diff" },
      { "<leader>cn", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Claude: Reject diff" },
    },
  },
}

return {
  {
    "zbirenbaum/copilot.lua",
    -- Auth/LSP backend only -- CopilotChat.nvim rides on this for auth.
    -- Inline ghost-text and cmp integration are intentionally left off.
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
      "CopilotChat", "CopilotChatToggle", "CopilotChatExplain",
      "CopilotChatTests", "CopilotChatFix", "CopilotChatReview",
    },
    opts = {},
    keys = {
      { "<leader>ch", "<cmd>CopilotChatToggle<cr>",  desc = "Copilot Chat: Toggle" },
      { "<leader>ch", "<cmd>CopilotChatToggle<cr>",  mode = "v", desc = "Copilot Chat: Toggle" },
      { "<leader>ce", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, desc = "Copilot Chat: Explain" },
      { "<leader>ct", "<cmd>CopilotChatTests<cr>",   mode = { "n", "v" }, desc = "Copilot Chat: Tests" },
      { "<leader>cx", "<cmd>CopilotChatFix<cr>",     mode = { "n", "v" }, desc = "Copilot Chat: Fix" },
      { "<leader>cr", "<cmd>CopilotChatReview<cr>",  mode = { "n", "v" }, desc = "Copilot Chat: Review" },
    },
  },
}

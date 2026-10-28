return {
  -- Breadcrumbs in the winbar (IntelliJ navigation bar / breadcrumbs)
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = (function()
      local pick = function() require("dropbar.api").pick() end
      local keys = {
        { "<A-Home>", pick, desc = "Jump to navigation bar (Alt+Home)" },
      }
      if require("config.util").is_mac() then
        -- mac IntelliJ: ⌘↑ → Jump to Navigation Bar
        table.insert(keys, { "<D-Up>", pick, desc = "Jump to navigation bar (⌘↑)" })
      end
      return keys
    end)(),
    opts = {},
  },
}

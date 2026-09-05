return {
  {
    "hrsh7th/nvim-cmp",
    -- Pinned just before hrsh7th/nvim-cmp@2ffe79f ("fix(#1303): TextChanged
    -- should update completion only on text added"), which requires the
    -- cursor to advance by exactly one column between consecutive
    -- TextChangedI events to trigger auto-completion. Any burst where two+
    -- characters land in a single TextChangedI (normal fast typing,
    -- autoindent, etc.) gets silently dropped, breaking IntelliJ-style
    -- as-you-type suggestions. Unpin once upstream fixes this without
    -- reintroducing #1303 (https://github.com/hrsh7th/nvim-cmp/issues/1303).
    commit = "7d850f3daf38462c4760adae9cfdbd3417bbc01c",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      local kind_icons = {
        Text          = "󰉿", Method      = "󰆧", Function    = "󰊕",
        Constructor   = "",  Field       = "󰜢", Variable    = "󰀫",
        Class         = "󰠱", Interface   = "",  Module      = "",
        Property      = "󰜢", Unit        = "󰑭", Value       = "󰎠",
        Enum          = "",  Keyword     = "󰌋", Snippet     = "",
        Color         = "󰏘", File        = "󰈙", Reference   = "󰈇",
        Folder        = "󰉋", EnumMember  = "",  Constant    = "󰏿",
        Struct        = "󰙅", Event       = "",  Operator    = "󰆕",
        TypeParameter = "",
      }

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"]     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-k>"]     = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          -- Tab: accept selected item or expand snippet (IntelliJ Tab-to-complete)
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Shift+Tab: jump back in snippet
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Enter: confirm without selecting (only if explicitly highlighted)
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500, keyword_length = 3 },
          { name = "path",     priority = 250 },
        }),
        formatting = {
          format = function(entry, item)
            item.kind = string.format("%s %s", kind_icons[item.kind] or "", item.kind)
            item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip  = "[Snip]",
              buffer   = "[Buf]",
              path     = "[Path]",
            })[entry.source.name] or ""
            return item
          end,
        },
        experimental = { ghost_text = { hl_group = "CmpGhostText" } },
      })

      -- C#: re-issue the completion request until roslyn_ls catches up.
      --
      -- Immediately after a keystroke roslyn_ls answers with a STALE, truncated
      -- snapshot that it marks `isIncomplete = false`. nvim-cmp trusts that, caches
      -- the slice and never re-queries, so the menu stays empty for anything past a
      -- couple of characters. The identical request a moment later is answered
      -- correctly. Measured, same position, same buffer text "StringBuil":
      --   +60ms   -> 545 items,  isIncomplete=false, StringBuilder absent
      --   +2000ms -> 1000 items, isIncomplete=true,  StringBuilder present
      -- So re-ask after the server settles. The delay it needs varies with project
      -- size and machine, and a single fixed delay was measured failing at 250, 500
      -- and 800ms, so retry on a short ladder and stop as soon as entries arrive.
      -- Scoped to cs: every other server labels its responses honestly.
      local cs_timers = {}
      local function cs_cancel()
        for _, t in ipairs(cs_timers) do
          t:stop()
        end
        cs_timers = {}
      end

      vim.api.nvim_create_autocmd("TextChangedI", {
        group = vim.api.nvim_create_augroup("CmpRoslynRequery", { clear = true }),
        callback = function()
          if vim.bo.filetype ~= "cs" then
            return
          end
          cs_cancel()
          for _, delay in ipairs({ 400, 1000, 2000 }) do
            table.insert(cs_timers, vim.defer_fn(function()
              if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" or vim.bo.filetype ~= "cs" then
                return
              end
              -- Already showing something: the server has caught up, leave it be
              -- rather than resetting the menu under the cursor.
              if #(cmp.get_entries() or {}) > 0 then
                return
              end
              local col    = vim.api.nvim_win_get_cursor(0)[2]
              local before = vim.api.nvim_get_current_line():sub(1, col)
              -- Only with a real word to filter on: re-asking after `.` or a space
              -- would fight cmp's own trigger-character handling.
              local word = before:match("[%w_]+$")
              if word and #word >= 2 then
                cmp.complete()
              end
            end, delay))
          end
        end,
      })

      -- A pending re-ask must not fire into a closed menu or another buffer.
      vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
        group = "CmpRoslynRequery",
        callback = cs_cancel,
      })
    end,
  },
}

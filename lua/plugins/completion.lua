return {
  {
    "hrsh7th/nvim-cmp",
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
    end,
  },
}

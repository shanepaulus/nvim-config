return {
  {
    "3rd/image.nvim",
    -- Renders inline in Neovim itself via the kitty graphics protocol
    -- (WezTerm/Ghostty/Kitty). SVGs are rasterized through rsvg-convert
    -- (system dep: librsvg2-bin), so they'll only show up once that's
    -- installed -- other image types work regardless.
    ft = { "markdown" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = { enabled = true },
      },
    },
  },

  -- Already a dependency of claudecode.nvim; opt into its image module so
  -- opening a .svg/.png/.jpg file directly (:e file.svg) renders it in
  -- place instead of showing raw bytes.
  {
    "folke/snacks.nvim",
    opts = {
      image = { enabled = true, doc = { enabled = true } },
    },
  },
}

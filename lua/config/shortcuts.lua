-- Shortcut finder (F1): every keymap in this config that has a description,
-- searchable by name or key. Enter runs the selected shortcut, like IntelliJ's
-- Find Action. Maps without a description (plugin internals) are left out.
local M = {}

function M.entry_maker(opts)
  local make
  return function(keymap)
    if (keymap.desc or "") == "" then return nil end
    -- created lazily: telescope sets opts.width_lhs just before building entries
    make = make or require("telescope.make_entry").gen_from_keymaps(opts)
    return make(keymap)
  end
end

function M.open()
  local opts = { modes = { "n", "x" }, show_plug = false, prompt_title = "Shortcuts (Enter runs it)" }
  opts.entry_maker = M.entry_maker(opts)
  require("telescope.builtin").keymaps(opts)
end

return M

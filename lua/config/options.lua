local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false
opt.cmdheight = 1
opt.pumheight = 10
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.list = false

-- Indentation (4 spaces — IntelliJ default)
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Files & history
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.backup = false
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 300

-- Splits (IntelliJ-like panel placement)
opt.splitbelow = true
opt.splitright = true

-- System clipboard — makes y/p work like IntelliJ Ctrl+C/Ctrl+V
opt.clipboard = "unnamedplus"

-- `unnamedplus` only reaches the OS clipboard through an external provider
-- (xclip/xsel on X11, wl-copy on Wayland, pbcopy on macOS). With none of them
-- installed Neovim silently keeps every yank to itself — copying here and
-- pasting into another app just produces the previous clipboard contents.
-- Fall back to OSC 52, which pushes the yank through the terminal emulator
-- itself and needs no system package. Paste is served from Neovim's own
-- register: reading the clipboard over OSC 52 requires the terminal to answer
-- a query, which most either refuse or prompt for, so requesting it would
-- stall every `p`. Install xclip (or wl-clipboard) for true two-way sync.
local function has_clipboard_provider()
  for _, exe in ipairs({
    "xclip", "xsel", "wl-copy", "pbcopy",
    "win32yank.exe", "termux-clipboard-set", "lemonade", "doitclient",
  }) do
    if vim.fn.executable(exe) == 1 then
      return true
    end
  end
  return false
end

if not has_clipboard_provider() then
  local osc52 = require("vim.ui.clipboard.osc52")
  -- getreg(..., 1, true) yields the register as a proper line list, and
  -- getregtype preserves charwise/linewise/blockwise — splitting the raw
  -- string instead would turn every linewise yank into a stray blank line.
  local from_unnamed = function()
    return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy  = { ["+"] = osc52.copy("+"),   ["*"] = osc52.copy("*") },
    paste = { ["+"] = from_unnamed,      ["*"] = from_unnamed },
  }
end

-- Full mouse support
opt.mouse = "a"

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Misc
opt.conceallevel = 0
opt.fileencoding = "utf-8"
opt.writebackup = false
opt.shortmess:append("c")
opt.isfname:append("@-@")

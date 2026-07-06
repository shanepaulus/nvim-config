local map = function(modes, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true, desc = desc }, opts or {})
  vim.keymap.set(modes, lhs, rhs, opts)
end

-- ============================================================
-- Vim defaults overridden for IntelliJ muscle memory:
--   <C-d>  scroll half-page down  → duplicate line
--   <C-b>  scroll page up         → go to definition (lsp.lua)
--   <C-e>  scroll 1 line down     → recent files (telescope.lua)
--   <C-g>  show file info         → go to line
--   <C-z>  suspend process        → undo
--   <C-a>  increment number       → select all
--   <C-v>  visual block           → paste  (visual block → <C-q>)
-- ============================================================

-- Save
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", "Save (Ctrl+S)")

-- Undo / Redo
map({ "n", "i" }, "<C-z>",   "<cmd>undo<cr>", "Undo (Ctrl+Z)")
map({ "n", "i" }, "<C-S-z>", "<cmd>redo<cr>", "Redo (Ctrl+Shift+Z)")
map({ "n", "i" }, "<C-y>",   "<cmd>redo<cr>", "Redo (Ctrl+Y)")

-- Select all
map({ "n", "i" }, "<C-a>", "ggVG", "Select all (Ctrl+A)")

-- Clipboard (system clipboard set via opt.clipboard = unnamedplus so y/p already sync;
-- these add IntelliJ Ctrl+C / Ctrl+V muscle memory on top)
map("v", "<C-c>", '"+y', "Copy to clipboard (Ctrl+C)")
map({ "n", "i", "v" }, "<C-v>", '"+p', "Paste from clipboard (Ctrl+V)")
-- Visual block mode: use Ctrl+V in normal mode (we override Ctrl+V to paste only in insert/visual)
-- (no separate visual block binding — enter normal mode first, then Ctrl+V works)

-- Duplicate line (IntelliJ Ctrl+D)
map("n", "<C-d>", "yyp",       "Duplicate line (Ctrl+D)")
map("i", "<C-d>", "<esc>yypi", "Duplicate line (Ctrl+D)")
map("v", "<C-d>", "y`>p",      "Duplicate selection (Ctrl+D)")

-- Move lines — Alt+J/K (Shift+Alt+Up/Down reserved for Switch plugin)
map("n", "<A-k>", "<cmd>m .-2<cr>==",        "Move line up (Alt+K)")
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", "Move line up (Alt+K)")
map("v", "<A-k>", ":m '<-2<cr>gv=gv",        "Move selection up (Alt+K)")
map("n", "<A-j>", "<cmd>m .+1<cr>==",        "Move line down (Alt+J)")
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", "Move line down (Alt+J)")
map("v", "<A-j>", ":m '>+1<cr>gv=gv",        "Move selection down (Alt+J)")

-- Delete line (IntelliJ Ctrl+Shift+D)
map({ "n", "i" }, "<C-S-d>", "<cmd>d<cr>", "Delete line (Ctrl+Shift+D)")

-- Toggle whitespace visibility (IntelliJ Ctrl+Alt+W)
map({ "n", "i" }, "<C-A-w>", "<cmd>set list!<cr>", "Toggle whitespace (Ctrl+Alt+W)")

-- Toggle comment (IntelliJ Ctrl+/)
-- Works with Comment.nvim loaded in plugins/editor.lua
local comment_n = function()
  require("Comment.api").toggle.linewise.current()
end
local comment_i = function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
  require("Comment.api").toggle.linewise.current()
end
local comment_v = function()
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end
map("n", "<C-/>", comment_n, "Toggle comment (Ctrl+/)")
map("i", "<C-/>", comment_i, "Toggle comment (Ctrl+/)")
map("v", "<C-/>", comment_v, "Toggle comment (Ctrl+/)")

-- Go to line (IntelliJ Ctrl+G)
local goto_line = function()
  local line = vim.fn.input("Go to line: ")
  if line ~= "" then
    vim.cmd(":" .. line)
  end
end
map({ "n", "i" }, "<C-g>", goto_line, "Go to line (Ctrl+G)")

-- Jump back / forward (IntelliJ Alt+Left / Alt+Right)
map("n", "<A-Left>",  "<C-o>", "Jump back (Alt+Left)")
map("n", "<A-Right>", "<C-i>", "Jump forward (Alt+Right)")

-- Buffer navigation (IntelliJ Ctrl+Tab / Ctrl+Shift+Tab / Ctrl+F4)
map("n", "<C-Tab>",   "<cmd>bnext<cr>",     "Next buffer (Ctrl+Tab)")
map("n", "<C-S-Tab>", "<cmd>bprevious<cr>", "Prev buffer (Ctrl+Shift+Tab)")
map("n", "<C-F4>",    "<cmd>bdelete<cr>",   "Close buffer (Ctrl+F4)")  -- may be intercepted by terminal
map({ "n", "i" }, "<C-q>", "<cmd>bdelete<cr>", "Close buffer (Ctrl+Q)")

-- Window navigation (Ctrl+hjkl)
map("n", "<C-h>", "<C-w>h", "Window left")
map("n", "<C-l>", "<C-w>l", "Window right")
map("n", "<C-j>", "<C-w>j", "Window down")
map("n", "<C-k>", "<C-w>k", "Window up")

-- Terminal mode: double-Escape to return to normal mode
map("t", "<esc><esc>", "<C-\\><C-n>", "Exit terminal mode")

-- Clear search highlight with Escape in normal mode
map("n", "<esc>", "<cmd>nohlsearch<cr>", "Clear search highlight")

-- Keep selection after indent (IntelliJ stays in visual after Tab/Shift+Tab)
map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")

-- Better up/down on wrapped lines (mostly relevant for markdown/text)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", "Down", { expr = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", "Up",   { expr = true })

-- ============================================================
-- macOS: Cmd (⌘) maps mirroring the stock mac IntelliJ keymap,
-- on top of the Ctrl maps above (kept as fallback).
-- Needs a terminal that forwards ⌘ chords via the kitty
-- keyboard protocol — see the "macOS (Ghostty)" README section.
-- ============================================================
if require("config.util").is_mac() then
  map({ "n", "i", "v" }, "<D-s>", "<cmd>w<cr><esc>", "Save (⌘S)")
  map({ "n", "i" }, "<D-z>",   "<cmd>undo<cr>", "Undo (⌘Z)")
  map({ "n", "i" }, "<D-S-z>", "<cmd>redo<cr>", "Redo (⇧⌘Z)")
  map({ "n", "i" }, "<D-a>", "ggVG", "Select all (⌘A)")
  map("v", "<D-c>", '"+y', "Copy to clipboard (⌘C)")
  map({ "n", "i", "v" }, "<D-v>", '"+p', "Paste from clipboard (⌘V)")
  map("n", "<D-d>", "yyp",       "Duplicate line (⌘D)")
  map("i", "<D-d>", "<esc>yypi", "Duplicate line (⌘D)")
  map("v", "<D-d>", "y`>p",      "Duplicate selection (⌘D)")
  map({ "n", "i" }, "<D-BS>", "<cmd>d<cr>", "Delete line (⌘⌫)")
  map("n", "<D-/>", comment_n, "Toggle comment (⌘/)")
  map("i", "<D-/>", comment_i, "Toggle comment (⌘/)")
  map("v", "<D-/>", comment_v, "Toggle comment (⌘/)")
  map({ "n", "i" }, "<D-l>", goto_line, "Go to line (⌘L)")
  map("n", "<D-[>", "<C-o>", "Jump back (⌘[)")
  map("n", "<D-]>", "<C-i>", "Jump forward (⌘])")
  map({ "n", "i" }, "<D-w>", "<cmd>bdelete<cr>", "Close buffer (⌘W)")
end

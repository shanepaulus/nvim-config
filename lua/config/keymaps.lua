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

-- Undo / Redo (IntelliJ keymap "XWin Proper Redo": Redo also on Ctrl+Y)
map({ "n", "i" }, "<C-z>",    "<cmd>undo<cr>", "Undo (Ctrl+Z)")
map({ "n", "i" }, "<A-BS>",   "<cmd>undo<cr>", "Undo (Alt+Backspace)")
map({ "n", "i" }, "<C-S-z>",  "<cmd>redo<cr>", "Redo (Ctrl+Shift+Z)")
map({ "n", "i" }, "<C-y>",    "<cmd>redo<cr>", "Redo (Ctrl+Y)")
map({ "n", "i" }, "<S-A-BS>", "<cmd>redo<cr>", "Redo (Shift+Alt+Backspace)")

-- Select all
map({ "n", "i" }, "<C-a>", "ggVG", "Select all (Ctrl+A)")

-- Clipboard (system clipboard set via opt.clipboard = unnamedplus so y/p already sync;
-- these add IntelliJ Ctrl+C / Ctrl+V muscle memory on top)
map("v", "<C-c>", '"+y', "Copy to clipboard (Ctrl+C)")
map("v", "<C-x>", '"+d', "Cut to clipboard (Ctrl+X)")
map({ "n", "i", "v" }, "<C-v>", '"+p', "Paste from clipboard (Ctrl+V)")
-- Visual block mode: use Ctrl+V in normal mode (we override Ctrl+V to paste only in insert/visual)
-- (no separate visual block binding — enter normal mode first, then Ctrl+V works)

-- Duplicate line (IntelliJ Ctrl+D)
map("n", "<C-d>", "yyp",       "Duplicate line (Ctrl+D)")
map("i", "<C-d>", "<esc>yypi", "Duplicate line (Ctrl+D)")
map("v", "<C-d>", "y`>p",      "Duplicate selection (Ctrl+D)")

-- Move line (IntelliJ Alt+Shift+Up/Down) and move statement (Ctrl+Shift+Up/Down;
-- moves the line too — no statement-aware move in Neovim).
-- Alt+J is IntelliJ's "select next occurrence" (vim-visual-multi, editor.lua).
local move_keys = {
  { "<A-S-Up>",   "<A-S-Down>", "line",      "Alt+Shift" },
  { "<C-S-Up>",   "<C-S-Down>", "statement", "Ctrl+Shift" },
}
for _, k in ipairs(move_keys) do
  local up, down, what, mods = k[1], k[2], k[3], k[4]
  map("n", up,   "<cmd>m .-2<cr>==",        "Move " .. what .. " up (" .. mods .. "+Up)")
  map("i", up,   "<esc><cmd>m .-2<cr>==gi", "Move " .. what .. " up (" .. mods .. "+Up)")
  map("v", up,   ":m '<-2<cr>gv=gv",        "Move " .. what .. " up (" .. mods .. "+Up)")
  map("n", down, "<cmd>m .+1<cr>==",        "Move " .. what .. " down (" .. mods .. "+Down)")
  map("i", down, "<esc><cmd>m .+1<cr>==gi", "Move " .. what .. " down (" .. mods .. "+Down)")
  map("v", down, ":m '>+1<cr>gv=gv",        "Move " .. what .. " down (" .. mods .. "+Down)")
end

-- Join lines (IntelliJ Ctrl+Shift+J)
map({ "n", "v" }, "<C-S-j>", "J",     "Join lines (Ctrl+Shift+J)")
map("i",          "<C-S-j>", "<C-o>J", "Join lines (Ctrl+Shift+J)")

-- Toggle case (IntelliJ Ctrl+Shift+U): word at caret, or the selection
map("n", "<C-S-u>", "g~iw", "Toggle case (Ctrl+Shift+U)")
map("v", "<C-S-u>", "~",    "Toggle case (Ctrl+Shift+U)")

-- Start new line (IntelliJ Shift+Enter) / new line before (Ctrl+Alt+Enter)
map("n", "<S-CR>",   "o",      "Start new line (Shift+Enter)")
map("i", "<S-CR>",   "<C-o>o", "Start new line (Shift+Enter)")
map("n", "<C-A-CR>", "O",      "Start new line before current (Ctrl+Alt+Enter)")
map("i", "<C-A-CR>", "<C-o>O", "Start new line before current (Ctrl+Alt+Enter)")

-- Auto-indent lines (IntelliJ Ctrl+Alt+I)
map("n", "<C-A-i>", "==", "Auto-indent lines (Ctrl+Alt+I)")
map("v", "<C-A-i>", "=",  "Auto-indent lines (Ctrl+Alt+I)")

-- Delete to word start / end (IntelliJ Ctrl+Backspace / Ctrl+Delete).
-- <C-w> on the right is Vim's built-in (noremap), not the Ctrl+W map below.
map("i", "<C-BS>",  "<C-w>",    "Delete to word start (Ctrl+Backspace)")
map("i", "<C-Del>", "<C-o>dw",  "Delete to word end (Ctrl+Delete)")

-- Scroll without moving the caret (IntelliJ Ctrl+Up / Ctrl+Down)
map("n", "<C-Up>",   "<C-y>",      "Scroll up (Ctrl+Up)")
map("i", "<C-Up>",   "<C-o><C-y>", "Scroll up (Ctrl+Up)")
map("n", "<C-Down>", "<C-e>",      "Scroll down (Ctrl+Down)")
map("i", "<C-Down>", "<C-o><C-e>", "Scroll down (Ctrl+Down)")

-- Previous / next method (IntelliJ Alt+Up / Alt+Down): treesitter-textobjects'
-- [m / ]m, so remap = true.
map("n", "<A-Up>",   "[m", "Previous method (Alt+Up)", { remap = true })
map("n", "<A-Down>", "]m", "Next method (Alt+Down)",   { remap = true })

-- Extend / shrink selection (IntelliJ Ctrl+W / Ctrl+Shift+W): treesitter
-- incremental selection, keys set in plugins/treesitter.lua. Insert mode
-- leaves insert first. Vim's own <C-w> window prefix moves to <leader>w.
map("i", "<C-w>", "<esc><C-w>", "Extend selection (Ctrl+W)", { remap = true })
map("n", "<leader>w", "<C-w>", "Window commands (Vim's Ctrl+W)")

-- Last edit location (IntelliJ Ctrl+Shift+Backspace)
map("n", "<C-S-BS>", "g;",      "Last edit location (Ctrl+Shift+Backspace)")
map("i", "<C-S-BS>", "<esc>g;", "Last edit location (Ctrl+Shift+Backspace)")

-- Find / replace in file (IntelliJ Ctrl+F / Ctrl+R, F3 / Shift+F3, Ctrl+L /
-- Ctrl+Shift+L, Ctrl+F3). Project-wide versions live in telescope.lua.
map("n", "<C-f>", "/",      "Find in file (Ctrl+F)", { silent = false })
map("i", "<C-f>", "<esc>/", "Find in file (Ctrl+F)", { silent = false })
local replace_in_file = function()
  vim.cmd("stopinsert")
  local word = vim.fn.escape(vim.fn.expand("<cword>"), [[\/]])
  vim.api.nvim_feedkeys(":%s/\\V" .. word .. "//gc" .. vim.keycode("<Left><Left><Left>"), "n", false)
end
map({ "n", "i" }, "<C-r>", replace_in_file, "Replace in file (Ctrl+R)")
-- Replace in files (IntelliJ Ctrl+Shift+R): ripgrep for the text, then
-- :cfdo a confirmed (c) substitution in every hit, like IntelliJ's preview.
local replace_in_files = function()
  vim.cmd("stopinsert")
  local find = vim.fn.input("Replace in files: ", vim.fn.expand("<cword>"))
  if find == "" then return end
  local with = vim.fn.input("Replace '" .. find .. "' with: ")
  local hits = vim.fn.systemlist({ "rg", "--vimgrep", "--fixed-strings", "--", find })
  if #hits == 0 then
    vim.notify("Replace in files: no matches for '" .. find .. "'")
    return
  end
  vim.fn.setqflist({}, " ", { title = "Replace in files", lines = hits, efm = "%f:%l:%c:%m" })
  local esc = function(str) return vim.fn.escape(str, [[\/]]) end
  vim.cmd("cfdo %s/\\V" .. esc(find) .. "/" .. esc(with) .. "/gce | update")
end
map({ "n", "i" }, "<C-S-r>", replace_in_files, "Replace in files (Ctrl+Shift+R)")
map("n", "<F3>",    "n", "Find next (F3)")
map("n", "<C-l>",   "n", "Find next (Ctrl+L)")
map("n", "<S-F3>",  "N", "Find previous (Shift+F3)")
map("n", "<C-S-l>", "N", "Find previous (Ctrl+Shift+L)")
map("n", "<C-F3>",  "*", "Find word at caret (Ctrl+F3)")

-- Close tab (IntelliJ Ctrl+Shift+F4; Ctrl+F4 is in plugins/ui.lua)
map({ "n", "i" }, "<C-S-F4>", "<cmd>bdelete<cr>", "Close active tab (Ctrl+Shift+F4)")

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

-- Shortcut finder: search every shortcut by name and run it, like IntelliJ's
-- Find Action (Ctrl+Shift+A; F1 kept as a fallback) — see config/shortcuts.lua
local shortcuts = function() require("config.shortcuts").open() end
map({ "n", "i" }, "<C-S-a>",    shortcuts, "Find action (Ctrl+Shift+A)")
map({ "n", "i" }, "<F1>",       shortcuts, "Find shortcut / action (F1)")
map("n",          "<leader>fk", shortcuts, "Find shortcut / action")

-- Bookmarks (IntelliJ F11 / Shift+F11) — see config/bookmarks.lua
local bookmarks = require("config.bookmarks")
map({ "n", "i" }, "<F11>",   bookmarks.toggle, "Toggle bookmark (F11)")
map({ "n", "i" }, "<S-F11>", bookmarks.list,   "Show bookmarks (Shift+F11)")
for n = 1, 9 do
  map({ "n", "i" }, "<C-" .. n .. ">", function() bookmarks.jump(n) end, "Go to bookmark " .. n .. " (Ctrl+" .. n .. ")")
  map({ "n", "i" }, "<C-S-" .. n .. ">", function() bookmarks.set(n) end, "Toggle bookmark " .. n .. " (Ctrl+Shift+" .. n .. ")")
end

-- Local History (IntelliJ VCS › Local History): Neovim 0.12's built-in undo tree.
-- undofile is on, so history survives restarts.
local local_history = function()
  if not pcall(vim.cmd.packadd, "nvim.undotree") then
    vim.notify("Local History needs Neovim 0.12+ (nvim.undotree)", vim.log.levels.WARN)
    return
  end
  require("undotree").open()
end
map("n", "<leader>uu", local_history, "Local history (undo tree)")

-- Jump back / forward (IntelliJ Ctrl+Alt+Left / Ctrl+Alt+Right).
-- Alt+Left/Right belong to bufferline (move between open tabs), plugins/ui.lua.
map("n", "<C-A-Left>",  "<C-o>", "Jump back (Ctrl+Alt+Left)")
map("n", "<C-A-Right>", "<C-i>", "Jump forward (Ctrl+Alt+Right)")

-- Buffer navigation (IntelliJ Ctrl+Tab / Ctrl+Shift+Tab / Ctrl+F4 / Ctrl+Q):
-- owned by bufferline's `keys` spec in plugins/ui.lua, not duplicated here.
-- Both files used to register the same lhs with a separate vim.keymap.set
-- call — whichever loaded last silently won, and which-key's health check
-- (`:checkhealth which-key`) had two conflicting entries to report on.

-- Window navigation: Ctrl+H/J/K/L belong to IntelliJ (type hierarchy, live
-- template, commit, find next), so windows use <leader>w + h/j/k/l.

-- Terminal mode: double-Escape to return to normal mode
map("t", "<esc><esc>", "<C-\\><C-n>", "Exit terminal mode")

-- Clear search highlight with Escape in normal mode
map("n", "<esc>", "<cmd>nohlsearch<cr>", "Clear search highlight")

-- Keep selection after indent (IntelliJ stays in visual after Tab/Shift+Tab)
map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")
map("x", "<Tab>", ">gv", "Indent right")
map("x", "<S-Tab>", "<gv", "Indent left")

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
  map({ "n", "i" }, "<F3>",    bookmarks.toggle, "Toggle bookmark (F3)")
  map({ "n", "i" }, "<D-F3>",  bookmarks.list,   "Show bookmarks (⌘F3)")
end

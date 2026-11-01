-- Smoke test for the IntelliJ-gap features: bookmarks, folding, call hierarchy,
-- local history (undotree) and breadcrumbs (dropbar).
--
--   nvim --headless -i NONE -c "luafile tests/features.lua"
--
-- `-i NONE` keeps the test's global marks out of your real shada.
-- Exits non-zero if any check fails.

local failed = 0
local function out(s) io.stdout:write(s .. "\n") end
local function check(name, fn)
  local ok, err = pcall(fn)
  if ok then
    out("PASS  " .. name)
  else
    failed = failed + 1
    out("FAIL  " .. name .. ": " .. tostring(err))
  end
end
local function eq(a, b, what)
  if a ~= b then error(string.format("%s: expected %s, got %s", what, vim.inspect(b), vim.inspect(a)), 0) end
end

local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
local file = dir .. "/sample.lua"
vim.fn.writefile({
  "local M = {}",
  "function M.a()",
  "  return 1",
  "end",
  "return M",
}, file)

local function global_marks_in(buf)
  local marks = {}
  for _, m in ipairs(vim.fn.getmarklist()) do
    if m.mark:match("^'[A-Z]$") and m.pos[1] == buf then
      marks[#marks + 1] = m
    end
  end
  return marks
end

local function sign_count(buf)
  local ns = vim.api.nvim_get_namespaces()["bookmarks"]
  if not ns then return 0 end
  return #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
end

local function run()
  vim.cmd.edit(file)
  local buf = vim.api.nvim_get_current_buf()

  check("bookmarks: toggle on sets mark + sign", function()
    local bm = require("config.bookmarks")
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    bm.toggle()
    local marks = global_marks_in(buf)
    eq(#marks, 1, "marks")
    eq(marks[1].pos[2], 2, "mark line")
    eq(sign_count(buf), 1, "signs")
    local ns = vim.api.nvim_get_namespaces()["bookmarks"]
    local sign = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })[1][4].sign_text
    eq(vim.trim(sign), "1", "first bookmark shows as 1 in the gutter")
  end)

  check("bookmarks: toggle off removes mark + sign", function()
    local bm = require("config.bookmarks")
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    bm.toggle()
    eq(#global_marks_in(buf), 0, "marks")
    eq(sign_count(buf), 0, "signs")
  end)

  check("bookmarks: list fills quickfix", function()
    local bm = require("config.bookmarks")
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    bm.toggle()
    vim.api.nvim_win_set_cursor(0, { 4, 0 })
    bm.toggle()
    bm.list()
    local qf = vim.fn.getqflist({ title = 1, items = 1 })
    eq(qf.title, "Bookmarks", "qf title")
    eq(#qf.items, 2, "qf items")
    -- close the telescope popup the list opened
    vim.cmd("stopinsert")
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_config(w).relative ~= "" then
        pcall(vim.api.nvim_win_close, w, true)
      end
    end
  end)

  vim.cmd.edit(file)

  check("bookmarks: Ctrl+2 jumps to 2nd bookmark, unset number is a no-op", function()
    if vim.fn.maparg("<C-1>", "n") == "" then error("missing <C-1>", 0) end
    local bm = require("config.bookmarks")
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    bm.jump(2)
    eq(vim.api.nvim_win_get_cursor(0)[1], 4, "line after jump(2)")
    bm.jump(9)
    eq(vim.api.nvim_win_get_cursor(0)[1], 4, "line after jump(9) with no 9th bookmark")
  end)

  check("bookmarks: Ctrl+Shift+3 sets, moves and removes bookmark 3", function()
    if vim.fn.maparg("<C-S-3>", "n") == "" then error("missing <C-S-3>", 0) end
    local bm = require("config.bookmarks")
    local function mark_c() return vim.api.nvim_get_mark("C", {})[1] end
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    bm.set(3)
    eq(mark_c(), 1, "bookmark 3 set on line 1")
    vim.api.nvim_win_set_cursor(0, { 5, 0 })
    bm.set(3)
    eq(mark_c(), 5, "bookmark 3 moved to line 5")
    eq(sign_count(buf), 3, "signs for bookmarks 1, 2, 3")
    bm.set(3)
    eq(mark_c(), 0, "bookmark 3 removed")
    eq(sign_count(buf), 2, "signs after removing 3")
  end)

  check("bookmarks: keys also work in insert mode", function()
    for _, lhs in ipairs({ "<F11>", "<S-F11>", "<C-1>", "<C-S-1>" }) do
      if vim.fn.maparg(lhs, "i") == "" then error("missing insert-mode " .. lhs, 0) end
    end
  end)

  check("bookmarks: :BookmarksClear removes all marks and signs", function()
    local bm = require("config.bookmarks")
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    bm.set(3)
    vim.cmd("BookmarksClear")
    eq(#global_marks_in(buf), 0, "marks")
    eq(sign_count(buf), 0, "signs")
  end)

  check("folding: treesitter foldexpr, opens unfolded", function()
    eq(vim.wo.foldmethod, "expr", "foldmethod")
    eq(vim.wo.foldexpr, "v:lua.vim.treesitter.foldexpr()", "foldexpr")
    eq(vim.wo.foldlevel, 99, "foldlevel")
  end)

  check("keymaps exist", function()
    for _, lhs in ipairs({ "<C-A-->", "<C-A-=>", "<C-A-S-->", "<C-A-S-=>", "<F11>", "<S-F11>", "<leader>uu", "<A-Home>" }) do
      if vim.fn.maparg(lhs, "n") == "" then error("missing " .. lhs, 0) end
    end
  end)

  check("call hierarchy: LspAttach maps Ctrl+Alt+H / Ctrl+Alt+Shift+H", function()
    vim.api.nvim_exec_autocmds("LspAttach", { group = "shared_lsp_keymaps", buffer = buf, data = { client_id = 0 } })
    for _, lhs in ipairs({ "<C-A-h>", "<C-A-S-h>" }) do
      local m = vim.fn.maparg(lhs, "n", false, true)
      if m.buffer ~= 1 then error("missing buffer-local " .. lhs, 0) end
    end
  end)

  check("local history: Space u u toggles undotree", function()
    local function undotree_open()
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "nvim-undotree" then return true end
      end
      return false
    end
    local toggle = vim.fn.maparg("<leader>uu", "n", false, true).callback
    toggle()
    eq(undotree_open(), true, "open after first toggle")
    vim.wait(100) -- let undotree's scheduled render run before closing it
    vim.cmd.wincmd("p")
    toggle()
    eq(undotree_open(), false, "open after second toggle")
  end)

  check("Shift+Tab unindents in insert and visual mode", function()
    require("lazy").load({ plugins = { "nvim-cmp" } }) -- normally loads on InsertEnter
    local prev = vim.api.nvim_get_current_buf()
    local b = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(b)
    vim.bo[b].expandtab, vim.bo[b].shiftwidth = true, 2
    -- cmp installs its insert-mode maps via a callback queued behind pending
    -- keys (i.e. after our <Esc>), so install them up front.
    require("cmp").core:prepare()
    -- flush the pending startinsert left by the telescope popup in "bookmarks: list"
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    local function after(keys)
      vim.api.nvim_buf_set_lines(b, 0, -1, false, { "    foo", "    bar" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      vim.api.nvim_feedkeys(vim.keycode(keys), "mx", false)
      local l = vim.api.nvim_buf_get_lines(b, 0, -1, false)
      return l[1] .. "|" .. l[2]
    end
    local results = {
      insert = after("A<S-Tab><Esc>"),
      visual_unindent = after("Vj<S-Tab><Esc>"),
      visual_indent = after("Vj<Tab><Esc>"),
    }
    vim.api.nvim_set_current_buf(prev)
    vim.api.nvim_buf_delete(b, { force = true })
    eq(results.insert, "  foo|    bar", "insert Shift+Tab")
    eq(results.visual_unindent, "  foo|  bar", "visual Shift+Tab")
    eq(results.visual_indent, "      foo|      bar", "visual Tab")
  end)

  -- dropbar attaches on its own autocmds; give it a moment
  vim.defer_fn(function()
    check("breadcrumbs: dropbar sets winbar", function()
      if vim.wo.winbar == "" then error("winbar is empty", 0) end
    end)
    out(failed == 0 and "ALL PASS" or (failed .. " FAILED"))
    vim.fn.delete(dir, "rf")
    vim.cmd(failed == 0 and "qa!" or "cq")
  end, 1000)
end

-- let lazy.nvim finish its VeryLazy loads first
vim.defer_fn(run, 500)

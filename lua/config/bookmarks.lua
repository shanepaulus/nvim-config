-- IntelliJ-style bookmarks (F11 toggle / Shift+F11 list) on top of native
-- uppercase marks: A-Z are global (cross-file) and persist in shada, which is
-- exactly IntelliJ's bookmark behaviour. A-I show as 1-9 in the gutter so the
-- number on screen is the Ctrl+<digit> that jumps there; J-Z show their letter.
local M = {}

local ns = vim.api.nvim_create_namespace("bookmarks")
local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function label(letter)
  local index = letters:find(letter, 1, true)
  return index <= 9 and tostring(index) or letter
end

-- Global marks set in this buffer: { { letter = "A", line = 12 }, ... }
local function marks_in(buf)
  local found = {}
  for _, m in ipairs(vim.fn.getmarklist()) do
    local letter = m.mark:match("^'([A-Z])$")
    if letter and m.pos[1] == buf then
      found[#found + 1] = { letter = letter, line = m.pos[2] }
    end
  end
  return found
end

function M.refresh(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local line_count = vim.api.nvim_buf_line_count(buf)
  for _, m in ipairs(marks_in(buf)) do
    if m.line <= line_count then
      vim.api.nvim_buf_set_extmark(buf, ns, m.line - 1, 0, { sign_text = label(m.letter), sign_hl_group = "Bookmark" })
    end
  end
end

function M.toggle()
  local buf = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local removed = false
  for _, m in ipairs(marks_in(buf)) do
    if m.line == line then
      vim.api.nvim_del_mark(m.letter)
      removed = true
    end
  end
  if not removed then
    local used = {}
    for _, m in ipairs(vim.fn.getmarklist()) do
      local letter = m.mark:match("^'([A-Z])$")
      if letter then used[letter] = true end
    end
    local free
    for letter in letters:gmatch(".") do
      if not used[letter] then free = letter break end
    end
    if not free then
      vim.notify("All 26 bookmarks (A-Z) are in use", vim.log.levels.WARN)
      return
    end
    vim.api.nvim_buf_set_mark(buf, free, line, 0, {})
  end
  M.refresh(buf)
end

function M.list()
  local items = {}
  for _, m in ipairs(vim.fn.getmarklist()) do
    local letter = m.mark:match("^'([A-Z])$")
    if letter then
      items[#items + 1] = { filename = vim.fn.expand(m.file), lnum = m.pos[2], col = m.pos[3], text = "Bookmark " .. label(letter) }
    end
  end
  vim.fn.setqflist({}, " ", { title = "Bookmarks", items = items })
  require("telescope.builtin").quickfix({ prompt_title = "Bookmarks" })
end

-- Toggle bookmark n (1-9) on the cursor line, like IntelliJ's Ctrl+Shift+<digit>:
-- moves it here if it is elsewhere, removes it if it is already on this line.
function M.set(n)
  local letter = letters:sub(n, n)
  local buf = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local old = vim.api.nvim_get_mark(letter, {})
  if old[1] == line and old[3] == buf then
    vim.api.nvim_del_mark(letter)
  else
    for _, m in ipairs(marks_in(buf)) do -- one bookmark per line
      if m.line == line then vim.api.nvim_del_mark(m.letter) end
    end
    vim.api.nvim_buf_set_mark(buf, letter, line, 0, {})
  end
  if old[3] ~= buf and vim.api.nvim_buf_is_loaded(old[3]) then M.refresh(old[3]) end
  M.refresh(buf)
end

-- Jump to bookmark n (1-9), like IntelliJ's Ctrl+<digit>
function M.jump(n)
  local letter = letters:sub(n, n)
  if vim.api.nvim_get_mark(letter, {})[1] == 0 then
    vim.notify("No bookmark " .. n, vim.log.levels.INFO)
    return
  end
  vim.cmd("normal! '" .. letter)
end

function M.clear()
  for letter in letters:gmatch(".") do
    vim.api.nvim_del_mark(letter)
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then M.refresh(buf) end
  end
end

function M.setup()
  vim.api.nvim_create_user_command("BookmarksClear", M.clear, { desc = "Remove all bookmarks" })
  vim.api.nvim_set_hl(0, "Bookmark", { link = "DiagnosticInfo", default = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("bookmarks", { clear = true }),
    callback = function(event) M.refresh(event.buf) end,
  })
end

return M

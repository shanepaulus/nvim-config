-- vim.ui.select (code actions, Alt+Enter) must open a Telescope picker, not
-- the builtin inputlist() that noice renders as an unusable "Confirm" popup.
--
--   nvim --headless -i NONE -c "luafile tests/ui_select.lua"
--
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

local function run()
  check("vim.ui.select opens a Telescope picker and returns the choice", function()
    local choice
    vim.ui.select({ "first", "second" }, { prompt = "Code actions" }, function(item) choice = item end)

    local opened = vim.wait(3000, function() return vim.bo.filetype == "TelescopePrompt" end)
    if not opened then error("no Telescope picker, current filetype: '" .. vim.bo.filetype .. "'", 0) end

    -- Drive the picker through Telescope's own actions (typeahead is not
    -- processed inside vim.wait, so feedkeys can't be used here).
    local prompt_bufnr = vim.api.nvim_get_current_buf()
    local actions = require("telescope.actions")
    local state = require("telescope.actions.state")
    vim.wait(3000, function() return state.get_selected_entry() ~= nil end)
    actions.move_selection_next(prompt_bufnr)
    actions.select_default(prompt_bufnr)
    vim.wait(3000, function() return choice ~= nil end)
    if choice ~= "second" then error("expected 'second', got " .. vim.inspect(choice), 0) end
  end)

  out(failed == 0 and "ALL PASS" or (failed .. " FAILED"))
  vim.cmd(failed == 0 and "qa!" or "cq")
end

-- let lazy.nvim finish its VeryLazy loads first (noice included)
vim.defer_fn(run, 500)

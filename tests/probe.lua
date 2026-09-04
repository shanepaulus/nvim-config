-- Generic auto-import probe.
-- env: PROBE_LOG PROBE_LINE PROBE_TYPE PROBE_PICK PROBE_EXPECT PROBE_WAIT
local LOG    = os.getenv("PROBE_LOG")
local LINE   = tonumber(os.getenv("PROBE_LINE"))
local TYPE   = os.getenv("PROBE_TYPE")
local PICK   = os.getenv("PROBE_PICK")
local EXPECT = os.getenv("PROBE_EXPECT")
local WAIT   = tonumber(os.getenv("PROBE_WAIT") or "20000")

local f = io.open(LOG, "w")
local function out(...) f:write(table.concat({ ... }, " ") .. "\n") f:flush() end
local function done(code) f:close() vim.cmd(code and "cq" or "qa!") end
local cmp
local function keys(s)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s, true, false, true), "t", false)
end

local function wait_clients(n)
  local cs = vim.lsp.get_clients({ bufnr = 0 })
  if #cs > 0 then
    local names = {}
    for _, c in ipairs(cs) do names[#names + 1] = c.name end
    out("CLIENTS :", table.concat(names, ", "))
    cmp = require("cmp")
    vim.defer_fn(step_type, WAIT)
  elseif n > 0 then
    vim.defer_fn(function() wait_clients(n - 1) end, 1000)
  else
    out("RESULT  : FAIL (no LSP client attached)") done()
  end
end

function step_type()
  -- Enter insert mode and let it settle FIRST: if the whole string lands in the
  -- same event tick as InsertEnter, cmp sees the context as unchanged on the
  -- following TextChangedI and never fires a completion request.
  keys("<Esc>" .. LINE .. "GA")
  vim.defer_fn(function()
    keys(TYPE)
    vim.defer_fn(step_pick, 7000)
  end, 2000)
end

function step_pick()
  local entries = cmp.get_entries() or {}
  out("popup   :", tostring(cmp.visible()), "entries:", #entries)
  if #entries == 0 then
    out("RESULT  : FAIL (no completion entries for '" .. TYPE .. "')") return done()
  end
  local labels = {}
  for i = 1, math.min(#entries, 6) do labels[i] = entries[i]:get_completion_item().label end
  out("labels  :", table.concat(labels, ", "))

  -- select the entry whose label matches PICK
  local target
  for i, e in ipairs(entries) do
    if e:get_completion_item().label:find(PICK, 1, true) then target = i break end
  end
  if not target then
    out("RESULT  : FAIL ('" .. PICK .. "' not offered)") return done()
  end
  out("picking : #" .. target .. " " .. entries[target]:get_completion_item().label)
  -- Confirm the specific entry directly. select_next_item() is scheduled async,
  -- so looping it and confirming in the same tick confirms nothing.
  cmp.core:confirm(entries[target], { behavior = cmp.ConfirmBehavior.Insert }, function()
    vim.defer_fn(step_verify, 4000)
  end)
end

function step_verify()
  local body = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local ok = body:find(EXPECT, 1, true) ~= nil
  out("buffer  :")
  for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do out("  | " .. l) end
  out("expect  : " .. EXPECT)
  out("RESULT  : " .. (ok and "PASS (auto-import applied)" or "FAIL (import not inserted)"))
  done()
end

vim.defer_fn(function() wait_clients(120) end, 1500)

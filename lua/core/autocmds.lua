-- lua/core/autocmds.lua
-- 自动保存（防抖）+ 可开关（per-buffer timer）

local api = vim.api
local uv = vim.uv or vim.loop

vim.g.autosave_enabled = true

local exclude_filetypes = {
  "gitcommit",
  "gitrebase",
  "TelescopePrompt",
  "NvimTree",
}

local function contains(t, v)
  for _, x in ipairs(t) do
    if x == v then return true end
  end
  return false
end

local function should_save(buf)
  if not api.nvim_buf_is_valid(buf) then return false end
  if vim.bo[buf].buftype ~= "" then return false end
  if not vim.bo[buf].modifiable then return false end
  if vim.bo[buf].readonly then return false end
  if contains(exclude_filetypes, vim.bo[buf].filetype) then return false end
  if api.nvim_buf_get_name(buf) == "" then return false end
  if not vim.bo[buf].modified then return false end
  return true
end

local saving = false
local function save(buf)
  if saving then return end
  if not vim.g.autosave_enabled then return end
  if not should_save(buf) then return end

  saving = true
  api.nvim_buf_call(buf, function()
    local ok, err = pcall(vim.cmd, "silent update")
    if not ok then
      vim.notify(("AutoSave failed: %s"):format(err), vim.log.levels.WARN)
    end
  end)
  saving = false
end

local group = api.nvim_create_augroup("JasonAutoSave", { clear = true })

-- per-buffer 防抖 timer
local delay_ms = 800
local timers = {}

local function schedule_save(buf)
  if timers[buf] == nil then
    timers[buf] = uv.new_timer()
  end
  local t = timers[buf]
  t:stop()
  t:start(delay_ms, 0, function()
    vim.schedule(function() save(buf) end)
  end)
end

api.nvim_create_autocmd("TextChangedI", {
  group = group,
  callback = function(ev)
    schedule_save(ev.buf)
  end,
})

api.nvim_create_autocmd({ "InsertLeave", "BufLeave", "FocusLost" }, {
  group = group,
  callback = function(ev)
    save(ev.buf)
  end,
})

api.nvim_create_autocmd("BufWipeout", {
  group = group,
  callback = function(ev)
    local t = timers[ev.buf]
    if t then
      t:stop()
      t:close()
      timers[ev.buf] = nil
    end
  end,
})

api.nvim_create_user_command("AutoSaveToggle", function()
  vim.g.autosave_enabled = not vim.g.autosave_enabled
  vim.notify("AutoSave: " .. (vim.g.autosave_enabled and "ON" or "OFF"))
end, {})


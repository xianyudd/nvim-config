-- Copy last terminal command + its output (between OSC 133 prompts) to Windows clipboard.
-- Relies on shell OSC 133 A marks + nvim built-in nvim.terminal.prompt extmarks.
-- Does not wrap/re-run/modify the original shell command.

local M = {}

local CLIP_PIPE = "iconv -f utf-8 -t utf-16le | /mnt/c/Windows/System32/clip.exe"
local PROMPT_NS = "nvim.terminal.prompt"

local function prompt_ns_id()
  local nss = vim.api.nvim_get_namespaces()
  return nss[PROMPT_NS]
end

local function resolve_term_buf(bufnr)
  bufnr = bufnr or 0
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  if vim.bo[bufnr].buftype == "terminal" then
    return bufnr
  end
  -- Prefer current tabpage terminal windows (toggleterm / :terminal)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(win)
    if vim.bo[b].buftype == "terminal" then
      return b
    end
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == "terminal" then
      return b
    end
  end
  return nil
end

--- Return 0-based start rows of OSC 133 prompt marks, ascending.
local function prompt_rows(bufnr)
  local ns = prompt_ns_id()
  if not ns then
    return {}
  end
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
  local rows = {}
  for _, m in ipairs(marks) do
    rows[#rows + 1] = m[2]
  end
  table.sort(rows)
  return rows
end

--- Extract text of last completed command block: [prev_prompt, current_prompt)
--- or, if only one prompt and content after it, that open block (still running / no next prompt yet).
local function extract_last_block(bufnr)
  local rows = prompt_rows(bufnr)
  if #rows == 0 then
    return nil, "no_prompt_marks"
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local start_row ---@type integer
  local end_row ---@type integer exclusive 0-based / line_count for end

  if #rows >= 2 then
    -- Last completed: between second-to-last and last prompt
    start_row = rows[#rows - 1]
    end_row = rows[#rows]
  else
    -- Single prompt: take from that prompt to buffer end (exclude trailing empty)
    start_row = rows[1]
    end_row = line_count
  end

  if end_row <= start_row then
    return nil, "empty_block"
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row, false)
  -- Drop pure trailing empties from the next-prompt boundary
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end
  if #lines == 0 then
    return nil, "empty_block"
  end
  return table.concat(lines, "\n"), nil
end

local function copy_text(text)
  local tmp = vim.fn.tempname()
  local f, err = io.open(tmp, "wb")
  if not f then
    return false, "open_tmp: " .. tostring(err)
  end
  f:write(text)
  if not text:match("\n$") then
    f:write("\n")
  end
  f:close()

  local cmd = string.format("cat %s | %s", vim.fn.shellescape(tmp), CLIP_PIPE)
  local ok = os.execute(cmd)
  pcall(os.remove, tmp)
  -- os.execute returns true on Lua 5.1+ / LuaJIT success, or 0 on some
  if ok == true or ok == 0 then
    return true
  end
  return false, "clip_failed: " .. tostring(ok)
end

function M.copy_last(bufnr)
  local term = resolve_term_buf(bufnr)
  if not term then
    vim.notify("✘ 未找到终端 buffer", vim.log.levels.WARN)
    return false
  end

  local text, why = extract_last_block(term)
  if not text then
    local msg = {
      no_prompt_marks = "✘ 无 OSC 133 提示符标记：请确认终端 shell 已加载 nvim OSC 133 配置",
      empty_block = "✘ 上一条命令块为空",
    }
    vim.notify(msg[why] or ("✘ 复制失败：" .. tostring(why)), vim.log.levels.WARN)
    return false
  end

  local ok, err = copy_text(text)
  if not ok then
    vim.notify("✘ 复制到 Windows 剪贴板失败：" .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  local nlines = select(2, text:gsub("\n", "\n")) + 1
  vim.notify(string.format("✔ 已复制上一条终端命令+输出（%d 行）", nlines), vim.log.levels.INFO)
  return true
end

function M.setup()
  local map = vim.keymap.set
  local desc = "复制上一条终端命令+输出到 Windows 剪贴板"
  map("n", "<leader>yy", function()
    M.copy_last()
  end, { noremap = true, silent = true, desc = desc })
  -- Terminal-mode: leave insert-like term mode first so marks/cursor are stable
  map("t", "<leader>yy", function()
    -- Go to terminal-normal then copy (toggleterm / :terminal)
    local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
    vim.schedule(function()
      M.copy_last()
    end)
  end, { noremap = true, silent = true, desc = desc })
end

return M

-- Copy last completed terminal command block (OSC 133 prompt → next prompt) to Windows clipboard.
-- Includes the prompt line that holds the command; does not wrap/re-run the shell command.

local M = {}

local CLIP_PIPE = "iconv -f utf-8 -t utf-16le | /mnt/c/Windows/System32/clip.exe"
local PROMPT_NS = "nvim.terminal.prompt"

---@type integer|nil last focused terminal buffer
local last_term_buf = nil

local function prompt_ns_id()
  local nss = vim.api.nvim_get_namespaces()
  return nss[PROMPT_NS]
end

local function is_term_buf(bufnr)
  return bufnr
    and vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_buf_is_loaded(bufnr)
    and vim.bo[bufnr].buftype == "terminal"
end

local function resolve_term_buf(bufnr)
  if bufnr and bufnr ~= 0 and is_term_buf(bufnr) then
    return bufnr
  end
  local cur = vim.api.nvim_get_current_buf()
  if is_term_buf(cur) then
    return cur
  end
  if is_term_buf(last_term_buf) then
    return last_term_buf
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(win)
    if is_term_buf(b) then
      return b
    end
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if is_term_buf(b) then
      return b
    end
  end
  return nil
end

--- Unique ascending 0-based prompt rows (dedupe same-line / double-fire marks).
local function prompt_rows(bufnr)
  local ns = prompt_ns_id()
  if not ns then
    return {}
  end
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
  local seen = {}
  local rows = {}
  for _, m in ipairs(marks) do
    local r = m[2]
    if not seen[r] then
      seen[r] = true
      rows[#rows + 1] = r
    end
  end
  table.sort(rows)
  return rows
end

--- Last completed block only: [second_last_prompt, last_prompt). No open/running block.
local function extract_last_block(bufnr)
  local rows = prompt_rows(bufnr)
  if #rows == 0 then
    return nil, "no_prompt_marks"
  end
  if #rows < 2 then
    return nil, "incomplete"
  end

  local start_row = rows[#rows - 1]
  local end_row = rows[#rows]
  if end_row <= start_row then
    return nil, "empty_block"
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row, false)
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
      no_prompt_marks = "✘ 无 OSC 133 提示符标记：请确认 shell 已加载 nvim OSC 133（且 $NVIM 已设置）",
      incomplete = "✘ 上一条命令尚未完成（需出现下一条提示符后再复制）",
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
  vim.notify(string.format("✔ 已复制上一条完整终端块（%d 行，含提示符行）", nlines), vim.log.levels.INFO)
  return true
end

function M.setup()
  local aug = vim.api.nvim_create_augroup("TermYankLastActive", { clear = true })
  vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "BufEnter" }, {
    group = aug,
    callback = function(args)
      if is_term_buf(args.buf) then
        last_term_buf = args.buf
      end
    end,
  })

  local map = vim.keymap.set
  -- <leader>Y：避免占用 <leader>y 前缀导致全文复制等 timeoutlen 延迟
  local desc = "复制上一条完整终端块(含提示符)到 Windows 剪贴板"
  map("n", "<leader>Y", function()
    M.copy_last()
  end, { noremap = true, silent = true, desc = desc })
  map("t", "<leader>Y", function()
    local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
    vim.schedule(function()
      M.copy_last()
    end)
  end, { noremap = true, silent = true, desc = desc })
end

-- test helpers (not used at runtime)
M._prompt_rows = prompt_rows
M._extract_last_block = extract_last_block
M._resolve_term_buf = resolve_term_buf
M._set_last_term = function(b)
  last_term_buf = b
end

return M

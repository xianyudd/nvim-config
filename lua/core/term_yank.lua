-- Copy the last completed terminal command block to the Windows clipboard.
-- A block is the text between two OSC 133 prompt-start (A) marks and includes
-- the prompt line containing the command. The shell command is never modified.

local M = {}

local CLIP_EXE = "/mnt/c/Windows/System32/clip.exe"
local PROMPT_NS = "nvim.terminal.prompt"
local FISH_CONF = "nvim-osc133.fish"
local FISH_CONF_MARKER = "# nvim-term-yank managed loader"

---@type integer|nil
local last_term_buf = nil

local function prompt_ns_id()
  return vim.api.nvim_get_namespaces()[PROMPT_NS]
end

local function is_term_buf(bufnr)
  return type(bufnr) == "number"
    and vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_buf_is_loaded(bufnr)
    and vim.bo[bufnr].buftype == "terminal"
end

local function resolve_term_buf(bufnr)
  if is_term_buf(bufnr) then
    return bufnr
  end

  local current = vim.api.nvim_get_current_buf()
  if is_term_buf(current) then
    return current
  end

  if is_term_buf(last_term_buf) then
    return last_term_buf
  end

  return nil
end

---Unique ascending 0-based prompt rows.
local function prompt_rows(bufnr)
  local ns = prompt_ns_id()
  if not ns then
    return {}
  end

  local seen = {}
  local rows = {}
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})) do
    local row = mark[2]
    if not seen[row] then
      seen[row] = true
      rows[#rows + 1] = row
    end
  end
  table.sort(rows)
  return rows
end

---Return the text between the latest two prompt-start marks.
local function extract_last_block(bufnr)
  local rows = prompt_rows(bufnr)
  if #rows == 0 then
    return nil, "no_prompt_marks"
  end
  if #rows < 2 then
    return nil, "no_completed_block"
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
  local file, err = io.open(tmp, "wb")
  if not file then
    return false, "open_tmp: " .. tostring(err)
  end

  file:write(text)
  if not text:match("\n$") then
    file:write("\n")
  end
  file:close()

  local cmd = string.format("iconv -f utf-8 -t utf-16le %s | %s", vim.fn.shellescape(tmp), CLIP_EXE)
  local out = vim.fn.system(cmd)
  local shell_error = vim.v.shell_error
  pcall(os.remove, tmp)
  if shell_error == 0 then
    return true
  end
  return false, string.format("clip_failed:%d %s", shell_error, out:gsub("%s+$", ""))
end

local function fish_conf_dir()
  local root = vim.env.XDG_CONFIG_HOME
  if not root or root == "" then
    root = vim.fn.expand("~/.config")
  end
  return root .. "/fish/conf.d"
end

local function ensure_fish_loader()
  if vim.fn.executable("fish") ~= 1 then
    return true
  end

  local source = vim.fn.expand("~/.config/nvim/shell/" .. FISH_CONF)
  if vim.fn.filereadable(source) ~= 1 then
    return false, "missing_source"
  end

  local dir = fish_conf_dir()
  local target = dir .. "/" .. FISH_CONF
  if vim.fn.filereadable(target) == 1 then
    local target_lines = vim.fn.readfile(target)
    local first = target_lines[1]
    local current = table.concat(target_lines, "\n") .. "\n"
    local wanted = table.concat(vim.fn.readfile(source), "\n") .. "\n"
    if first == FISH_CONF_MARKER then
      if current == wanted then
        return true
      end
    elseif not (current:find("NVIM", 1, true) and current:find("osc133.fish", 1, true)) then
      return false, "target_exists"
    end
  end

  if vim.fn.mkdir(dir, "p") == 0 and vim.fn.isdirectory(dir) == 0 then
    return false, "mkdir_failed"
  end
  local ok, err = pcall(vim.fn.writefile, vim.fn.readfile(source), target)
  if not ok then
    return false, tostring(err)
  end
  return true
end

function M.copy_last(bufnr)
  local term = resolve_term_buf(bufnr)
  if not term then
    vim.notify("✘ 未找到当前或最近活动的终端", vim.log.levels.WARN)
    return false
  end

  local text, why = extract_last_block(term)
  if not text then
    local messages = {
      no_prompt_marks = "✘ 终端没有 OSC 133 提示符标记，请检查 Fish/Bash 加载入口和 $NVIM",
      no_completed_block = "✘ 尚无已完成的终端命令块，请等待下一个提示符出现",
      empty_block = "✘ 上一个终端命令块为空",
    }
    vim.notify(messages[why] or ("✘ 复制失败：" .. tostring(why)), vim.log.levels.WARN)
    return false
  end

  local ok, err = copy_text(text)
  if not ok then
    vim.notify("✘ 复制到 Windows 剪贴板失败：" .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  local line_count = select(2, text:gsub("\n", "\n")) + 1
  vim.notify(string.format("✔ 已复制最后一个已完成终端命令块（%d 行，含提示符行）", line_count), vim.log.levels.INFO)
  return true
end

function M.setup()
  local fish_ok, fish_err = ensure_fish_loader()
  if not fish_ok then
    local msg = fish_err == "target_exists"
        and "✘ Fish OSC 133 加载器未安装：conf.d 中已有非本配置管理的 nvim-osc133.fish"
      or "✘ Fish OSC 133 加载器安装失败："
    vim.schedule(function()
      vim.notify(msg .. (fish_err == "target_exists" and "" or tostring(fish_err)), vim.log.levels.WARN)
    end)
  end

  local group = vim.api.nvim_create_augroup("TermYankLastActive", { clear = true })
  vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "BufEnter" }, {
    group = group,
    callback = function(args)
      if is_term_buf(args.buf) then
        last_term_buf = args.buf
      end
    end,
  })

  local desc = "复制最后一个已完成终端命令块到 Windows 剪贴板"
  vim.keymap.set("n", "<leader>Y", function()
    M.copy_last()
  end, { noremap = true, silent = true, desc = desc })

  -- Terminal-mode callbacks run in Terminal-Job mode, so the user can keep typing.
  vim.keymap.set("t", "<leader>Y", function()
    M.copy_last(0)
  end, { noremap = true, silent = true, desc = desc })
end

-- Small integration-test surface; runtime behavior uses the public functions above.
M._prompt_rows = prompt_rows
M._extract_last_block = extract_last_block
M._resolve_term_buf = resolve_term_buf
M._ensure_fish_loader = ensure_fish_loader
M._set_last_term = function(bufnr)
  last_term_buf = bufnr
end

return M

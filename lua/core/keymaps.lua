-- ============================================================
-- core/keymaps.lua
-- 统一管理所有快捷键（LSP / Telescope / NvimTree / 终端 / 标签页 等）
-- ============================================================

-- vim.keymap.set 的简单别名
local map = vim.keymap.set

-- 默认选项：不递归映射、静默执行
local opts = { noremap = true, silent = true }

-- ============================================================
-- Windows 剪贴板同步（WSL 下把内容复制到 /mnt/c/.../clip.exe）
-- ============================================================

local function copy_to_win_clipboard(is_visual)
  -- 和之前 VimScript 版本一致的命令
  local cmd = 'iconv -f utf-8 -t utf-16le | /mnt/c/Windows/System32/clip.exe'

  local ok, err = pcall(function()
    if is_visual then
      -- 复制选中区域
      vim.cmd('silent \'<,\'>w !' .. cmd)
    else
      -- 复制全文
      vim.cmd('silent %w !' .. cmd)
    end
  end)

  if ok then
    vim.notify('✔ 已复制到 Windows 剪贴板', vim.log.levels.INFO)
  else
    vim.notify('✘ 复制失败：' .. tostring(err), vim.log.levels.ERROR)
  end
end

-- 复制全文到 Windows 剪贴板（普通模式：<Space>y）
map("n", "<leader>y", function()
  copy_to_win_clipboard(false)
end, { noremap = true, silent = true, desc = "复制全文到 Windows 剪贴板" })

-- 复制选中内容到 Windows 剪贴板（可视模式：选中 + <Space>y）
map("v", "<leader>y", function()
  copy_to_win_clipboard(true)
end, { noremap = true, silent = true, desc = "复制选中内容到 Windows 剪贴板" })

-- ============================================================
-- LSP 快捷键（适用于所有启用了 LSP 的 buffer）
-- ============================================================

-- 跳转到定义
map("n", "gd", vim.lsp.buf.definition, opts)

-- 跳转到声明
map("n", "gD", vim.lsp.buf.declaration, opts)

-- 跳转到实现（通常用于查看函数/接口实现）
map("n", "gi", vim.lsp.buf.implementation, opts)

-- 查找所有引用
map("n", "gr", vim.lsp.buf.references, opts)

-- 查看悬浮文档（函数说明、结构体文档等）
map("n", "K", vim.lsp.buf.hover, opts)

-- 变量/函数重命名（批量重命名）
map(
  "n",
  "<leader>rn",
  vim.lsp.buf.rename,
  { noremap = true, silent = true, desc = "LSP 重命名符号" }
)

-- 弹出代码操作（快速修复、导入等）
map(
  "n",
  "<leader>ca",
  vim.lsp.buf.code_action,
  { noremap = true, silent = true, desc = "LSP 代码操作 / 快速修复" }
)

-- LSP 格式化（异步执行）
-- 用 <leader>lf（LSP Format），避免和 “查找 / 搜索” 前缀 <leader>f 冲突
map("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { noremap = true, silent = true, desc = "LSP 格式化当前文件" })

-- 下一个诊断信息（错误 / 警告）
map("n", "]d", vim.diagnostic.goto_next, opts)

-- 上一个诊断信息
map("n", "[d", vim.diagnostic.goto_prev, opts)

-- 弹出诊断浮窗（改用 <leader>de，避免和 NvimTree 冲突）
map(
  "n",
  "<leader>de",
  vim.diagnostic.open_float,
  { noremap = true, silent = true, desc = "当前行诊断信息" }
)

-- 打开你的快捷键文档（keymaps.md）
map(
  "n",
  "<leader>km",
  ":e ~/.config/nvim/docs/keymaps.md<CR>",
  { noremap = true, silent = true, desc = "打开快捷键说明文档" }
)

-- ============================================================
-- NvimTree 文件树
-- ============================================================

-- 打开 / 关闭文件树（保留 <leader>e）
map(
  "n",
  "<leader>e",
  ":NvimTreeToggle<CR>",
  { noremap = true, silent = true, desc = "切换文件树" }
)

-- ============================================================
-- Telescope（模糊搜索框架）
-- ============================================================

-- 搜索文件（最常用），从当前 :pwd 开始递归
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { noremap = true, silent = true, desc = "搜索文件" })

-- 全局搜索文本（依赖 ripgrep，支持正则，从当前 :pwd 开始）
map("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { noremap = true, silent = true, desc = "全局搜索文本（正则）" })

-- 搜索已打开的 buffer
map("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { noremap = true, silent = true, desc = "搜索已打开的 buffer" })

-- 搜索 Neovim 帮助文档
map("n", "<leader>fh", function()
  require("telescope.builtin").help_tags()
end, { noremap = true, silent = true, desc = "搜索 Neovim 帮助文档" })

-- 当前文件内搜索（模糊匹配当前 buffer 的内容）
-- 类似 VSCode 在当前文件里快速跳转
map("n", "<leader>/", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, { noremap = true, silent = true, desc = "当前文件内搜索" })

-- 在指定目录中搜索文本（正则）
-- 步骤：
--   - 按 <leader>fs
--   - 命令行提示：Search in dir:
--   - 默认值是当前文件所在目录，可以直接回车，或者改成 src/、include/ 等任意路径
map("n", "<leader>fs", function()
  local builtin = require("telescope.builtin")

  -- 默认使用当前文件所在目录
  local default_dir = vim.fn.expand("%:p:h") .. "/"
  local dir = vim.fn.input("Search in dir: ", default_dir, "dir")

  -- 用户直接回车 / 取消输入，就不继续执行
  if dir == nil or dir == "" then
    return
  end

  builtin.live_grep({
    search_dirs = { dir }, -- 只在这个目录范围内搜索
  })
end, { noremap = true, silent = true, desc = "在指定目录中搜索文本（正则）" })

-- ============================================================
-- 终端：toggleterm
-- ============================================================

-- 普通终端（底部水平）：开 / 关
map(
  "n",
  "<leader>tt",
  ":ToggleTerm<CR>",
  { noremap = true, silent = true, desc = "切换终端（水平）" }
)

-- 在终端里运行 make（使用插件里定义的 _TOGGLE_MAKE_TERM）
map(
  "n",
  "<leader>tm",
  ":lua _TOGGLE_MAKE_TERM()<CR>",
  { noremap = true, silent = true, desc = "在终端运行 make" }
)

-- 在终端里运行 ./a.out（使用插件里定义的 _TOGGLE_RUN_TERM）
map(
  "n",
  "<leader>tr",
  ":lua _TOGGLE_RUN_TERM()<CR>",
  { noremap = true, silent = true, desc = "在终端运行 ./a.out" }
)

-- ============================================================
-- 标签页（tab）管理：像 tmux window 那样
-- ============================================================

-- 新建标签页（tab create）
map(
  "n",
  "<leader>tc",
  ":tabnew<CR>",
  { noremap = true, silent = true, desc = "新建标签页" }
)

-- 关闭当前标签页（tab close）
map(
  "n",
  "<leader>tq",
  ":tabclose<CR>",
  { noremap = true, silent = true, desc = "关闭当前标签页" }
)

-- 只保留当前标签页，关闭其它所有标签页（tab only）
map(
  "n",
  "<leader>to",
  ":tabonly<CR>",
  { noremap = true, silent = true, desc = "只保留当前标签页" }
)

-- 下一个标签页（tab next）
map(
  "n",
  "<leader>tn",
  ":tabnext<CR>",
  { noremap = true, silent = true, desc = "下一个标签页" }
)

-- 上一个标签页（tab prev）
map(
  "n",
  "<leader>tp",
  ":tabprevious<CR>",
  { noremap = true, silent = true, desc = "上一个标签页" }
)


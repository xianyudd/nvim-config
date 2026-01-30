-- core/options.lua
-- 这里放所有通用的基础配置

local opt = vim.opt
local g = vim.g

-- 行号
opt.number = true
opt.relativenumber = true

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- 编码
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- 外观
opt.termguicolors = true
opt.cursorline = true
opt.wrap = false

-- 交互
opt.mouse = "a"

-- leader 键
g.mapleader = " "

-- 自动把换行格式改成 unix，避免 
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*",
  command = "set fileformat=unix",
})

-- ==========================
-- Persistent Undo（退出 nvim 后仍可 undo）
-- ==========================
opt.undofile = true
opt.undolevels = 10000
opt.undoreload = 10000

-- undodir：放到 nvim 的 state 目录（更合理）
local undodir = vim.fn.stdpath("state") .. "/undo//"
vim.fn.mkdir(undodir, "p")
opt.undodir = undodir


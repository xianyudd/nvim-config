-- init.lua
-- Neovim 入口文件：加载基础配置 + 插件

-- 1. 加载基础配置（行号、缩进、自动 LF 等）
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- 2. 初始化 lazy.nvim 插件管理器
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("❗ lazy.nvim 没找到，请检查路径: " .. lazypath)
end
vim.opt.rtp:prepend(lazypath)

-- 3. 插件列表
require("lazy").setup("plugins")


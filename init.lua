-- init.lua
-- Neovim 入口文件：加载基础配置 + 插件

-- 1. 加载基础配置（行号、缩进、自动 LF 等）
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.term_yank").setup()

-- 2. 初始化 lazy.nvim 插件管理器（缺失时自动 clone）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      {
        "\n需要安装 Git 且网络可用，或者手动安装 lazy.nvim 到:\n  " .. lazypath .. "\n",
        "ErrorMsg",
      },
    }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

-- 3. 插件列表
require("lazy").setup("plugins")

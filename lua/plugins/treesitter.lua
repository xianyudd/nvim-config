-- lua/plugins/treesitter.lua
-- 语法高亮 / 基本缩进 / 结构感知
-- 使用 nvim-treesitter

return {
  "nvim-treesitter/nvim-treesitter",

  -- 安装或更新插件时自动运行 :TSUpdate，同步语法解析器
  build = ":TSUpdate",

  event = { "BufReadPost", "BufNewFile" },

  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      -----------------------------------------------------------------------
      -- 需要安装的语言解析器
      -- 可以按需增减，后面你常用什么语言再慢慢加
      -----------------------------------------------------------------------
      ensure_installed = {
        "c",
        "cpp",
        "lua",
        "python",
        "go",
        "javascript",
        "typescript",
        "json",
        "bash",
        "html",
        "css",
        "markdown",
        "vim",
        "query",
      },

      -- 同步安装（一般不用，保持 false 就行）
      sync_install = false,

      -- 打开文件时自动尝试安装缺失的解析器（需要网络，懒得折腾可以关）
      auto_install = true,

      -----------------------------------------------------------------------
      -- 语法高亮
      -----------------------------------------------------------------------
      highlight = {
        enable = true,
        -- 如果你发现和老的语法高亮冲突，可以把这个设为 true
        additional_vim_regex_highlighting = false,
      },

      -----------------------------------------------------------------------
      -- 基本缩进
      -----------------------------------------------------------------------
      indent = {
        enable = true,
      },

      -----------------------------------------------------------------------
      -- 增量选择（这里我们先关掉默认按键，避免和你自己的 keymaps 冲突）
      -----------------------------------------------------------------------
      incremental_selection = {
        enable = false,
        -- 以后你想玩可以自己在 core/keymaps.lua 里加映射
        -- keymaps = { ... }
      },
    })
  end,
}


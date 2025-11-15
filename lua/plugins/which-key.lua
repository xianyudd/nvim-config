-- lua/plugins/which-key.lua
-- 按下 <leader> / g 等前缀时，弹出快捷键提示菜单

return {
  "folke/which-key.nvim",

  -- 不需要很早加载，等 Neovim 空闲时加载即可
  event = "VeryLazy",

  config = function()
    local ok, wk = pcall(require, "which-key")
    if not ok then
      vim.notify("[which-key] 加载失败", vim.log.levels.ERROR)
      return
    end

    ---------------------------------------------------------------------------
    -- 1. 基础外观配置（使用新字段名：win / replace）
    ---------------------------------------------------------------------------
    wk.setup({
      -- 开哪些小功能
      plugins = {
        marks = true,       -- 显示 mark
        registers = true,   -- 显示寄存器
        spelling = false,   -- 拼写建议先关掉
      },

      -- ✅ 新版用 win，替代旧的 window
      win = {
        border = "rounded", -- 窗口圆角边框
        position = "bottom",
        margin = { 1, 1, 1, 1 },
        padding = { 1, 2, 1, 2 },
      },

      -- 布局相关
      layout = {
        spacing = 4,        -- 各组之间的间距
        align = "left",
      },

      icons = {
        breadcrumb = "»",
        separator  = "➜",
        group      = "+",
      },

      -- ✅ 新版用 replace，替代旧的 key_labels
      --    用来在提示里“重命名按键”显示，不影响真实键位。
      replace = {
        ["<leader>"] = "SPC",
      },
    })

    ---------------------------------------------------------------------------
    -- 2. 给 <leader> 下的前缀分组，并起一个中文名字（只影响显示）
    --
    --    真正的功能还是你 core/keymaps.lua 里的映射，这里只是说明分类。
    ---------------------------------------------------------------------------
    wk.add({
      -- 查找 / 搜索相关（ff / fg / fs / fb / fh / /）
      { "<leader>f", group = "查找 / 搜索", mode = "n" },

      -- 诊断 / LSP 相关（<leader>de 等）
      { "<leader>d", group = "诊断 / LSP", mode = "n" },

      -- 文档 / 帮助（<leader>km）
      { "<leader>k", group = "文档 / 帮助", mode = "n" },

      -- 终端 / 任务（<leader>tt / tm / tr）
      { "<leader>t", group = "终端 / 任务", mode = "n" },

      -- Windows 剪贴板（<leader>y）
      { "<leader>y", group = "Windows 剪贴板", mode = { "n", "v" } },

      -- LSP 专用前缀（比如 <leader>lf：格式化）
      { "<leader>l", group = "LSP / 格式化", mode = "n" },
    })
  end,
}


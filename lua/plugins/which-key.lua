-- lua/plugins/which-key.lua
-- 最终稳定版：立即触发、最少改动、自动根据 desc 显示描述
-- 并为所有 leader 前缀加上中文分组名称

return {
  "folke/which-key.nvim",
  event = "VimEnter",

  config = function()
    local ok, wk = pcall(require, "which-key")
    if not ok then
      vim.notify("[which-key] 加载失败", vim.log.levels.ERROR)
      return
    end

    vim.o.timeout = true
    vim.o.timeoutlen = 300

    wk.setup({
      delay = 0,
      win = {
        border = "rounded",
        padding = { 1, 2 },
        title = true,
        title_pos = "center",
      },
      layout = {
        spacing = 3,
      },

      triggers = {
        { "<leader>", mode = { "n", "v" } },
      },
    })

    ----------------------------------------------------------------------
    -- 这里是分组：which-key 会自动用你 keymaps.lua 的 desc 显示子项
    ----------------------------------------------------------------------
    wk.add({

      -- ========================
      -- 文件 / 搜索 (Telescope)
      -- ========================
      { "<leader>f", group = "文件 / 搜索", mode = "n" },

      -- ========================
      -- 终端 / 标签页 / Make / Run
      -- ========================
      { "<leader>t", group = "终端 / 标签页", mode = "n" },

      -- ========================
      -- Windows 剪贴板同步
      -- ========================
      { "<leader>y", group = "Windows 剪贴板", mode = { "n", "v" } },

      -- ========================
      -- LSP 系列
      -- ========================
      { "<leader>l", group = "LSP 操作", mode = "n" },
      { "<leader>r", group = "LSP 重命名 / 引用 / 实现", mode = "n" },
      { "<leader>c", group = "LSP 代码操作", mode = "n" },

      -- ========================
      -- 文档 / 帮助
      -- ========================
      { "<leader>k", group = "文档 / 帮助", mode = "n" },

      -- ========================
      -- 文件树
      -- ========================
      { "<leader>e", group = "文件树", mode = "n" },

      -- ========================
      -- 诊断
      -- ========================
      { "<leader>d", group = "诊断 (Diagnostics)", mode = "n" },

    })
  end,
}


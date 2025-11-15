-- lua/plugins/comment.lua
-- 代码注释插件：快速注释 / 取消注释当前行或选中块
-- 类似之前 Vim 里的 vim-commentary，但支持多语言、和 Treesitter 更配

return {
  "numToStr/Comment.nvim",
  event = { "BufReadPost", "BufNewFile" },  -- 打开文件时再加载，减少启动开销

  config = function()
    require("Comment").setup({
      --- 基础配置先用默认，已经很好用
      --- 下面是几个你可能关心的点：

      -- 是否启用基于 Treesitter 的上下文判断（比如在 JSX 里识别正确的注释方式）
      -- 你已经有 Treesitter 了，可以开：
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim")
        .create_pre_hook(),
    })
  end,

  -- 可选依赖：让不同语言里的“注释风格”更智能（比如 jsx/tsx 里用 {/* */}）
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
}


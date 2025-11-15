-- lua/plugins/autopairs.lua
-- 简单稳定的括号 / 引号自动补全
-- 使用 windwp/nvim-autopairs，只做两件事：
--   1）插入括号/引号时自动补全成对
--   2）在简单场景下支持成对删除（(|) 中间按退格）

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",  -- 进入插入模式时再加载，避免拖慢启动

  config = function()
    local npairs = require("nvim-autopairs")

    npairs.setup({
      ------------------------------------------------------------------------
      -- 基础行为
      ------------------------------------------------------------------------
      check_ts = false,  -- 暂时不用 treesitter，先关掉，减小干扰

      -- 在这些 filetype 里禁用自动括号（比如 Telescope 输入框）
      disable_filetype = { "TelescopePrompt", "vim" },

      ------------------------------------------------------------------------
      -- 删除相关
      ------------------------------------------------------------------------
      -- 让插件接管 <BS>：
      --   - 光标在一对括号/引号中间时：成对删除，例如 (|) + <BS> -> |
      --   - 其它情况：退格行为尽量贴近默认，不做太多“智能猜测”
      map_bs = true,
      map_c_h = false,   -- 不额外用 <C-h> 做退格，保持简单

      -- 其他配置使用默认值即可
      fast_wrap = {},
    })

    ------------------------------------------------------------------------
    -- （可选）和 nvim-cmp 联动：
    --   在补全菜单中选中函数时，自动补一个右括号 )
    --   比如：选择 printf -> 变成 printf(|)
    --   如果你以后觉得多余，可以把这段删掉。
    ------------------------------------------------------------------------
    local ok_cmp, cmp = pcall(require, "cmp")
    if ok_cmp then
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end,
}


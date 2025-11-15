-- lua/plugins/surround.lua
-- 成对结构的增删改：() {} [] "" '' 等
-- 用在普通模式 / 可视模式，解决“整对括号怎么删 / 换”的问题

return {
  "kylechui/nvim-surround",
  version = "*",        -- 用稳定版即可
  event = "VeryLazy",   -- 启动后空闲时加载，不拖慢启动

  config = function()
    require("nvim-surround").setup({
      -- 默认配置已经很好用了，这里先不做复杂自定义
      -- 以后你想改映射 / 行为，再单独调
    })
  end,
}


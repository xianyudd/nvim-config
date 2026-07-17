-- lua/plugins/cmp.lua
-- nvim-cmp 主配置：补全菜单 + snippet

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- 进入插入模式时再加载，减少启动时间

  dependencies = {
    -- LSP 源（配合 nvim-lspconfig）
    "hrsh7th/cmp-nvim-lsp",
    -- Buffer 内容补全
    "hrsh7th/cmp-buffer",
    -- 文件路径补全
    "hrsh7th/cmp-path",
    -- 命令行补全（: 后面）
    "hrsh7th/cmp-cmdline",

    -- Snippet 支持（必需：用于展开 LSP/CMP 返回的 snippet）
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
  },

  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- 加载 VSCode 风格的 snippet（friendly-snippets）
    require("luasnip.loaders.from_vscode").lazy_load()

    --------------------------------------------------------------------------
    -- nvim-cmp 主配置
    --------------------------------------------------------------------------
    cmp.setup({
      ------------------------------------------------------------------------
      -- snippet 配置
      -- 所有来自 LSP 的 snippet（比如带占位符的函数）都交给 LuaSnip 展开
      ------------------------------------------------------------------------
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      ------------------------------------------------------------------------
      -- 按键映射（Insert 模式下的补全行为）
      ------------------------------------------------------------------------
      mapping = cmp.mapping.preset.insert({
        -- 手动触发补全菜单：Ctrl + Space
        ["<C-Space>"] = cmp.mapping.complete(),

        -- 回车：菜单可见时确认候选项，否则正常换行
        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true })
          else
            fallback()
          end
        end, { "i", "s" }),

        ----------------------------------------------------------------------
        -- Tab / Shift-Tab 行为：
        -- - 补全菜单可见时：在候选项间向前/向后移动
        -- - 否则：尝试在 LuaSnip snippet 中跳转占位符
        -- - 再否则：退回编辑器默认 Tab 行为（缩进）
        ----------------------------------------------------------------------
        ["<Tab>"] = function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end,

        ["<S-Tab>"] = function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end,
      }),

      ------------------------------------------------------------------------
      -- 补全数据源
      -- 顺序即优先级（从上往下）
      ------------------------------------------------------------------------
      sources = {
        { name = "nvim_lsp" }, -- 来自 LSP（clangd / pyright / gopls 等）
        { name = "buffer" },   -- 当前 buffer 中出现过的单词
        { name = "path" },     -- 文件路径补全
        { name = "luasnip" },  -- snippet 补全（LuaSnip）
      },
    })
  end,
}

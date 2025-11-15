-- lua/plugins/cmp.lua
-- nvim-cmp 主配置：补全菜单 + snippet + “智能自动补分号”（模拟 coc 的体验）

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
    -- 1. 需要“自动补分号”的语言配置
    --    只在这些 filetype 下，确认补全后自动在行尾加 `;`
    --    可以根据需要自行增删，例如：
    --    javascript / typescript / rust 等
    --------------------------------------------------------------------------
    local auto_semicolon_filetypes = {
      c    = true,
      cpp  = true,
      java = true,
      go   = true,
      -- ["javascript"] = true,
      -- ["typescript"] = true,
      ["rust"] = true,
    }

    --------------------------------------------------------------------------
    -- 2. nvim-cmp 主配置
    --------------------------------------------------------------------------
    cmp.setup({
      ------------------------------------------------------------------------
      -- 2.1 snippet 配置
      --     所有来自 LSP 的 snippet（比如带占位符的函数）都交给 LuaSnip 展开
      ------------------------------------------------------------------------
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      ------------------------------------------------------------------------
      -- 2.2 按键映射（Insert 模式下的补全行为）
      ------------------------------------------------------------------------
      mapping = cmp.mapping.preset.insert({
        -- 手动触发补全菜单：Ctrl + Space
        ["<C-Space>"] = cmp.mapping.complete(),

        ----------------------------------------------------------------------
        -- 回车键：模拟 coc 的“智能补全 + 自动分号”体验
        --
        -- 行为说明：
        -- 1. 如果补全菜单可见：
        --    - 先确认当前选中项（默认选中第一项）
        --    - 然后（异步）检查当前 buffer 的 filetype：
        --        * 若不在 auto_semicolon_filetypes 中：直接结束
        --        * 若在其中：检查当前行末尾是否已经有分号；
        --          - 没有：自动在“逻辑行末尾”加一个 `;`
        --          - 已有：不重复添加
        --    ✅ 这样就可以做到：
        --       - 函数补全后 → 自动加 `;`
        --       - 如果你已经手动写了 `;` → 不会重复
        --
        -- 2. 如果补全菜单不可见：
        --    - 回退为普通的 <CR> 行为（换行）
        ----------------------------------------------------------------------
        ["<CR>"] = function(fallback)
          if cmp.visible() then
            -- 先确认补全选项（类似 coc#pum#confirm()）
            cmp.confirm({ select = true })

            -- 使用 vim.schedule 确保下面的逻辑在文本真正插入之后执行
            vim.schedule(function()
              local ft = vim.bo.filetype
              -- 不在自动分号名单中的语言，直接跳过
              if not auto_semicolon_filetypes[ft] then
                return
              end

              -- 当前行内容
              local line = vim.api.nvim_get_current_line()
              -- 去掉行尾空白（逻辑上的“行末”）
              local trimmed = line:gsub("%s+$", "")

              -- 空行，无需处理
              if trimmed == "" then
                return
              end

              -- 1）如果本来就以 ; 结尾，什么都不做
              if trimmed:sub(-1) == ";" then
                return
              end

              -- 2）更保守一点：如果行尾已经有 ; + 若干空格，也不重复加
              if trimmed:match(";%s*$") then
                return
              end

              -- 保留原有行尾空白
              local suffix = line:match("%s+$") or ""
              local new_line = trimmed .. ";" .. suffix

              -- 写回当前行
              vim.api.nvim_set_current_line(new_line)
            end)
          else
            -- 如果补全菜单不可见，就按普通回车处理
            fallback()
          end
        end,

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
      -- 2.3 补全数据源
      --     这里可以根据需要增删，顺序即优先级（从上往下）
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


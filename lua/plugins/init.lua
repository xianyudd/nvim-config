-- lua/plugins/init.lua
-- 所有插件列表写在这里（不写快捷键，只做功能配置）

return {
  -- ==========================
  {
    "folke/tokyonight.nvim",
    lazy = false,      -- 不延迟加载，启动就生效
    priority = 1000,   -- 提前加载主题，避免闪烁
    config = function()
      vim.cmd("colorscheme tokyonight")
    end,
  },

  -- ==========================
  -- 左侧目录树：nvim-tree
  -- ==========================
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      -- ❗ 不要写快捷键，快捷键统一放在 core/keymaps.lua
    end,
  },

  -- ==========================
  -- 模糊搜索：Telescope
  -- ==========================
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      -- ❗ 不要写快捷键，快捷键统一放在 core/keymaps.lua
    end,
  },

  -- ==========================
  -- 状态栏：Lualine
  -- ==========================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          icons_enabled = true,
          component_separators = "|",
          section_separators = "",
        },
      })
    end,
  },

  -- ==========================
  -- 图标：mini.icons（可选，用来消掉 which-key 的 warning）
  -- ==========================
  {
    "echasnovski/mini.icons",
    version = false,  -- 始终用最新，不锁 tag
    lazy = true,      -- 需要时再加载，不影响启动速度
  },


  -- ==========================
  -- 多语言 LSP 配置（C/C++/Python/Go/JS 等）
  -- ==========================
  require("plugins.lsp"),

  -- ==========================
  -- 自动补全：nvim-cmp + LuaSnip
  -- ==========================
  require("plugins.cmp"),

  -- Treesitter 语法高亮 / 缩进
  require("plugins.treesitter"),
 
  -- ==========================
  -- 括号 / 引号自动补全：nvim-autopairs
  -- ==========================
  require("plugins.autopairs"),

  -- 代码注释插件
  require("plugins.comment"),

  -- 成对结构的增删改：nvim-surround（ds{ / cs{( / ysiw)）
  require("plugins.surround"),

  -- 终端：toggleterm，在 Neovim 里开终端跑 make / ./a.out
  require("plugins.toggleterm"),

  -- 快捷键提示：which-key
  require("plugins.which-key"),
}



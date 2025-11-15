-- lua/plugins/toggleterm.lua
-- 在 Neovim 里打开可切换的终端（适合跑 make / ./a.out 等命令）
-- 插件：akinsho/toggleterm.nvim

return {
  "akinsho/toggleterm.nvim",

  -- 锁定大版本，避免未来更新突然 break 配置
  version = "*",

  -- 不需要非常早加载，启动后空闲时加载即可
  event = "VeryLazy",

  config = function()
    ---------------------------------------------------------------------------
    -- 1. 基础 setup：只做几件简单的事情
    --    - 默认开一个水平终端（底部）
    --    - 打开时自动进入插入模式
    --    - 使用当前 Neovim 的 shell（你在 WSL 下可以是 bash/fish）
    --    - 不在这里配快捷键，快捷键统一写在 core/keymaps.lua
    ---------------------------------------------------------------------------
    require("toggleterm").setup({
      size = 12,                -- 默认高度，12 行左右，一般够用
      direction = "horizontal", -- 默认水平分屏终端（在底部）
      open_mapping = nil,       -- 不用插件自带的按键，键位统一放 core/keymaps.lua

      hide_numbers = true,      -- 终端 buffer 不显示行号
      shade_terminals = true,   -- 终端背景稍微变暗一点，区分普通窗口
      start_in_insert = true,   -- 打开终端时自动进入插入模式
      insert_mappings = true,   -- 在终端里保留常用映射（如 <C-w> 等）
      terminal_mappings = true, -- 在终端模式下也启用插件的映射（一般保持默认即可）

      persist_size = true,      -- 记住上一次的终端尺寸
      persist_mode = true,      -- 记住上一次的模式（一般是 insert）

      close_on_exit = true,     -- 终端进程退出后自动关闭窗口
      shell = vim.o.shell,      -- 使用当前 Neovim 的 shell（WSL 下可配置为 fish/bash）
    })

    ---------------------------------------------------------------------------
    -- 2. 为 make / ./a.out 准备两个专用终端
    --    思路：
    --      - 用 toggleterm.terminal.Terminal:new 创建两个“预设终端”
    --      - 暴露两个全局函数 _TOGGLE_MAKE_TERM / _TOGGLE_RUN_TERM
    --      - 在 core/keymaps.lua 里绑定快捷键调用这两个函数
    ---------------------------------------------------------------------------
    local Terminal = require("toggleterm.terminal").Terminal

    -- 在当前工作目录中执行 `make` 的终端
    local make_term = Terminal:new({
      cmd = "make",             -- 打开时自动运行的命令
      hidden = true,            -- 不在 :ToggleTerm 列表里显示名字，保持干净
      direction = "horizontal", -- 也使用水平终端
    })

    function _TOGGLE_MAKE_TERM()
      make_term:toggle()
    end

    -- 在当前工作目录中执行 `./a.out` 的终端
    local run_term = Terminal:new({
      cmd = "./a.out",
      hidden = true,
      direction = "horizontal",
    })

    function _TOGGLE_RUN_TERM()
      run_term:toggle()
    end
  end,
}


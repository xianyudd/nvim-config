# Neovim Config 

个人 Neovim 配置仓库，用于在 **WSL Ubuntu + Neovim 0.11+** 环境下提供接近 IDE 的开发体验：

* 插件管理：`lazy.nvim`
* 语言支持：C/C++、Python、Go、TypeScript/JavaScript、Rust（可选）
* 特性：LSP、自动补全、文件树、模糊搜索、内置终端、括号/包裹/注释增强等

---

## 1. 环境要求

### 1.1 基础环境

> 以下命令以 Ubuntu（WSL）为例。

* **Neovim** ≥ 0.11（建议通过 Homebrew 安装）
* **Git**
* **ripgrep**（Telescope 文本搜索依赖，命令 `rg`）
* **fd**（可选，提升文件搜索体验，命令 `fd`）

```bash
# 基础工具
sudo apt update
sudo apt install -y git ripgrep

# fd，在 Ubuntu 中包名为 fd-find
sudo apt install -y fd-find
# 可选：把 fdfind 链接为 fd
mkdir -p ~/.local/bin
ln -s "$(command -v fdfind)" ~/.local/bin/fd
```

Neovim 可通过 Homebrew 安装（推荐）：

```bash
brew install neovim
```

> 请确保 `nvim --version` 至少为 0.11。更低版本与本配置中部分 API（如 `vim.lsp.config`）不兼容。

---

### 1.2 语言服务器（LSP）

本配置在 `lua/plugins/lsp.lua` 中预置了多语言 LSP 配置，但 **不会自动安装语言服务器本身**，需要在系统中自行安装：

#### C / C++ — `clangd`

```bash
sudo apt install -y clangd
```

#### Python — `pyright`

```bash
# 二选一
npm install -g pyright
# 或
pip install pyright
```

#### Go — `gopls`

```bash
go install golang.org/x/tools/gopls@latest
```

#### JavaScript / TypeScript — `typescript-language-server`

```bash
npm install -g typescript typescript-language-server
```

#### Rust（可选）— `rust-analyzer`

```bash
# 如果使用 rustup
rustup component add rust-analyzer
```

> ⚠️ 未安装对应 LSP 时，Neovim 启动会出现类似提示： `[lsp] 可执行文件 'xxx' 未找到，跳过 LSP 'yyy'`
> 仅表示跳过该语言，不会影响其他语言的正常使用。

---

### 1.3 WSL 相关（可选但推荐）

* **wslu + xdg-utils**：让 `vim.ui.open` / `gx` 能在 Windows 浏览器中打开链接。

```bash
sudo apt install -y wslu xdg-utils
sudo update-alternatives --install /usr/bin/xdg-open xdg-open /usr/bin/wslview 100
```

* **Windows 剪贴板**：本配置通过 `/mnt/c/Windows/System32/clip.exe` 支持复制到 Windows 剪贴板，需要在 WSL 中可访问该路径（默认可以）。

---

## 2. 仓库结构

```text
~/.config/nvim
├── init.lua                  # Neovim 入口：加载 core 配置 + lazy.nvim
├── lazy-lock.json            # lazy.nvim 锁文件，记录插件版本
├── docs
│   └── keymaps.md            # 快捷键说明文档（<leader>km 打开）
└── lua
    ├── core
    │   ├── options.lua       # 基础选项：行号、缩进、搜索、编码等
    │   └── keymaps.lua       # 所有自定义快捷键（LSP/Telescope/终端等）
    └── plugins
        ├── init.lua          # 插件列表：主题、文件树、Telescope、Lualine 等
        ├── cmp.lua           # nvim-cmp + LuaSnip 自动补全配置
        ├── lsp.lua           # 多语言 LSP 统一配置（vim.lsp.config / vim.lsp.enable）
        ├── treesitter.lua    # nvim-treesitter：高亮 / 缩进 / 语法解析
        ├── autopairs.lua     # nvim-autopairs：括号 / 引号成对补全
        ├── surround.lua      # mini.surround：y s / d s / c s 包裹编辑
        ├── comment.lua       # Comment.nvim：gc / gcc 注释
        ├── toggleterm.lua    # toggleterm.nvim：内置终端 + make / ./a.out
        ├── which-key.lua     # which-key.nvim：快捷键提示
        └── ...               # 后续可按需扩展
```

> 插件本体（下载的代码）位于 `~/.local/share/nvim` 下，由 lazy.nvim 自动管理，**无需纳入 Git 仓库**。

---

## 3. 安装与使用

### 3.1 初次克隆配置

```bash
# 将仓库克隆到 Neovim 配置目录
rm -rf ~/.config/nvim  # 如存在旧配置，可先备份再删除

git clone git@github.com:xianyudd/nvim-config.git ~/.config/nvim

# 启动 Neovim
nvim
```

首次启动时：

1. `init.lua` 会加载 lazy.nvim；若 `stdpath("data")/lazy/lazy.nvim` 不存在，会用 `git clone --filter=blob:none --branch=stable` 自动安装。需要本机已安装 Git 且能访问 GitHub；失败时会打印错误并中止加载插件（不会再出现含糊的 `module 'lazy' not found`）。也可手动克隆到该路径。
2. lazy.nvim 依据 `lua/plugins/init.lua` 自动安装所有插件。
3. 安装完成后，可执行 `:Lazy` 查看插件状态，执行 `:checkhealth` 检查整体健康状况。

---

### 3.2 快捷键文档

本配置将快捷键说明集中写在：

* `docs/keymaps.md`

在 Neovim 内可通过：

```text
<Space> k m
```

即 `<leader>km` 快速打开该文档。

---

## 4. 功能概览

### 4.1 UI 与布局

* **主题**：`folke/tokyonight.nvim`
* **状态栏**：`nvim-lualine/lualine.nvim`
* **文件树**：`nvim-tree/nvim-tree.lua`

  * 主键位：`<leader>e` 打开 / 关闭

### 4.2 导航与搜索

* **模糊搜索**：`nvim-telescope/telescope.nvim`

  * `<leader>ff`：搜索文件（默认从当前工作目录递归）
  * `<leader>fg`：全局文本搜索（基于 ripgrep，支持正则）
  * `<leader>/`：当前 buffer 内搜索
  * `<leader>fs`：在指定目录中搜索文本（会提示输入目录路径）
  * `<leader>fb`：搜索已打开的 buffer
  * `<leader>fh`：搜索 Neovim 帮助文档

* **快捷键提示**：`folke/which-key.nvim`

  * 按下 `<leader>` 后，自动弹出可用快捷键菜单。

### 4.3 LSP 与自动补全

* 使用 Neovim 0.11 新 API：

  * `vim.lsp.config(server, opts)` 注册配置
  * `vim.lsp.enable(server)` 启用 LSP
* 统一能力由 `cmp_nvim_lsp.default_capabilities` 提供，与 nvim-cmp 自动补全集成。
* 目前预设的语言：

  * C / C++：`clangd`
  * Python：`pyright`
  * Go：`gopls`
  * JavaScript / TypeScript：`tsserver`（typescript-language-server）
  * Rust：`rust_analyzer`（可选）

**补全相关操作**（见 `lua/plugins/cmp.lua`）：

* `Insert` 模式下：

  * `<C-Space>`：手动弹出补全菜单
  * `<CR>`：确认当前选中项（若未手动选择则默认第一项）
  * `<Tab>` / `<S-Tab>`：在候选项或 snippet 占位符间跳转

### 4.4 编辑增强

* **括号 / 引号补全**：`windwp/nvim-autopairs`
* **包裹编辑**：`echasnovski/mini.surround`

  * 示例：`ysiw"` 为一个单词加上双引号
* **注释**：`numToStr/Comment.nvim`

  * 普通行注释：`gcc`
  * 选区注释：`gc` + motion 或 Visual 模式选中后 `gc`

### 4.5 终端与 C 语言编译运行

使用 `akinsho/toggleterm.nvim`：

* `<leader>tt`：切换底部终端
* `<leader>tm`：在专用终端运行 `make`
* `<leader>tr`：在专用终端运行 `./a.out`

适合简单的 C 项目在 Neovim 内直接编译 / 运行。

---

## 5. 常见问题（FAQ）

### Q1. 启动 Neovim 时提示某个 LSP 的可执行文件未找到？

* 说明对应语言服务器尚未在系统中安装。
* 按本 README 的 **1.2 小节** 安装对应 LSP 即可。

---

### Q2. `vim.ui.open` / `Open in web browser` 报错 `xdg-open` 相关？

* 在 WSL 环境下，Neovim 默认通过 `xdg-open` 打开浏览器。
* 如果未安装 `xdg-open` 或未配置为 `wslview`，会报错。
* 参照 **1.3 WSL 相关** 安装 `wslu` 并配置 `xdg-open`。

---

### Q3. Telescope 搜索无结果 / 报错 `rg` 未找到？

* 确认是否安装了 `ripgrep`：

```bash
rg --version
```

* 如果没有，执行：

```bash
sudo apt install -y ripgrep
```

---

如有需要，可将本仓库作为个人 Neovim 配置模板，在此基础上按自身习惯继续扩展。


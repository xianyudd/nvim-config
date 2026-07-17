# 📝 Neovim 快捷键说明文档（完整版）

> 文件路径：`~/.config/nvim/docs/keymaps.md`
> 约定：`<leader>` = 空格键（Space）

---

## 📦 1. 基础移动与窗口 / 分屏

### 1.1 基础移动

* `h` / `j` / `k` / `l` — 左 / 下 / 上 / 右 移动
* `gg` — 跳到文件开头
* `G` — 跳到文件末尾
* `0` — 跳到行首
* `$` — 跳到行尾

### 1.2 分屏（Split）

> Neovim 自带分屏功能，不需要插件。

命令：

* `:vsplit` / `:vsp` — 垂直分屏（左右分屏）
* `:split` / `:sp` — 水平分屏（上下分屏）

窗口切换（`Ctrl-w` 开头）：

* `<C-w> h` — 切到左边窗口
* `<C-w> l` — 切到右边窗口
* `<C-w> j` — 切到下方窗口
* `<C-w> k` — 切到上方窗口
* `<C-w> w` — 在所有窗口之间轮流切换

窗口大小：

* `<C-w> =` — 所有窗口等宽等高
* `<C-w> +` / `-` — 调整当前窗口高度
* `<C-w> >` / `<` — 调整当前窗口宽度

关闭当前窗口：

* `:q` 或 `:close`

---

## 🗂 2. 标签页（Tab）管理

> 可以理解为“tmux 的 window”：每个标签页里可以有自己的一套分屏布局。

自定义快捷键（在 `core/keymaps.lua` 中定义）：

* `<leader>tc` — 新建标签页（tab create）
* `<leader>tq` — 关闭当前标签页（tab close）
* `<leader>to` — 只保留当前标签页，关闭其他所有标签页
* `<leader>tn` — 切换到下一个标签页（tab next）
* `<leader>tp` — 切换到上一个标签页（tab prev）

内置命令：

* `:tabnew` / `:tabe {file}` — 新建标签页
* `:tabnext` / `:tabn` — 下一个标签页
* `:tabprevious` / `:tabp` — 上一个标签页
* `:tabclose` — 关闭当前标签页
* `:tabonly` — 只保留当前标签页
* `gt` / `gT` — 在标签页之间前后切换

> 提示：如果在 `core/options.lua` 里设置 `vim.o.showtabline = 2`，顶部会一直显示标签栏。

---

## 📘 3. LSP 快捷键（clangd / pyright / gopls / tsserver 等）

> 前提：对应语言的 LSP 已开启（在 `lua/plugins/lsp.lua` 里配置）。

### 3.1 跳转 / 查找

* `gd` — 跳转到定义（Go to Definition）
* `gD` — 跳转到声明（Go to Declaration）
* `gi` — 跳转到实现（Go to Implementation）
* `gr` — 查找引用（References）
* `<C-o>` — 返回上一个位置（跳转后退）
* `<C-i>` — 跳转前进

### 3.2 文档 / 重命名 / 格式化

* `K` — 悬浮文档（Hover，查看函数/变量说明）
* `<leader>rn` — 重命名符号（Rename symbol）
* `<leader>ca` — Code Action（快速修复 / 导入 / 重构）
* `<leader>lf` — **LSP 格式化当前文件**（LSP Format）

> 说明：`<leader>lf` 中的 `l` 代表 LSP，避免和 `<leader>f` 系列“查找 / 搜索”前缀冲突。

---

## ⚠️ 4. 诊断（Diagnostics：错误 / 警告）

* `]d` — 跳到下一条诊断信息（错误 / 警告）
* `[d` — 跳到上一条诊断信息
* `<leader>de` — 弹出当前行的诊断浮窗（diagnostic float）

---

## 📂 5. 文件目录树（NvimTree）

> 插件：`nvim-tree.lua`

### 5.1 打开 / 关闭

* `<leader>e` — 打开 / 关闭 左侧文件树

### 5.2 NvimTree 内常用操作（默认键位）

> 仅在 NvimTree 窗口里生效。

* `<CR>` 或 `l` — 打开文件 / 展开目录
* `h` — 关闭目录（折叠）
* `a` — 新建文件 / 目录
* `r` — 重命名
* `d` — 删除
* `c` — 复制
* `p` — 粘贴
* `y` — 复制名称 / 路径（带提示菜单）

> 这些是插件的默认键位，你可以通过 `:help nvim-tree-default-mappings` 查看完整列表。

---

## 🔍 6. 搜索与跳转（Telescope）

> 插件：`telescope.nvim`，依赖 `ripgrep (rg)`。

### 6.1 文件与帮助搜索

* `<leader>ff` — 搜索文件（从当前 `:pwd` 开始递归）
* `<leader>fb` — 搜索已打开的 buffer
* `<leader>fh` — 搜索 Neovim 帮助文档（help tags）

### 6.2 文本搜索（正则 / 全局 / 指定目录）

* `<leader>fg` — 全局搜索文本（正则），从当前 `:pwd` 开始递归
* `<leader>fs` — 在“指定目录”中搜索文本（正则）：

  * 按 `<leader>fs` 后，命令行会提示 `Search in dir:`
  * 默认值是当前文件所在目录，可以直接回车，或者改成 `src/`、`include/` 等路径
  * 只会在这个目录（及其子目录）里搜索

### 6.3 当前文件内搜索

* `<leader>/` — **当前文件内搜索**（current buffer fuzzy find）

  * 只在当前 buffer 内模糊搜索行内容
  * 类似 VSCode “在当前文件里搜索 / 快速跳转”

> 提示：`ff / fg / fs` 都是递归扫描子目录；`<leader>/` 只在当前文件内部，不会跨文件。

---

## 🧾 7. 终端（toggleterm.nvim）

> 插件：`toggleterm.nvim`，用于在 Neovim 里快捷打开终端执行命令。

### 7.1 基础终端

* `<leader>tt` — 切换水平终端（打开 / 关闭）

  * 默认在底部打开一个终端窗口
  * 再按一次 `<leader>tt` 会隐藏 / 显示

终端内常用：

* `Esc` / `<C-\><C-n>` — 从终端插入模式回到普通模式
* 在普通模式下可用 `:q` 关闭该终端窗口

### 7.2 专用终端（make / ./a.out）

> 这两个按键是为了 C 项目习惯做的预设，你可以以后按需要再扩展。

* `<leader>tm` — 在专用终端里执行 `make`
* `<leader>tr` — 在专用终端里执行 `./a.out`

> 如果当前目录没有 `Makefile` 或 `./a.out`，命令会报错，但不会影响 Neovim。

---

## 📎 8. Windows 剪贴板同步（WSL 场景）

> 场景：在 WSL 的 Neovim 里编辑文件，希望复制到 **Windows 系统剪贴板**。

自定义按键：

* `<leader>y`（普通模式）— 复制 **全文** 到 Windows 剪贴板
* 选中一段文本后 `<leader>y`（可视模式）— 复制选中内容到 Windows 剪贴板
* `<leader>yy` — 复制 **上一条终端命令 + 完整输出** 到 Windows 剪贴板（依赖 OSC 133 / `:terminal` 或 toggleterm）

内部实现：

* 实际命令为：`iconv -f utf-8 -t utf-16le | /mnt/c/Windows/System32/clip.exe`
* 复制成功 / 失败会通过 `vim.notify` 提示：

  * `✔ 已复制到 Windows 剪贴板`
  * `✘ 复制失败：...`

---

## 🧱 9. 常用编辑操作（Neovim 默认行为）

> 以下为 Neovim/Vim 的基础操作，与本配置无关，但列在这里方便查阅。

### 9.1 文本编辑

* `yy` — 复制当前行
* `dd` — 删除当前行
* `p` — 在光标后粘贴
* `P` — 在光标前粘贴
* `u` — 撤销
* `<C-r>` — 重做

### 9.2 缩进与自动格式

* `>>` — 当前行向右缩进
* `<<` — 当前行向左缩进
* `=` + motion — 根据语法自动缩进（例如 `=%`、`=G`）

---

## 📁 10. 文件 / Buffer / 退出

### 10.1 保存与退出

* `:w` — 保存当前文件
* `:q` — 退出当前窗口# 📝 Neovim 快捷键说明文档（完整版）

> 文件路径：`~/.config/nvim/docs/keymaps.md`
> 约定：`<leader>` = 空格键（Space）

---

## 📦 1. 基础移动与窗口 / 分屏

### 1.1 基础移动

* `h` / `j` / `k` / `l` — 左 / 下 / 上 / 右 移动
* `gg` — 跳到文件开头
* `G` — 跳到文件末尾
* `0` — 跳到行首
* `$` — 跳到行尾

### 1.2 分屏（Split）

> Neovim 自带分屏功能，不需要插件。

命令：

* `:vsplit` / `:vsp` — 垂直分屏（左右分屏）
* `:split` / `:sp` — 水平分屏（上下分屏）

窗口切换（`Ctrl-w` 开头）：

* `<C-w> h` — 切到左边窗口
* `<C-w> l` — 切到右边窗口
* `<C-w> j` — 切到下方窗口
* `<C-w> k` — 切到上方窗口
* `<C-w> w` — 在所有窗口之间轮流切换

窗口大小：

* `<C-w> =` — 所有窗口等宽等高
* `<C-w> +` / `-` — 调整当前窗口高度
* `<C-w> >` / `<` — 调整当前窗口宽度

关闭当前窗口：

* `:q` 或 `:close`

---

## 🗂 2. 标签页（Tab）管理

> 可以理解为“tmux 的 window”：每个标签页里可以有自己的一套分屏布局。

自定义快捷键（在 `core/keymaps.lua` 中定义）：

* `<leader>tc` — 新建标签页（tab create）
* `<leader>tq` — 关闭当前标签页（tab close）
* `<leader>to` — 只保留当前标签页，关闭其他所有标签页
* `<leader>tn` — 切换到下一个标签页（tab next）
* `<leader>tp` — 切换到上一个标签页（tab prev）

内置命令：

* `:tabnew` / `:tabe {file}` — 新建标签页
* `:tabnext` / `:tabn` — 下一个标签页
* `:tabprevious` / `:tabp` — 上一个标签页
* `:tabclose` — 关闭当前标签页
* `:tabonly` — 只保留当前标签页
* `gt` / `gT` — 在标签页之间前后切换

> 提示：如果在 `core/options.lua` 里设置 `vim.o.showtabline = 2`，顶部会一直显示标签栏。

---

## 📘 3. LSP 快捷键（clangd / pyright / gopls / tsserver 等）

> 前提：对应语言的 LSP 已开启（在 `lua/plugins/lsp.lua` 里配置）。

### 3.1 跳转 / 查找

* `gd` — 跳转到定义（Go to Definition）
* `gD` — 跳转到声明（Go to Declaration）
* `gi` — 跳转到实现（Go to Implementation）
* `gr` — 查找引用（References）
* `<C-o>` — 返回上一个位置（跳转后退）
* `<C-i>` — 跳转前进

### 3.2 文档 / 重命名 / 格式化

* `K` — 悬浮文档（Hover，查看函数/变量说明）
* `<leader>rn` — 重命名符号（Rename symbol）
* `<leader>ca` — Code Action（快速修复 / 导入 / 重构）
* `<leader>lf` — **LSP 格式化当前文件**（LSP Format）

> 说明：`<leader>lf` 中的 `l` 代表 LSP，避免和 `<leader>f` 系列“查找 / 搜索”前缀冲突。

---

## ⚠️ 4. 诊断（Diagnostics：错误 / 警告）

* `]d` — 跳到下一条诊断信息（错误 / 警告）
* `[d` — 跳到上一条诊断信息
* `<leader>de` — 弹出当前行的诊断浮窗（diagnostic float）

---

## 📂 5. 文件目录树（NvimTree）

> 插件：`nvim-tree.lua`

### 5.1 打开 / 关闭

* `<leader>e` — 打开 / 关闭 左侧文件树

### 5.2 NvimTree 内常用操作（默认键位）

> 仅在 NvimTree 窗口里生效。

* `<CR>` 或 `l` — 打开文件 / 展开目录
* `h` — 关闭目录（折叠）
* `a` — 新建文件 / 目录
* `r` — 重命名
* `d` — 删除
* `c` — 复制
* `p` — 粘贴
* `y` — 复制名称 / 路径（带提示菜单）

> 这些是插件的默认键位，你可以通过 `:help nvim-tree-default-mappings` 查看完整列表。

---

## 🔍 6. 搜索与跳转（Telescope）

> 插件：`telescope.nvim`，依赖 `ripgrep (rg)`。

### 6.1 文件与帮助搜索

* `<leader>ff` — 搜索文件（从当前 `:pwd` 开始递归）
* `<leader>fb` — 搜索已打开的 buffer
* `<leader>fh` — 搜索 Neovim 帮助文档（help tags）

### 6.2 文本搜索（正则 / 全局 / 指定目录）

* `<leader>fg` — 全局搜索文本（正则），从当前 `:pwd` 开始递归
* `<leader>fs` — 在“指定目录”中搜索文本（正则）：

  * 按 `<leader>fs` 后，命令行会提示 `Search in dir:`
  * 默认值是当前文件所在目录，可以直接回车，或者改成 `src/`、`include/` 等路径
  * 只会在这个目录（及其子目录）里搜索

### 6.3 当前文件内搜索

* `<leader>/` — **当前文件内搜索**（current buffer fuzzy find）

  * 只在当前 buffer 内模糊搜索行内容
  * 类似 VSCode “在当前文件里搜索 / 快速跳转”

> 提示：`ff / fg / fs` 都是递归扫描子目录；`<leader>/` 只在当前文件内部，不会跨文件。

---

## 🧾 7. 终端（toggleterm.nvim）

> 插件：`toggleterm.nvim`，用于在 Neovim 里快捷打开终端执行命令。

### 7.1 基础终端

* `<leader>tt` — 切换水平终端（打开 / 关闭）

  * 默认在底部打开一个终端窗口
  * 再按一次 `<leader>tt` 会隐藏 / 显示

终端内常用：

* `Esc` / `<C-\><C-n>` — 从终端插入模式回到普通模式
* 在普通模式下可用 `:q` 关闭该终端窗口

### 7.2 专用终端（make / ./a.out）

> 这两个按键是为了 C 项目习惯做的预设，你可以以后按需要再扩展。

* `<leader>tm` — 在专用终端里执行 `make`
* `<leader>tr` — 在专用终端里执行 `./a.out`

> 如果当前目录没有 `Makefile` 或 `./a.out`，命令会报错，但不会影响 Neovim。

---

## 📎 8. Windows 剪贴板同步（WSL 场景）

> 场景：在 WSL 的 Neovim 里编辑文件，希望复制到 **Windows 系统剪贴板**。

自定义按键：

* `<leader>y`（普通模式）— 复制 **全文** 到 Windows 剪贴板
* 选中一段文本后 `<leader>y`（可视模式）— 复制选中内容到 Windows 剪贴板
* `<leader>yy` — 复制 **上一条终端命令 + 完整输出** 到 Windows 剪贴板（依赖 OSC 133 / `:terminal` 或 toggleterm）

内部实现：

* 实际命令为：`iconv -f utf-8 -t utf-16le | /mnt/c/Windows/System32/clip.exe`
* 复制成功 / 失败会通过 `vim.notify` 提示：

  * `✔ 已复制到 Windows 剪贴板`
  * `✘ 复制失败：...`

---

## 🧱 9. 常用编辑操作（Neovim 默认行为）

> 以下为 Neovim/Vim 的基础操作，与本配置无关，但列在这里方便查阅。

### 9.1 文本编辑

* `yy` — 复制当前行
* `dd` — 删除当前行
* `p` — 在光标后粘贴
* `P` — 在光标前粘贴
* `u` — 撤销
* `<C-r>` — 重做

### 9.2 缩进与自动格式

* `>>` — 当前行向右缩进
* `<<` — 当前行向左缩进
* `=` + motion — 根据语法自动缩进（例如 `=%`、`=G`）

---

## 📁 10. 文件 / Buffer / 退出

### 10.1 保存与退出

* `:w` — 保存当前文件
* `:q` — 退出当前窗口
* `:wq` — 保存并退出
* `:q!` — 不保存强制退出

### 10.2 Buffer 管理

* `:ls` — 列出所有 buffer
* `:bnext` / `:bn` — 下一个 buffer
* `:bprevious` / `:bp` — 上一个 buffer
* `:bd` — 关闭当前 buffer

---

## 📚 11. 打开本说明文档

在 `core/keymaps.lua` 中已有映射：

* `<leader>km` — 打开 `~/.config/nvim/docs/keymaps.md`

随时忘了快捷键，就：

```text
空格 + k + m
```

打开本文件查看即可。

* `:wq` — 保存并退出
* `:q!` — 不保存强制退出

### 10.2 Buffer 管理

* `:ls` — 列出所有 buffer# 📝 Neovim 快捷键说明文档（完整版）

> 文件路径：`~/.config/nvim/docs/keymaps.md`
> 约定：`<leader>` = 空格键（Space）

---

## 📦 1. 基础移动与窗口 / 分屏

### 1.1 基础移动

* `h` / `j` / `k` / `l` — 左 / 下 / 上 / 右 移动
* `gg` — 跳到文件开头
* `G` — 跳到文件末尾
* `0` — 跳到行首
* `$` — 跳到行尾

### 1.2 分屏（Split）

> Neovim 自带分屏功能，不需要插件。

命令：

* `:vsplit` / `:vsp` — 垂直分屏（左右分屏）
* `:split` / `:sp` — 水平分屏（上下分屏）

窗口切换（`Ctrl-w` 开头）：

* `<C-w> h` — 切到左边窗口
* `<C-w> l` — 切到右边窗口
* `<C-w> j` — 切到下方窗口
* `<C-w> k` — 切到上方窗口
* `<C-w> w` — 在所有窗口之间轮流切换

窗口大小：

* `<C-w> =` — 所有窗口等宽等高
* `<C-w> +` / `-` — 调整当前窗口高度
* `<C-w> >` / `<` — 调整当前窗口宽度

关闭当前窗口：

* `:q` 或 `:close`

---

## 🗂 2. 标签页（Tab）管理

> 可以理解为“tmux 的 window”：每个标签页里可以有自己的一套分屏布局。

自定义快捷键（在 `core/keymaps.lua` 中定义）：

* `<leader>tc` — 新建标签页（tab create）
* `<leader>tq` — 关闭当前标签页（tab close）
* `<leader>to` — 只保留当前标签页，关闭其他所有标签页
* `<leader>tn` — 切换到下一个标签页（tab next）
* `<leader>tp` — 切换到上一个标签页（tab prev）

内置命令：

* `:tabnew` / `:tabe {file}` — 新建标签页
* `:tabnext` / `:tabn` — 下一个标签页
* `:tabprevious` / `:tabp` — 上一个标签页
* `:tabclose` — 关闭当前标签页
* `:tabonly` — 只保留当前标签页
* `gt` / `gT` — 在标签页之间前后切换

> 提示：如果在 `core/options.lua` 里设置 `vim.o.showtabline = 2`，顶部会一直显示标签栏。

---

## 📘 3. LSP 快捷键（clangd / pyright / gopls / tsserver 等）

> 前提：对应语言的 LSP 已开启（在 `lua/plugins/lsp.lua` 里配置）。

### 3.1 跳转 / 查找

* `gd` — 跳转到定义（Go to Definition）
* `gD` — 跳转到声明（Go to Declaration）
* `gi` — 跳转到实现（Go to Implementation）
* `gr` — 查找引用（References）
* `<C-o>` — 返回上一个位置（跳转后退）
* `<C-i>` — 跳转前进

### 3.2 文档 / 重命名 / 格式化

* `K` — 悬浮文档（Hover，查看函数/变量说明）
* `<leader>rn` — 重命名符号（Rename symbol）
* `<leader>ca` — Code Action（快速修复 / 导入 / 重构）
* `<leader>lf` — **LSP 格式化当前文件**（LSP Format）

> 说明：`<leader>lf` 中的 `l` 代表 LSP，避免和 `<leader>f` 系列“查找 / 搜索”前缀冲突。

---

## ⚠️ 4. 诊断（Diagnostics：错误 / 警告）

* `]d` — 跳到下一条诊断信息（错误 / 警告）
* `[d` — 跳到上一条诊断信息
* `<leader>de` — 弹出当前行的诊断浮窗（diagnostic float）

---

## 📂 5. 文件目录树（NvimTree）

> 插件：`nvim-tree.lua`

### 5.1 打开 / 关闭

* `<leader>e` — 打开 / 关闭 左侧文件树

### 5.2 NvimTree 内常用操作（默认键位）

> 仅在 NvimTree 窗口里生效。

* `<CR>` 或 `l` — 打开文件 / 展开目录
* `h` — 关闭目录（折叠）
* `a` — 新建文件 / 目录
* `r` — 重命名
* `d` — 删除
* `c` — 复制
* `p` — 粘贴
* `y` — 复制名称 / 路径（带提示菜单）

> 这些是插件的默认键位，你可以通过 `:help nvim-tree-default-mappings` 查看完整列表。

---

## 🔍 6. 搜索与跳转（Telescope）

> 插件：`telescope.nvim`，依赖 `ripgrep (rg)`。

### 6.1 文件与帮助搜索

* `<leader>ff` — 搜索文件（从当前 `:pwd` 开始递归）
* `<leader>fb` — 搜索已打开的 buffer
* `<leader>fh` — 搜索 Neovim 帮助文档（help tags）

### 6.2 文本搜索（正则 / 全局 / 指定目录）

* `<leader>fg` — 全局搜索文本（正则），从当前 `:pwd` 开始递归
* `<leader>fs` — 在“指定目录”中搜索文本（正则）：

  * 按 `<leader>fs` 后，命令行会提示 `Search in dir:`
  * 默认值是当前文件所在目录，可以直接回车，或者改成 `src/`、`include/` 等路径
  * 只会在这个目录（及其子目录）里搜索

### 6.3 当前文件内搜索

* `<leader>/` — **当前文件内搜索**（current buffer fuzzy find）

  * 只在当前 buffer 内模糊搜索行内容
  * 类似 VSCode “在当前文件里搜索 / 快速跳转”

> 提示：`ff / fg / fs` 都是递归扫描子目录；`<leader>/` 只在当前文件内部，不会跨文件。

---

## 🧾 7. 终端（toggleterm.nvim）

> 插件：`toggleterm.nvim`，用于在 Neovim 里快捷打开终端执行命令。

### 7.1 基础终端

* `<leader>tt` — 切换水平终端（打开 / 关闭）

  * 默认在底部打开一个终端窗口
  * 再按一次 `<leader>tt` 会隐藏 / 显示

终端内常用：

* `Esc` / `<C-\><C-n>` — 从终端插入模式回到普通模式
* 在普通模式下可用 `:q` 关闭该终端窗口

### 7.2 专用终端（make / ./a.out）

> 这两个按键是为了 C 项目习惯做的预设，你可以以后按需要再扩展。

* `<leader>tm` — 在专用终端里执行 `make`
* `<leader>tr` — 在专用终端里执行 `./a.out`

> 如果当前目录没有 `Makefile` 或 `./a.out`，命令会报错，但不会影响 Neovim。

---

## 📎 8. Windows 剪贴板同步（WSL 场景）

> 场景：在 WSL 的 Neovim 里编辑文件，希望复制到 **Windows 系统剪贴板**。

自定义按键：

* `<leader>y`（普通模式）— 复制 **全文** 到 Windows 剪贴板
* 选中一段文本后 `<leader>y`（可视模式）— 复制选中内容到 Windows 剪贴板
* `<leader>yy` — 复制 **上一条终端命令 + 完整输出** 到 Windows 剪贴板（依赖 OSC 133 / `:terminal` 或 toggleterm）

内部实现：

* 实际命令为：`iconv -f utf-8 -t utf-16le | /mnt/c/Windows/System32/clip.exe`
* 复制成功 / 失败会通过 `vim.notify` 提示：

  * `✔ 已复制到 Windows 剪贴板`
  * `✘ 复制失败：...`

---

## 🧱 9. 常用编辑操作（Neovim 默认行为）

> 以下为 Neovim/Vim 的基础操作，与本配置无关，但列在这里方便查阅。

### 9.1 文本编辑

* `yy` — 复制当前行
* `dd` — 删除当前行
* `p` — 在光标后粘贴
* `P` — 在光标前粘贴
* `u` — 撤销
* `<C-r>` — 重做

### 9.2 缩进与自动格式

* `>>` — 当前行向右缩进
* `<<` — 当前行向左缩进
* `=` + motion — 根据语法自动缩进（例如 `=%`、`=G`）

---

## 📁 10. 文件 / Buffer / 退出

### 10.1 保存与退出

* `:w` — 保存当前文件
* `:q` — 退出当前窗口
* `:wq` — 保存并退出
* `:q!` — 不保存强制退出

### 10.2 Buffer 管理

* `:ls` — 列出所有 buffer
* `:bnext` / `:bn` — 下一个 buffer
* `:bprevious` / `:bp` — 上一个 buffer
* `:bd` — 关闭当前 buffer

---

## 📚 11. 打开本说明文档

在 `core/keymaps.lua` 中已有映射：

* `<leader>km` — 打开 `~/.config/nvim/docs/keymaps.md`

随时忘了快捷键，就：

```text
空格 + k + m
```

打开本文件查看即可。

* `:bnext` / `:bn` — 下一个 buffer
* `:bprevious` / `:bp` — 上一个 buffer
* `:bd` — 关闭当前 buffer

---

## 📚 11. 打开本说明文档

在 `core/keymaps.lua` 中已有映射：

* `<leader>km` — 打开 `~/.config/nvim/docs/keymaps.md`

随时忘了快捷键，就：

```text
空格 + k + m
```

打开本文件查看即可。


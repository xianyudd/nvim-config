-- lua/plugins/lsp.lua
-- 多语言 LSP 统一配置（使用 Neovim 0.11 推荐的 vim.lsp.config / vim.lsp.enable）
-- 目标：
--   - 所有语言共用一套 capabilities（配合 nvim-cmp）
--   - 每种语言一个简洁的 config，集中管理，方便扩展
--   - 不再使用 require("lspconfig")[server].setup 旧框架，避免 deprecation 警告

return {
  "neovim/nvim-lspconfig",

  config = function()
    --------------------------------------------------------------------------
    -- 1. 前置依赖：nvim-cmp 的 capabilities
    --------------------------------------------------------------------------
    local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if not ok_cmp then
      vim.notify("[lsp] cmp_nvim_lsp 未安装，LSP 补全能力将使用默认值", vim.log.levels.WARN)
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if ok_cmp then
      capabilities = cmp_lsp.default_capabilities(capabilities)
    end

    --------------------------------------------------------------------------
    -- 2. 统一的注册函数：用 vim.lsp.config + vim.lsp.enable
    --    - server_name: "clangd" / "pyright" / "gopls" / "tsserver" / "rust_analyzer"
    --    - opts:        对应 server 的配置项（cmd / filetypes / settings 等）
    --------------------------------------------------------------------------
    local function configure_server(server_name, opts)
      opts = opts or {}

      -- 合并 capabilities（以 cmp 能力为主）
      opts.capabilities = vim.tbl_deep_extend(
        "force",
        capabilities,
        opts.capabilities or {}
      )

      -- 如果显式指定了 cmd[1]，帮你检测本机是否存在该可执行
      if opts.cmd and opts.cmd[1] then
        local cmd_name = opts.cmd[1]
        if vim.fn.executable(cmd_name) ~= 1 then
          vim.notify(
            string.format("[lsp] 可执行文件 '%s' 未找到，跳过 LSP '%s'", cmd_name, server_name),
            vim.log.levels.WARN
          )
          return
        end
      end

      -- 新 API：注册配置
      vim.lsp.config(server_name, opts)
      -- 新 API：启用该 LSP（之后在对应 filetype buffer 中会自动 attach）
      vim.lsp.enable(server_name)
    end

    --------------------------------------------------------------------------
    -- 3. 各语言 LSP 配置（按需启用）
    --------------------------------------------------------------------------

    -- 3.1 C / C++：clangd
    configure_server("clangd", {
      cmd = { "clangd" },  -- 你已经安装好的 clangd 18.x
      filetypes = { "c", "cpp", "objc", "objcpp" },
      -- 你也可以按需添加参数，例如：
      -- cmd = { "clangd", "--header-insertion=never", "--function-arg-placeholders=1" },
    })

    -- 3.2 Python：pyright
    -- 安装方式（任选一条）：
    --   npm i -g pyright
    --   或 pip install pyright
    configure_server("pyright", {
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      -- settings = {
      --   python = {
      --     analysis = {
      --       typeCheckingMode = "basic",
      --     },
      --   },
      -- },
    })

    -- 3.3 Go：gopls
    -- 安装：go install golang.org/x/tools/gopls@latest
    configure_server("gopls", {
      cmd = { "gopls" },
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
      -- settings = {
      --   gopls = {
      --     gofumpt = true,
      --   },
      -- },
    })

    -- 3.4 JavaScript / TypeScript：tsserver
    -- 建议使用 typescript-language-server + typescript
    -- 安装：npm i -g typescript typescript-language-server
    configure_server("tsserver", {
      cmd = { "typescript-language-server", "--stdio" },
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
    })

    -- 3.5 Rust：rust_analyzer（预留，将来你想玩再装）
    -- 安装：rustup component add rust-analyzer 或单独下载
    configure_server("rust_analyzer", {
      cmd = { "rust-analyzer" },
      filetypes = { "rust" },
      -- settings = {
      --   ["rust-analyzer"] = {
      --     cargo = { allFeatures = true },
      --     checkOnSave = { command = "clippy" },
      --   },
      -- },
    })

    --------------------------------------------------------------------------
    -- 4. 键位说明
    --
    --   LSP 相关的快捷键还是走你的 core/keymaps.lua：
    --     gd / gD / gi / gr / K / <leader>rn / <leader>ca / <leader>f / [d / ]d ...
    --
    --   这里就不重复写 on_attach，只使用 vim.lsp.buf.* 通用 API。
    --------------------------------------------------------------------------
  end,
}


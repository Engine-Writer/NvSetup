require("nvchad.configs.lspconfig").defaults()

local servers = {
    "html",
    "cssls",

    "clangd",        -- C / C++
    "pyright",       -- Python
    "ts_ls",         -- JavaScript / TypeScript
    "jsonls",        -- JSON
    "yamlls",        -- YAML
    "taplo",         -- TOML
    "gopls",         -- Go
    "rust_analyzer", -- Rust
    "zls",           -- Zig
    "jdtls",         -- Java
    "omnisharp",     -- C#
    "glsl_analyzer", -- GLSL
    "slang_server",  -- SLang
    "asm_lsp",       -- ASM (NASM my beloved)
    "lua_ls",        -- Lua
}
vim.lsp.enable(servers)

vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=none", -- no .clang-format => clangd does not format
        -- (whoever made LLVM the default here owes me my time back)
    },
    -- clangd wants one merged "cpp" filetype request
    capabilities = (function()
        local caps = require("cmp_nvim_lsp").default_capabilities()
        caps.textDocument.completion.completionItem.snippetSupport = true
        caps.offsetEncoding = { "utf-16" }
        return caps
    end)(),
    -- clangd must never format (cuz clang-format): strip the capability so
    -- nothing (gq, LSP format keymaps, conform fallback) can ask it to.
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        client.server_capabilities.documentOnTypeFormattingProvider = nil
        require("nvchad.configs.lspconfig").on_attach(client, bufnr)
    end,
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
})

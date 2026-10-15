local options = {
    formatters_by_ft = {
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        -- css = { "prettier" },
        -- html = { "prettier" },
    },

    formatters = {
        -- only run clang-format when a .clang-format/_clang-format exists
        -- somewhere above the file; otherwise it would fall back to LLVM style.
        ["clang-format"] = {
            condition = function(_, ctx)
                return vim.fs.find({ ".clang-format", "_clang-format" }, {
                    path = ctx.filename,
                    upward = true,
                })[1] ~= nil
            end,
        },
    },


    format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ft == "cuda" then
            local found = vim.fs.find({ ".clang-format", "_clang-format" }, {
                path = vim.api.nvim_buf_get_name(bufnr),
                upward = true,
            })[1]
            if not found then
                return nil
            end
            return { timeout_ms = 500, lsp_format = "never" }
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
    end,
}

return options

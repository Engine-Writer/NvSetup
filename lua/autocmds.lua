require "nvchad.autocmds"

vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.bo.tabstop = 4
        vim.bo.shiftwidth = 4
        vim.bo.softtabstop = 4
        vim.bo.expandtab = false
    end,
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local arg = vim.fn.argv(0)
        if type(arg) == "string" and arg ~= "" and vim.fn.isdirectory(arg) == 1 then
            vim.cmd "NvimTreeFocus"
        end
    end,
})


-- TOOL TO NOT FIGHT NVIM TRYNA `:q`
local function in_tabufline()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.bo[buf].buflisted then
        return false
    end
    if vim.bo[buf].buftype ~= "" then
        return false
    end -- excludes terminal, help, quickfix
    for _, b in ipairs(vim.t.bufs or {}) do
        if b == buf then
            return true
        end
    end
    return false
end

local function smart_quit(real_cmd)
    return function(opts)
        if in_tabufline() and #(vim.t.bufs or {}) > 1 then
            if opts.write then
                vim.cmd "write"
            end
            require("nvchad.tabufline").close_buffer()
        else
            vim.cmd(real_cmd .. (opts.bang and "!" or ""))
        end
    end
end

vim.api.nvim_create_user_command("Qq", function(o)
    smart_quit "quit" { bang = o.bang, write = false }
end, { bang = true, desc = "Smart quit" })

vim.api.nvim_create_user_command("Qwq", function(o)
    smart_quit "wq" { bang = o.bang, write = true }
end, { bang = true, desc = "Smart write-quit" })

vim.api.nvim_create_user_command("Qx", function(o)
    smart_quit "xit" { bang = o.bang, write = true }
end, { bang = true, desc = "Smart write-quit if modified" })

local function abbrev(from, to)
    vim.cmd(
        string.format(
            [[cnoreabbrev <expr> %s (getcmdtype() == ':' && getcmdline() ==# '%s') ? '%s' : '%s']],
            from,
            from,
            to,
            from
        )
    )
end

abbrev("q", "Qq")
abbrev("wq", "Qwq")
abbrev("x", "Qx")

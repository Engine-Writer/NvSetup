require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Eww imaging using <C-s> to save like a baby
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>") -- NO MORE!

-- nice numered TogTerm
map("n", "<leader>tt", function()
  require("toggleterm").toggle(vim.v.count1)
end, { desc = "terminal toggle numbered term (count-prefixed, default 1)" })

-- code runner in first term so you can js `yy` `""<leader>tr`
map("n", "<leader>tr", function()
  local reg = vim.v.register
  local cmd = vim.fn.getreg(reg)
  if cmd == nil or cmd == "" then
    vim.notify('register "' .. reg .. '" is empty', vim.log.levels.WARN)
    return
  end
  require("toggleterm").exec(cmd, 1)
end, { desc = 'terminal exec register contents (default unnamed, "+ for clipboard)' })

-- Floating terminal
map("n", "<leader>tf", function()
  local id = vim.v.count > 0 and vim.v.count or 99
  require("toggleterm").toggle(id, nil, nil, "float")
end, { desc = "terminal toggle floating term (count-prefixed, default 99)" })

-- Ctrl+g = close whichever terminal youre in. vim.b.toggle_number is the id
local function close_active_term()
  local id = vim.b.toggle_number
  if not id then
    return
  end
  local term = require("toggleterm.terminal").get(id)
  if term then
    term:toggle()
  end
end

local function close_active_term_but_better()
  local ttTerms = require "toggleterm.terminal"
  local bufnr = vim.api.nvim_get_current_buf()
  for _, t in ipairs(ttTerms.get_all(true)) do
    if t.bufnr == bufnr then
      t:close()
      return
    end
  end

  local nvTerms = vim.g.nvchad_terms or {}
  local nvOpts = nvTerms[tostring(bufnr)]
  if nvOpts then
    require("nvchad.term").toggle { pos = nvOpts.pos, id = tostring(bufnr) }
    return
  end

  vim.cmd "hide"
end

map("t", "<C-g>", close_active_term_but_better, { desc = "terminal close active" })
map("n", "<C-g>", close_active_term_but_better, { desc = "terminal close active" })

-- vim-illuminate
map("n", "]r", function()
  require("illuminate").goto_next_reference(true)
end, { desc = "illuminate jump to next reference" })

map("n", "[r", function()
  require("illuminate").goto_prev_reference(true)
end, { desc = "illuminate jump to prev reference" })

map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "new empty scratch buffer" })
map("n", "<leader>gn", "<cmd>enew<cr>", { desc = "new empty scratch buffer" })

-- gt/gT natively switch tab PAGES, EWW.
-- Point them at tabufline so they match what's actually on screen.
map("n", "gt", function()
  require("nvchad.tabufline").next()
end, { desc = "Next buffer" })

map("n", "gT", function()
  require("nvchad.tabufline").prev()
end, { desc = "Prev buffer" })

-- Close the current buffer in the tabufline bar
map("n", "<leader>bq", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close buffer" })

map("n", "<leader>gq", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close buffer" })

-- and markdown for readmes
vim.keymap.set("n", "<leader>md", "<cmd>RenderMarkdown toggle<cr>", {
  desc = "Toggle markdown render",
})

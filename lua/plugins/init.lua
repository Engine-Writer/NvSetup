return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false, -- don't depend on NvChad's own spec supplying a trigger
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      git = {
        ignore = false,
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function()
      return require "configs.cmp"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- C / C++
        "clangd",
        "clang-format",
        -- Python
        "pyright",
        -- JavaScript / TypeScript
        "typescript-language-server",
        -- JSON / YAML / TOML
        "json-lsp",
        "yaml-language-server",
        "taplo",
        -- Go
        "gopls",
        -- Rust
        "rust-analyzer",
        -- Zig (NOTE: needs a zig compiler on PATH btw)
        "zls",
        -- Java (NOTE: needs a JDK on PATH)
        "jdtls",
        -- C# -- omnisharp, not csharp-language-server: that package's
        -- upstream NuGet publish is broken :skull: (see configs/lspconfig.lua),
        "omnisharp",
        -- GLSL / SLang. No maintained HLSL LSP exists in Mason's registry
        -- as of this setup (F*CK)
        "glsl_analyzer",
        "slang-server",
        -- ASM (x86/x86_64/ARM/RISC-V)
        "asm-lsp",
        "intelephense", -- shh
        -- Lua
        "lua-language-server",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    -- must load before FileType fires on the first buffer, since its
    -- config() registers the autocmd that starts the parser; being pulled
    -- in late as another plugin's dependency (on BufReadPost) is too late
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- NOTE: on the main branch, ensure_installed is no longer a setup()
      -- table option — it's just read here as a plain list for US to pass
      -- to require("nvim-treesitter").install() and to build the FileType
      -- autocmd pattern below. The old all-in-one setup({ensure_installed=..})
      -- call silently did nothing on main; parsers never actually installed.
      ensure_installed = {
        "vim",
        "vimdoc",
        "lua",
        "c",
        "cpp",
        "cmake",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
        "toml",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "rust",
        "zig",
        "java",
        "c_sharp",
        "glsl",
        "hlsl",
        "asm",
        "php",
        "html",
        "css",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").install(opts.ensure_installed)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = opts.ensure_installed,
        callback = function(args)
          vim.treesitter.start(args.buf)
        end,
      })
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "ahmedkhalf/project.nvim",
    -- <leader>pp collided with NvChad's built-in <leader>pt Telescope
    -- mapping
    keys = {
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Switch project" },
    },
    config = function()
      require("project_nvim").setup {
        detection_methods = { "pattern" },
        patterns = { ".git", "Makefile", "CMakeLists.txt", "*.pro", "*.sln" },
      }
    end,
  },

  -- OLD: project-wide find & replace with a live preview.
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>sr",
        function()
          require("spectre").open()
        end,
        desc = "Replace in files",
      },
      {
        "<leader>sw",
        function()
          require("spectre").open_visual { select_word = true }
        end,
        desc = "Replace word under cursor",
      },
    },
  },

  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = function()
      -- pull colors from the active NvChad theme so it follows theme switches
      local c = require("base46").get_theme_tb "base_30"

      -- Dim/desaturate the editor behind a float with a full-screen backdrop
      local backdrop_buf, backdrop_win
      local function open_backdrop()
        if backdrop_win and vim.api.nvim_win_is_valid(backdrop_win) then
          return
        end
        backdrop_buf = vim.api.nvim_create_buf(false, true)
        backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
          relative = "editor",
          row = 0,
          col = 0,
          width = vim.o.columns,
          height = vim.o.lines,
          style = "minimal",
          focusable = false,
          zindex = 40, -- below the float (toggleterm floats use 50)
        })
        vim.api.nvim_set_hl(0, "TermBackdrop", { bg = "#000000" })
        vim.wo[backdrop_win].winhighlight = "Normal:TermBackdrop"
        vim.wo[backdrop_win].winblend = 40 -- higher = see more of the editor
      end
      local function close_backdrop()
        if backdrop_win and vim.api.nvim_win_is_valid(backdrop_win) then
          vim.api.nvim_win_close(backdrop_win, true)
        end
        if backdrop_buf and vim.api.nvim_buf_is_valid(backdrop_buf) then
          vim.api.nvim_buf_delete(backdrop_buf, { force = true })
        end
        backdrop_win, backdrop_buf = nil, nil
      end

      return {
        float_opts = {
          border = "curved",
          winblend = 0,
        },
        highlights = {
          -- terminal area inside the float: darker than the editor
          NormalFloat = { guibg = c.darker_black },
          FloatBorder = { guifg = c.grey_fg, guibg = c.darker_black },
        },
        on_open = function(term)
          if term.direction == "float" then
            open_backdrop()
          end
        end,
        on_close = function(term)
          if term.direction == "float" then
            close_backdrop()
          end
        end,
      }
    end,
    -- OLD, Commented out cuz interferes with <C-\><C-n>
    -- keys = { "<C-\\>" },
    -- opts = { open_mapping = [[<C-\>]] },
  },

  -- Highlights every other occurrence of the identifier under the cursor
  {
    "RRethy/vim-illuminate",
    event = "User FilePost",
    config = function()
      require("illuminate").configure {
        delay = 150,
        filetypes_denylist = { "NvimTree", "lazy", "mason", "help" },
      }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      -- the plugin's own built-in default mappings would otherwise fight
      -- with the custom ones set up below
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
          selection_modes = {
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
          },
        },
        move = {
          set_jumps = true,
        },
      }

      local select = require "nvim-treesitter-textobjects.select"
      local move = require "nvim-treesitter-textobjects.move"

      local textobjects = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      }
      for map, query in pairs(textobjects) do
        vim.keymap.set({ "x", "o" }, map, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      vim.keymap.set({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function start" })
      vim.keymap.set({ "n", "x", "o" }, "]c", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next class start" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Previous function start" })
      vim.keymap.set({ "n", "x", "o" }, "[c", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Previous class start" })
    end,
  },

  -- fun stuff
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = "markdown",
    opts = {},
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      image = { enabled = true },
      git = { enabled = true },
    },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info", alt = { "todo" } },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      highlight = {
        multiline = true,
        before = "",
        keyword = "wide",
        pattern = {
          [[.*<(KEYWORDS)\s*:]],
          [[.*@(KEYWORDS)\b]],
        },
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[(?i)\b(KEYWORDS):|@(KEYWORDS)\b]],
      },
    },
  },
  {
    "J-Cowsert/classlayout.nvim",
    ft = { "c", "cpp" },
    opts = {},
  },
}

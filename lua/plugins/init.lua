return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
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
        "intelephense",
        -- Lua
        "lua-language-server",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    opts = {
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
      local backdrop_win
      local function open_backdrop()
        if backdrop_win and vim.api.nvim_win_is_valid(backdrop_win) then
          return
        end
        local buf = vim.api.nvim_create_buf(false, true)
        backdrop_win = vim.api.nvim_open_win(buf, false, {
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
        backdrop_win = nil
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
    branch = "master",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter.configs").setup {
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
        },
      }
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
}

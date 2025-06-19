local function load_env_file(path)
  local file = io.open(path, "r")
  if not file then
    return
  end

  for line in file:lines() do
    local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
    if key and value then
      vim.fn.setenv(key, value)
    end
  end

  file:close()
end

-- edit this config by calling user command `:e $MYVIMRC`
vim.env.MYVIMRC = vim.fn.stdpath("config") .. "/init.lua"
load_env_file(vim.fn.stdpath("config") .. "/.env")

-- [[ Setting options ]]
-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- Allow editorconfig
vim.g.editorconfig = true

-- Make line numbers default
vim.opt.number = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- enable conceal (e.g. for obsidian.nvim)
vim.opt.conceallevel = 2

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ lazy.nvim ]]
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ lazy.nvim => Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
require("lazy").setup({
  spec = {
    -- Detect tabstop and shiftwidth automatically
    "tpope/vim-sleuth",

    -- Adds git related signs to the gutter, as well as utilities for managing changes
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      },
    },

    -- Useful plugin to show you pending keybinds.
    {
      "folke/which-key.nvim",
      event = "VimEnter", -- Sets the loading event to 'VimEnter'
      opts = {
        -- delay between pressing a key and opening which-key (milliseconds)
        -- this setting is independent of vim.opt.timeoutlen
        delay = 0,
        icons = {
          -- set icon mappings to true if you have a Nerd Font
          mappings = vim.g.have_nerd_font,
          -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
          -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
          keys = vim.g.have_nerd_font and {} or {
            Up = "<Up> ",
            Down = "<Down> ",
            Left = "<Left> ",
            Right = "<Right> ",
            C = "<C-…> ",
            M = "<M-…> ",
            D = "<D-…> ",
            S = "<S-…> ",
            CR = "<CR> ",
            Esc = "<Esc> ",
            ScrollWheelDown = "<ScrollWheelDown> ",
            ScrollWheelUp = "<ScrollWheelUp> ",
            NL = "<NL> ",
            BS = "<BS> ",
            Space = "<Space> ",
            Tab = "<Tab> ",
            F1 = "<F1>",
            F2 = "<F2>",
            F3 = "<F3>",
            F4 = "<F4>",
            F5 = "<F5>",
            F6 = "<F6>",
            F7 = "<F7>",
            F8 = "<F8>",
            F9 = "<F9>",
            F10 = "<F10>",
            F11 = "<F11>",
            F12 = "<F12>",
          },
        },

        -- Document existing key chains
        spec = {
          { "<leader>c", group = "[C]ode",     mode = { "n", "x" } },
          { "<leader>d", group = "[D]ocument" },
          { "<leader>r", group = "[R]ename" },
          { "<leader>s", group = "[S]earch" },
          { "<leader>w", group = "[W]orkspace" },
          { "<leader>t", group = "[T]oggle" },
          { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        },
      },
    },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        { "j-hui/fidget.nvim", opts = {} },
        {
          "saghen/blink.cmp",
          -- optional: provides snippets for the snippet source
          dependencies = { "rafamadriz/friendly-snippets" },

          -- use a release tag to download pre-built binaries
          version = "1.*",
          -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
          -- build = 'cargo build --release',
          -- If you use nix, you can build from source using latest nightly rust with:
          -- build = 'nix run .#build-plugin',

          ---@module 'blink.cmp'
          ---@type blink.cmp.Config
          opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            keymap = { preset = "default" },

            appearance = {
              nerd_font_variant = "mono",
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = { documentation = { auto_show = true } },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
              default = { "lsp", "path", "snippets", "buffer" },
            },

            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
            -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" },
          },
          opts_extend = { "sources.default" },
        },
        {
          'stevearc/conform.nvim',
          event = { 'BufWritePre' },
          cmd = { 'ConformInfo' },
          opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
              -- Disable "format_on_save lsp_fallback" for languages that don't
              -- have a well standardized coding style. You can add additional
              -- languages here or re-enable it for the disabled ones.
              local disable_filetypes = { c = true, cpp = true }
              if disable_filetypes[vim.bo[bufnr].filetype] then
                return nil
              else
                return {
                  timeout_ms = 500,
                  lsp_format = 'fallback',
                }
              end
            end,
            formatters_by_ft = {
              -- lua = { 'stylua' },
              -- Conform can also run multiple formatters sequentially
              -- python = { "isort", "black" },
              --
              -- You can use 'stop_after_first' to run the first available formatter from the list
              -- javascript = { "prettierd", "prettier", stop_after_first = true },
            },
          },
          keys = {
            {
              '<leader>lf',
              function()
                require('conform').format { async = true, lsp_format = 'fallback' }
              end,
              mode = '',
              desc = '([L]SP) [F]ormat buffer',
            },
          },
        }
      },
      config = function()
        local capabilities = require("blink.cmp").get_lsp_capabilities()
        local lspconfig = require("lspconfig")
        -- I am gonna do it "manually" first
        lspconfig["solargraph"].setup({ capabilities = capabilities })
        lspconfig["lua_ls"].setup({ capabilities = capabilities })
      end,
    },
    -- init.lua:
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      end
    },
    {
      "webhooked/kanso.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd.colorscheme("kanso-ink")
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      branch = 'master',
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require 'nvim-treesitter.configs'.setup {
          -- A list of parser names, or "all" (the listed parsers MUST always be installed)
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "ruby", "editorconfig" },

          -- Install parsers synchronously (only applied to `ensure_installed`)
          sync_install = false,

          -- Automatically install missing parsers when entering buffer
          -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
          auto_install = false,
          highlight = {
            enable = true,

            -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
            -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
            -- the name of the parser)
            -- list of language that will be disabled
            -- disable = { "c", "rust" },
            -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
            disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` when you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = { "ruby" }
          },
        }
      end
    },
    {
      "epwalsh/obsidian.nvim",
      version = "*", -- recommended, use latest release instead of latest commit
      lazy = true,
      event = {
        -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
        -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
        -- refer to `:h file-pattern` for more examples
        "BufReadPre " .. vim.fn.expand(vim.env.OBSIDIAN_PERSONAL_NOTES_DIR) .. "*.md",
        "BufNewFile " .. vim.fn.expand(vim.env.OBSIDIAN_PERSONAL_NOTES_DIR) .. "*.md",
      },
      dependencies = {
        -- Required.
        "nvim-lua/plenary.nvim",
      },
      opts = {
        ui = { enable = false },
        workspaces = {
          {
            name = "main",
            path = vim.fn.expand(vim.env.OBSIDIAN_PERSONAL_NOTES_DIR)
          },
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
      opts = {},
    }
  },
  checker = { enabled = true },
})

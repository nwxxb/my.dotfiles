-- [[ Globals ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- [[ Setting options ]]
-- see :help vim.o

-- make line numbers as default
vim.o.number = true
-- show relative numbers
-- vim.o.relativenumber = true

-- disable line wrapping
-- vim.o.wrap = false

-- enable break indent
vim.o.breakindent = true

-- enable mouse mode
vim.o.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Adjust the width of the tab character.
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- Show which line your cursor is on
vim.o.cursorline = false

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- folding
-- utilize treesitter to handle folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- show folding column beside line number
vim.o.foldcolumn = "1"
-- don't show folding column beside line number
-- vim.o.foldtext = ""
-- open all fold, but still get the nice "open & close" fold feature
vim.o.foldlevel = 99
-- but close fold below 3 level
vim.o.foldlevelstart = 4

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- [[ Diagnostic Config ]]
-- See :help vim.diagnostic.Opts
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = { min = vim.diagnostic.severity.HINT } },
	-- Can switch between these as you prefer
	virtual_text = true, -- Text shows up at the end of the line
	virtual_lines = false, -- Text shows up underneath the line, with virtual lines

	-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
	jump = {
		on_jump = function()
			vim.diagnostic.open_float({ focus = false })
		end,
	},
})

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open Diagnostic [Q]uickfix list" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking/copying text",
	group = vim.api.nvim_create_augroup("main-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ Add some plugins ]]
vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.nvim", version = "main" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	-- mini.snippets use this internally
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},
	{ src = "https://github.com/webhooked/kanso.nvim" },
})

-- [[ Plugins Configuration ]]
-- there is also extras in the kanso.nvim repo
vim.cmd.colorscheme("kanso-zen")

require("fidget").setup()

require("mini.misc").setup()
-- to avoid doubling the quotes after word (e.g. foo"")
-- I have to add custom config below
require("mini.pairs").setup({
	mappings = {
		['"'] = { action = "closeopen", pair = '""', neigh_pattern = "^[^%a\\]", register = { cr = false } },
		["'"] = { action = "closeopen", pair = "''", neigh_pattern = "^[^%a\\]", register = { cr = false } },
		["`"] = { action = "closeopen", pair = "``", neigh_pattern = "^[^%a\\]", register = { cr = false } },
	},
})

require("mini.indentscope").setup()
require("mini.pick").setup()
vim.keymap.set("n", "<leader>pb", "<cmd>Pick buffers<cr>", { desc = "[P]ick [B]uffers" })
vim.keymap.set("n", "<leader>pf", "<cmd>Pick files<cr>", { desc = "[P]ick [F]iles" })
vim.keymap.set("n", "<leader>pg", "<cmd>Pick grep_live<cr>", { desc = "[P]ick [G]rep" })
vim.keymap.set("n", "<leader>ph", "<cmd>Pick help<cr>", { desc = "[P]ick [H]elp" })
vim.keymap.set("n", "<leader>p", "<cmd>Pick resume<cr>", { desc = "[P]ick Resume" })

require("mini.diff").setup()

require("mini.snippets").setup({
	snippets = { require("mini.snippets").gen_loader.from_lang() },
})
MiniSnippets.start_lsp_server()

require("mini.completion").setup({
	lsp_completion = {
		source_func = "omnifunc",
		auto_setup = false,
	},
})

local root_names = { ".git", "Makefile", "Gemfile.lock", "yarn.lock", "package-lock.json" }
MiniMisc.setup_auto_root(root_names)

-- [[ LSP Configuration ]]
vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
			telemetry = { enable = false },
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
vim.lsp.enable("lua_ls")
vim.lsp.enable("ruby_lsp")
vim.lsp.enable("gopls")
vim.lsp.config("rumdl", {
	root_markers = { ".obsidian", "index.md" },
})
vim.lsp.enable("rumdl")

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf }
		vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
		vim.keymap.set("n", "grd", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
		-- already handled by conform.nvim
		-- vim.keymap.set({ "n", "x" }, "gq", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)

		local id = vim.tbl_get(event, "data", "client_id")
		local client = id and vim.lsp.get_client_by_id(id)

		if client and client:supports_method("textDocument/completion") then
			vim.bo[event.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
		end
	end,
})

require("conform").setup({
	formatters_by_ft = {
		-- You can customize some of the format options for the filetype (:help conform.format)
		lua = { "stylua" },
		ruby = { lsp_format = "prefer" },
		javascript = { "prettierd", "prettier", lsp_format = "fallback", stop_after_first = true },
		-- markdown = { "prettier" },
	},
	-- If this is set, Conform will run the formatter on save.
	-- It will pass the table to conform.format().
	-- This can also be a function that returns the table.
	format_on_save = {
		-- I recommend these options. See :help conform.format for details.
		lsp_format = "fallback",
		timeout_ms = 500,
	},
})

-- [[ Treesitter Configuration ]]
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and kind == "update" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

-- [[ Netrw ]]
-- Netrw is an old built-in vim & nvim package
-- this package's settings historically binded to the vim itself
vim.g.netrw_keepdir = 0
vim.g.netrw_winsize = 30
vim.g.netrw_localcopycmd = "cp -r"

vim.keymap.set("n", "<leader>e", "<cmd>Lexplore<cr>", { desc = "[E]xplore directory" })
vim.keymap.set("n", "<leader>ef", "<cmd>Lexplore %:p:h<cr>", { desc = "[E]xplore current [F]ile directory" })

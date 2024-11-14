vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = "split"
vim.opt.termguicolors = true
vim.opt.scrolloff = 10

vim.api.nvim_create_autocmd({ "InsertEnter" }, { command = "NoMatchParen" })
vim.api.nvim_create_autocmd({ "InsertLeave" }, { command = "DoMatchParen" })
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	{ "folke/neodev.nvim", opts = {} },
	{
		"nvim-treesitter/nvim-treesitter",
		init = function()
			require("nvim-treesitter.configs").setup({
				modules = {},
				ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "html" },
				sync_install = false,
				auto_install = true,
				ignore_install = { "javascript" },
				highlight = { enable = true },
			})
		end,
	},
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "neovim/nvim-lspconfig" },
	{ "rktjmp/lush.nvim" },
	{
		dir = "/home/ks/.config/nvim/colorschemes/alright",
		lazy = true,
		init = function()
			vim.cmd.colorscheme("alright")
		end,
	},
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
	{
		"stevearc/oil.nvim",
		opts = {
			skip_confirm_for_simple_edits = true,
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"windwp/nvim-autopairs",
		opts = {},
	},
	{
		"numToStr/Comment.nvim",
		opts = {
			toggler = {
				line = "<leader>/",
			},
			opleader = {
				line = "<leader>/",
			},
		},
		lazy = false,
	},
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		init = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
				mapping = {
					["<CR>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							if luasnip.expandable() then
								luasnip.expand()
							else
								cmp.confirm({
									select = true,
								})
							end
						else
							fallback()
						end
					end),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.locally_jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),

					-- ... Your other mappings ...
				},
			})
		end,
	},
	{ "rafamadriz/friendly-snippets" },
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				c = { "clang_format" },
				cpp = { "clang_format" },
				css = { "prettier" },
				go = { "gofumpt" },
				html = { "prettier" },
				htmldjango = { "djlint" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				lua = { "stylua" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				tailwindcss = { "tailwindcss " },
				python = { "black" },
				rust = { "rustfmt" },
				svelte = { "prettier" },
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					require("conform").format({ bufnr = args.buf })
				end,
			})
		end,
	},
	{
		"Exafunction/codeium.vim",
		config = function()
			vim.keymap.set("i", "<C-\\>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true, silent = true })
		end,
	},
	{
		"b0o/schemastore.nvim",
	},
}

require("lazy").setup(plugins)
require("neodev").setup()
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls" },
})

require("lspconfig").lua_ls.setup({
	settings = {
		Lua = {
			format = {
				enable = true,
				defaultConfig = {
					indent_style = "space",
					indent_size = "4",
				},
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	},
})
require("lspconfig").gopls.setup({})
require("lspconfig").html.setup({
	settings = {
		html = {
			format = {
				templating = true,
				wrapLineLength = 120,
				wrapAttributes = "auto",
			},
			hover = {
				documentation = true,
				references = true,
			},
		},
	},
})
require("lspconfig").clangd.setup({})
require("lspconfig").tailwindcss.setup({})
require("lspconfig").zls.setup({})
require("lspconfig").emmet_ls.setup({})
require("lspconfig").pyright.setup({})
require("lspconfig").rust_analyzer.setup({})
require("lspconfig").eslint.setup({})
require("lspconfig").ts_ls.setup({})
require("lspconfig").svelte.setup({})
require("lspconfig").jsonls.setup({
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
})

local lsp_servers = {
	"lua_ls",
	"gopls",
	"html",
	"ts_ls",
	"cssls",
	"clangd",
	"zls",
	"emmet_ls",
	"eslint",
	"rust_analyzer",
	"jsonls",
	"svelte",
	"pyright",
}
local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, server in ipairs(lsp_servers) do
	require("lspconfig")[server].setup({
		capabilities = capabilities,
	})
end

require("gitsigns").setup()

require("conform").setup({
	formatters = {
		clang_format = {
			prepend_args = {
				"--style={BasedOnStyle: Microsoft, IndentWidth: 4, ColumnLimit: 100, DerivePointerAlignment: false, PointerAlignment: Right}",
			},
			filetypes = { "c", "cpp" },
		},
	},
})

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>se", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	end,
})

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<space>e", ":Oil<CR>")
vim.keymap.set("n", "<space>bd", ":bd<CR>")

local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>sf", telescope.find_files, {})
vim.keymap.set("n", "<leader><leader>", telescope.buffers, {})
vim.keymap.set("n", "<leader>sk", telescope.diagnostics, {})
vim.keymap.set("n", "<leader>st", telescope.live_grep, {})
vim.keymap.set("n", "<C-d>", "<C-d>zz", {})
vim.keymap.set("n", "<C-u>", "<C-u>zz", {})
vim.keymap.set("n", "|", ":vsplit<CR>", {})
vim.keymap.set("n", "-", ":split<CR>", {})
vim.keymap.set("n", "<space>f", function()
	require("conform").format()
end, {})

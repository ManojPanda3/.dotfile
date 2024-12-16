local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local cordpath = vim.fn.stdpath("data") .. "/lazy/cord.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins", opts = {
			colorscheme = "dracula",
		} },
		{ "Mofiqul/dracula.nvim", opts = {
			transparent_bg = true,
		} },
		{
			"luckasRanarison/tailwind-tools.nvim",
			name = "tailwind-tools",
			build = ":UpdateRemotePlugins",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-telescope/telescope.nvim",
				"neovim/nvim-lspconfig",
			},
			opts = {},
		},
		{ "nvim-lua/plenary.nvim" },
		{
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {
				signs = true,
				sign_priority = 8, -- sign priority
				-- keywords recognized as todo comments
				keywords = {
					FIX = {
						icon = " ", -- icon used for the sign, and in search results
						color = "error", -- can be a hex color, or a named color (see below)
						alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
						-- signs = false, -- configure signs for some keywords individually
					},
					TODO = { icon = " ", color = "info" },
					HACK = { icon = " ", color = "warning" },
					WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
					PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
					NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
					TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
					LOGIC = { icon = " ", color = "logic" },
				},
				gui_style = {
					bg = "BOLD",
				},
				merge_keywords = true,
				highlight = {
					multiline_pattern = "^.*",
					multiline_context = 10,
					multiline = true,
					before = "",
					keyword = "wide",
					after = "fg",
					pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
					comments_only = true,
					max_line_len = 400, -- ignore lines longer than this
					exclude = {}, -- list of file types to exclude highlighting
				},
				-- list of named colors where we try to extract the guifg from the
				-- list of highlight groups or use the hex color if hl not found as a fallback
				colors = {
					error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
					warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
					info = { "DiagnosticInfo", "#2563EB" },
					hint = { "DiagnosticHint", "#10B981" },
					default = { "Identifier", "#7C3AED" },
					test = { "Identifier", "#FF00FF" },
					logic = { "Identifier", "#18D51F" },
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
					-- regex that will be used to match keywords.
					-- don't rgplace the (KEYWORDS) placeholder
					pattern = [[\b(KEYWORDS):]], -- ripgrep regex
					-- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
				},
			},
		},
		{
			"vyfor/cord.nvim",
			build = "./build || .\\build",
			event = "VeryLazy",
			opts = {
				usercmds = true, -- Enable user commands
				log_level = "error", -- One of 'trace', 'debug', 'info', 'warn', 'error', 'off'
				timer = {
					interval = 2000, -- Interval between presence updates in milliseconds (min 500)
					reset_on_idle = false, -- Reset start timestamp on idle
					reset_on_change = false, -- Reset start timestamp on presence change
				},
				editor = {
					image = nil, -- Image ID or URL in case a custom client id is provided
					client = "neovim", -- vim, neovim, lunarvim, nvchad, astronvim or your application's client id
					tooltip = "The Superior Text Editor", -- Text to display when hovering over the editor's image
				},
				display = {
					show_time = true, -- Display start timestamp
					show_repository = true, -- Display 'View repository' button linked to repository url, if any
					show_cursor_position = false, -- Display line and column number of cursor's position
					swap_fields = false, -- If enabled, workspace is displayed first
					swap_icons = false, -- If enabled, editor is displayed on the main image
					workspace_blacklist = {}, -- List of workspace names that will hide rich presence
				},
				idle = {
					enable = true, -- Enable idle status
					show_status = true, -- Display idle status, disable to hide the rich presence on idle
					timeout = 300000, -- Timeout in milliseconds after which the idle status is set, 0 to display immediately
					disable_on_focus = false, -- Do not display idle status when neovim is focused
					text = "Idle", -- Text to display when idle
					tooltip = "💤", -- Text to display when hovering over the idle image
				},
				lsp = {
					show_problem_count = false, -- Display number of diagnostics problems
					severity = 1, -- 1 = Error, 2 = Warning, 3 = Info, 4 = Hint
					scope = "workspace", -- buffer or workspace
				},
				text = {
					viewing = "Viewing {}", -- Text to display when viewing a readonly file
					editing = "Coding {}", -- Text to display when editing a file
					file_browser = "Browsing files in {}", -- Text to display when browsing files (Empty string to disable)
					plugin_manager = "Managing plugins in {}", -- Text to display when managing plugins (Empty string to disable)
					lsp_manager = "Configuring LSP in {}", -- Text to display when managing LSP servers (Empty string to disable)
					vcs = "Committing changes in {}", -- Text to display when using Git or Git-related plugin (Empty string to disable)
					workspace = "In {}", -- Text to display when in a workspace (Empty string to disable)
				},
				buttons = {
					{
						label = "View Repository", -- Text displayed on the button
						url = "git", -- URL where the button leads to ('git' = automatically fetch Git repository URL)
					},
					{
						label = "Arch",
						url = "https://archlinux.org/",
					},
					{
						label = "neovim",
						url = "https://github.com/neovim/neovim",
					},
				},
				assets = nil,
			}, -- calls require('cord').setup()
		},
		{ import = "plugins" },
	},
	defaults = {
		lazy = true,
		version = false,
	},
	install = { colorscheme = { "dracula" } },
	checker = {
		enable = false,
		notify = false,
	},
	performance = {
		rtp = {
			disable_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

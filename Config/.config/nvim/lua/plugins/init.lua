return {
	{
		"stevearc/conform.nvim",
		-- event = 'BufWritePre', -- uncomment for format on save
		opts = require("configs.conform"),
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lspconfig")
		end,
	},

	-- LSP Support => Mason with integrated configuration
	{
		"mason-org/mason.nvim",
		dependencies = {
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			-- local mason_tool_installer = require("mason-tool-installer")

			-- enable mason and configure icons (your existing tweaks preserved)
			mason.setup({
				ui = {
					border = "rounded",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			-- Mason LSP config (your existing configuration preserved)
			mason_lspconfig.setup({
				ensure_installed = {
					"lua_ls",
					"bashls",
					"gopls",
					"html",
					"pyright",
					"rust_analyzer",
					"ts_ls",
				},
				automatic_installation = true,
			})

			-- -- Mason tool installer (your existing configuration preserved)
			-- mason_tool_installer.setup({
			-- 	ensure_installed = {
			-- 		"prettier",
			-- 		"stylua",
			-- 		"isort",
			-- 		"black",
			-- 		"pylint",
			-- 		"shfmt",
			-- 		"golines",
			-- 		"rustfmt",
			-- 		"nixfmt",
			-- 	},
			-- 	run_on_start = true,
			-- 	start_delay = 4000, -- 4 second delay
			-- 	debounce_hours = 5,
			-- 	integrations = {
			-- 		["mason-lspconfig"] = true,
			-- 	},
			-- })
		end,
	},

	-- test new blink
	-- { import = "nvchad.blink.lazyspec" },

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"vim", "vimdoc",
				"lua", "bash", "nix",
				"go", "gosum", "rust", "python",
				"html", "css", "latex", "typst", "yaml",
				"markdown", "markdown_inline",
				"jsx", "tsx", "typescript",
			},
		},
	},

  -- -- Markdown Preview
  {
    "OXY2DEV/markview.nvim",
    ft = "markdown",   -- Lazy-load: only activates when you open a .md file

    dependencies = {
      -- "saghen/blink.cmp",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = require("configs.markview"),
  },

  -- END
}

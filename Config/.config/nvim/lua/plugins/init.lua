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
					"lua_ls", "bashls",
					"gopls", "html", "ts_ls",
					"pyright", "rust_analyzer",
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

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"lua", "bash", "nix",
				"jsx", "tsx", "typescript",
				"markdown", "markdown_inline",
				"vim", "vimdoc", "yaml", "toml",
				"go", "gosum", "rust", "python",
				"html", "css", "latex", "typst",
			},
		},
	},

  -- -- Markdown Preview
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },

    opts = function()
      return require("configs.markview")
    end,
  },

  --
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  }

  -- END
}

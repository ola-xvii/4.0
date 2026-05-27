require("nvchad.configs.lspconfig").defaults()

local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- Ensure lspconfig is loaded to register its configurations
require("lspconfig")

-- Define and enable LSP servers using the new vim.lsp.config API
local servers = {
	"bashls",
	"gofmt", -- golang formatter
	"golines", -- golang formatter
	"pyright",
	"rust_analyzer",
	"ts_ls", -- TypeScript and TSX support
	"cssls",
	"html", -- HTML support
	"lua_ls", -- Lua support
}

-- Configure each server
for _, server in ipairs(servers) do
	vim.lsp.config(server, {
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = server == "ts_ls" and {
			"typescript",
			"javascript",
			"typescriptreact",
			"javascriptreact",
		} or nil,
	})
end

-- Enable all configured servers
vim.lsp.enable(servers)

-- Optional: TypeScript/TSX specific enhancements
vim.lsp.config("tsserver", {
	root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
})

-- -- Optional: Python specific configuration
-- vim.lsp.config("pyright", {
--   settings = {
--     python = {
--       analysis = {
--         autoSearchPaths = true,
--         diagnosticMode = "workspace",
--         useLibraryCodeForTypes = true
--       }
--     }
--   }
-- })

-- -- Optional: Rust specific configuration
-- vim.lsp.config("rust_analyzer", {
--   settings = {
--     ['rust-analyzer'] = {
--       checkOnSave = {
--         command = "clippy"
--       },
--     }
--   }
-- })

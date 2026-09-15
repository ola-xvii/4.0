require("nvchad.options")

-- Tabbing / Indentation
vim.opt.tabstop = 2 -- Tab width
vim.opt.shiftwidth = 2 -- Indent width
vim.opt.softtabstop = 2 -- Soft tab stop
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true -- Copy indent from current line
vim.opt.grepprg = "rg --vimgrep" -- Use ripgrep if available

-- -- Enforce 2-space indents on all filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
    vim.opt.tabstop = 2 -- Tab width
    vim.opt.shiftwidth = 2 -- Indent width
    vim.opt.softtabstop = 2 -- Soft tab stop
    vim.opt.expandtab = true -- Use spaces instead of tabs
    vim.opt.smartindent = true -- Smart auto-indenting
    vim.opt.autoindent = true -- Copy indent from current line
	end,
})

-- Alternatively, enable it only for specific filetypes like markdown or text
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_gb"
  end,
})


-- -- -- -- -->
local o = vim.opt

-- Enable spell checker globally
-- o.spell = true
-- o.spelllang = { "en_gb" }

-- Blinking Cursor
o.termguicolors = true -- Enable true color support
o.relativenumber = true -- Show relative numbers
o.showmatch = true -- Highlight matching brackets
o.autoread = true -- Auto-reload file if changed outside

-- CursorLine
o.cursorline = false
o.cursorlineopt ='both' -- to enable cursorline!
vim.cmd([[
  highlight CursorLine ctermbg=236 guibg=#313244
  highlight CursorLineNr ctermbg=236 guibg=#3d3d3d ctermfg=White guifg=#ffffff
]])

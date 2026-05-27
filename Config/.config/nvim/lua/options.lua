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

local o = vim.opt
-- add yours here!
o.termguicolors = true -- Enable true color support
o.guicursor = "i-n-c-sm:block-blinkwait700-blinkon400-blinkoff250"
o.relativenumber = true -- Show relative numbers
o.showmatch = true -- Highlight matching brackets
o.autoread = true -- Auto-reload file if changed outside


-- CursorLine
o.cursorline = true
o.cursorlineopt ='both' -- to enable cursorline!
vim.cmd([[
  highlight CursorLine ctermbg=DarkGrey guibg=#2a2a2a
  highlight CursorLineNr ctermbg=DarkGrey guibg=#2a2a2a
]])


-- Enable spell checker globally
-- o.spell = true
-- o.spelllang = { "en_ng" }

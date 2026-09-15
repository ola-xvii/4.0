-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "tokyodark",
  transparency = true,

	hl_override = {
		Comment = { italic = true },
		["@comment"] = { italic = true },
	},
}

M.nvdash = {
  load_on_startup = true,
  header = {
    "                              ",
    "                              ",
    "     ██╗ ██╗███╗   ██╗██╗  ██╗",
    "     ██║███║████╗  ██║╚██╗██╔╝",
    "     ██║╚██║██╔██╗ ██║ ╚███╔╝ ",
    "██   ██║ ██║██║╚██╗██║ ██╔██╗ ",
    "╚█████╔╝ ██║██║ ╚████║██╔╝ ██╗",
    " ╚════╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝",
    "                              ",
    "      󰅴   eovim™ (ツ)  󰅴   ",
    "                              ",
  },
}

M.ui = {
  statusline = {
      -- default/vscode/vscode_colored/minimal
     theme = "default",
      -- round and block will work for minimal theme only
      -- default/round/block/arrow separators work only for default statusline theme
     separator_style = "default",
  },

  tabufline = {
    enabled = true,
    lazyload = true,
  },
}

return M

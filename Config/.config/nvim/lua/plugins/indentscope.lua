return {
  "echasnovski/mini.indentscope",
  version = false,
  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local indentscope = require("mini.indentscope")

    indentscope.setup({
      -- symbol = "│",
      symbol = '╎',
      options = { try_as_border = true },
      draw = {
        delay = 100,
        animation = indentscope.gen_animation.quadratic({
          easing = "in-out",
          unit = "step",
        }),
      },
    })

    -- Disable in special filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "help", "dashboard", "neo-tree", "lazy", "mason", "trouble", "alpha", "nvim-tree",
      },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  end,
}

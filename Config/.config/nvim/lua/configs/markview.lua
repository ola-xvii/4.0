local presets = require("markview.presets")

---@type markview.config
local options = {

  -- ╔══════════════════════════════╗
  -- ║  PREVIEW BEHAVIOUR           ║
  -- ╚══════════════════════════════╝
  preview = {
    -- Which modes trigger live preview rendering ==> "n" = normal, "i" = insert, "v" = visual, "c" = command
    modes = { "n", "no", "c" },

    -- Which modes trigger hybrid mode (show raw markdown near cursor)
    hybrid_modes = { "i" },

    -- Debounce delay in ms before re-rendering after a change
    debounce = 50,

    -- Icon provider: "internal" (built-in), "mini" (mini.icons), "devicons"
    icon_provider = "internal",

    -- Max buffer lines to render (performance cap)
    max_buf_lines = 1000,

    -- Splitview window options (used with :Markview splitToggle)
    splitview_winopts = {
      width = 80,
      split = "right",
    },
  },

  -- ╔══════════════════════════════╗
  -- ║  MARKDOWN                    ║
  -- ╚══════════════════════════════╝
  markdown = {
    enable = true,

    -- ── Headings ──────────────────────────────────────────────────────────
    -- Use a built-in preset OR define manually
    -- Presets: glow | glow_center | slanted | arrowed | simple | marker
    headings = presets.headings.glow,

    -- ── Block Quotes & Callouts ────────────────────────────────────────────
    block_quotes = {
      enable = true,
      wrap = true, -- ✅ this enables text wrap support inside block quotes

      -- Default style for plain > quotes (no callout type)
      default = {
        border = "▋",
        hl = "MarkviewBlockQuoteDefault",
      },

      -- ✅ Callouts go HERE, inside block_quotes
      ["NOTE"] = {
        hl = "MarkviewBlockQuoteNote",
        preview = "󰋽 Note",
        title = true,
        icon = "󰋽",
      },
      ["TIP"] = {
        hl = "MarkviewBlockQuoteOk",
        preview = " Tip",
        title = true,
        icon = "",
      },
      ["IMPORTANT"] = {
        hl = "MarkviewBlockQuoteSpecial",
        preview = " Important",
        title = true,
        icon = "",
      },
      ["WARNING"] = {
        hl = "MarkviewBlockQuoteWarn",
        preview = " Warning",
        title = true,
        icon = "",
      },
      ["CAUTION"] = {
        hl = "MarkviewBlockQuoteError",
        preview = "󰳦 Caution",
        title = true,
        icon = "󰳦",
      },
      ["TODO"] = {
        hl = "MarkviewBlockQuoteNote",
        preview = " Todo",
        title = true,
        icon = "",
      },
      ["BUG"] = {
        hl = "MarkviewBlockQuoteError",
        preview = " Bug",
        title = true,
        icon = "",
      },
      ["SUCCESS"] = {
        hl = "MarkviewBlockQuoteOk",
        preview = "󰗠 Success",
        title = true,
        icon = "󰗠",
      },
    },

    -- ── Code Blocks ───────────────────────────────────────────────────────
    code_blocks = {
      enable = true,
      style = "simple", -- "simple" | "block"
      hl = "MarkviewCode",

      -- Show language icon next to the code block label
      language_direction = "right",

      -- Minimum width of the code block background
      min_width = 60,
      pad_amount = 3, -- spaces of padding on each side
    },

    -- ── Tables ────────────────────────────────────────────────────────────
    -- Preset: none | single | double | rounded | solid
    tables = presets.tables.rounded,

    -- ── Horizontal Rules ──────────────────────────────────────────────────
    -- Preset: thin | thick | double | dashed | dotted | solid | arrowed
    horizontal_rules = presets.horizontal_rules.double,

    -- ── List Items ────────────────────────────────────────────────────────
    list_items = {
      enable = true,
      indent_size = 2,
      shift_width = 2,

      marker_minus = {
        add_padding = true, -- enables wrap support for list items
        text = "",
        hl = "MarkviewListItemMinus",
      },
      marker_plus = {
        add_padding = true,
        text = "",
        hl = "MarkviewListItemPlus",
      },
      marker_star = {
        add_padding = true,
        text = "",
        hl = "MarkviewListItemStar",
      },
    },
  },

  -- ╔══════════════════════════════╗
  -- ║  MARKDOWN INLINE             ║
  -- ╚══════════════════════════════╝
  markdown_inline = {
    enable = true,

    -- Checkboxes: [ ] unchecked, [x] checked
    checkboxes = {
      enable = true,
      checked = {
        text = "󰗠",
        hl = "MarkviewCheckboxChecked",
      },
      unchecked = {
        text = "󰄱",
        hl = "MarkviewCheckboxUnchecked",
      },
    },

    -- Inline code spans (`like this`)
    inline_codes = {
      enable = true,
      hl = "MarkviewCode",
    },

    -- Hyperlinks
    hyperlinks = {
      enable = true,
    },
  },
}

return options

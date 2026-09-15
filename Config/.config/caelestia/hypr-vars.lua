return {
  -- Apps
  terminal                   = "ghostty",
  browser                    = "zen-browser",
  editor                     = "ghostty -e nvim",


  -- Window styling
  windowOpacity              = 0.90,
  windowRounding             = 10,
  windowBorderSize           = 6,

  windowGapsIn               = 5,
  windowGapsOut              = 10,

  cursorTheme                = "Bibata-Mordern-Amber",
  cursorSize                 = 38,

  ------------------
  ---- KEYBINDS ----
  ------------------

  -- Workspaces
  kbMoveWinToWs              = "SUPER + ALT",
  kbMoveWinToWsGroup         = "CTRL + SUPER + ALT",
  kbGoToWs                   = "SUPER",
  kbGoToWsGroup              = "CTRL + SUPER",
  kbNextWs                   = "CTRL + SUPER + Right",
  kbPrevWs                   = "CTRL + SUPER + Left",
  kbToggleSpecialWs          = "SUPER + S",

  -- Window Group
  kbWindowGroupCycleNext     = "ALT + TAB",
  kbWindowGroupCyclePrev     = "CTRL + SHIFT + ALT + TAB",
  kbUngroup                  = "SUPER + U",
  kbToggleGroup              = "SUPER + Comma",

  -- Window Action
  kbMoveWindow               = "SUPER + XF86PickupPhone",
  kbResizeWindow             = "SUPER + XF86Tools",
  kbWindowPip                = "SUPER + ALT + backslash",
  -- Special workspaces toggles
  kbCommunication            = "SUPER + C",
  kbTodo                     = "SUPER + D",

  -- Apps
  kbTerminal                 = "SUPER + RETURN",
  kbBrowser                  = "SUPER + Z",
  kbEditor                   = "SUPER + X",
  kbFileExplorer             = "SUPER + E",

  -- Utilities
  kbScreenshot               = "SUPER + Y",
  kbScreenshotFreeze         = "SUPER + SHIFT + Y",
  kbScreenshotRegion         = "SUPER + SHIFT + ALT + Y",
  kbRecordSound              = "Print",
  kbRecordRegion             = "ALT + Print",
  kbColorPicker              = "SUPER + SHIFT + C",

  -- Clipboard and emoji picker
  kbClipboardDel             = "SUPER + ALT + H",
  kbClipboardPasteLatest     = "CTRL + SHIFT + ALT + V",
  kbEmoji                    = "SUPER + Period",

  -- Misc
  kbSession                  = "CTRL + ALT + Delete",
  kbShowSidebar              = "SUPER + N",
  kbClearNotifs              = "ALT + C",
  kbShowPanels               = "SUPER + A",
  kbLock                     = "SUPER + L",
  kbRestoreLock              = "SUPER + ALT + L",
}

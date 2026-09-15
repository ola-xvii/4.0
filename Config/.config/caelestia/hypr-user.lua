local home = os.getenv("HOME")

local plugins = home .. "/.config/caelestia/plugins"
require("plugins")

-- -
hyde = hyde or {}
hyde.config = hyde.config or {}
hyde.config.anim = hyde.config.anim or {}
hyde.config.anim.duration_scale = 0.6  -- Change this to your preferred speed multiplier
-- -
local animations = home .. "/.config/caelestia/animations"
require("animations.diablo-1")
-- -


--[ EXECS ]
hl.on("hyprland.start", function()
  hl.exec_cmd("udiskie")
  hl.exec_cmd("hyprpm reload -n")
  hl.exec_cmd("sleep 2 && ~/.local/bin/mech-key")
end)


--[ INPUT ]
hl.config({
  input = {
    kb_layout = "us",
    kb_options = "caps:escape",
    numlock_by_default = true,
    repeat_delay = 250,
    repeat_rate = 35,
  }
})

-- [ XWAYLAND ]
hl.config({
  xwayland = {
    force_zero_scaling = true
  },
})


-- #[ GTK_THEMING ]
local i_theme = "Papirus-Dark"

hl.on("config.reloaded", function()
  hl.exec_cmd("sleep 1 && gsettings set org.gnome.desktop.interface icon-theme " .. i_theme)
  hl.exec_cmd("sleep 1 && gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark")
  hl.exec_cmd("sleep 1 && gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
end)


-- BINDS
hl.bind("SUPER + ALT + RETURN", hl.dsp.exec_raw("foot"))
hl.bind("SUPER + G", hl.dsp.exec_raw("lutris"))
hl.bind("SUPER + K", hl.dsp.exec_raw("uwsm app -- ~/.local/bin/wayclick/dusky_wayclick.sh"))

hl.bind("SUPER + ALT + E", hl.dsp.exec_raw("ghostty -e $SHELL -l -c yazi"))

hl.bind( "SUPER + R", hl.dsp.exec_cmd("qs -c caelestia kill"), { release = true })
hl.bind( "SUPER + SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"),  { release = true })

-- RULES 
hl.window_rule({ match = { class = "org.gnome.Papers" }, no_blur = true, opaque = true })
hl.window_rule({ match = { class = "mpv" }, no_blur = true, opaque = true })

-- -- ENV
-- hl.env("env = QT_FFMPEG_DECODING_HW_DEVICE_TYPES", "none")

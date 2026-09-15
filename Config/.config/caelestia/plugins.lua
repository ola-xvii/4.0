if hl.plugin.hyprglass then
  local hg = hl.plugin.hyprglass

  -- Presets
  hg.preset("alte", { glass_opacity = 0.9,
    blur_strength = 1.4,
    blur_iterations = 2,
    chromatic_aberration = 0.1,
    fresnel_strength = 0.8,
    edge_thickness = 0.04,
    tint_color = 0x00000000,
    lens_distortion = 6.5,
    contrast = 1.0,
    saturation = 2.0,
    vibrancy = 0.4,
    vibrancy_darkness = 2.0,
    adaptive_boost = 0.8,
    dark = { brightness = 0.9 },
    light = { brightness = 1.2 },
  })
  --
  hg.preset("glass", {
    blur_strength = 1.0,
    blur_iteration = 3,
    chromatic_abberation = 0.8,
    fresnel_strength = 0.8,
    edge_thickness = 0.06,
    tint_color = 0x00000000,
    lens_distortion = 0.9,
    brightness = 2.0,
    contrast = 1.7,
    saturation = 1,
    vibrancy = 0.8,
    vibrancy_darkness = 1,
    adaptive_boost = 0.5
  })

  hg.preset("apple", {
    blur_strength = 1.0,
    blur_iterations = 3,
    refraction_strength = 0.55,
    chromatic_abberation = 0.3,
    fresnel_strength = 0.5,
    specular_strength = 0.75,
    edge_thickness = 0.05,
    lens_distortion = 0.3,
    dark = { brightness = 0.82, contrast = 0.90, saturation = 0.80, vibrancy = 0.15, adaptive_dim = 0.4 },
    light = { brightness = 1.12, contrast = 0.92, saturation = 0.85, vibrancy = 0.12, adaptive_boost = 0.4 },
  })

  -- Layer surfaces: each call whitelists the namespace and configures it
  hg.layer("quickshell:bezel", { preset = "ui", mask_threshold = 0.3 })
  hg.layer("quickshell:bar", { preset = "ui", mask_threshold = 0.3 })
  hg.layer("debug-panel", { exclude = true })

  -- rules
  hl.window_rule({ match = { title = "Obsidian" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { class = "md.obsidian.Obsidian" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { class = "com.rtosta.zapzap" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { class = "Spotify" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { class = "org.gnome.Papers" }, tag = "+hyprglass_disabled" })

  hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { title = "Picture-in-Picture" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { title = "Save file" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { title = "Download" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { title = "btop" }, tag = "+hyprglass_disabled" })

  hl.window_rule({ match = { class = "steam" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { class = "steam_proton" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { class = "net.lutris.Lutris" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { class = "dotnet" }, tag = "+hyprglass_disabled" })

  hl.window_rule({ match = { class = "bottles" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { class = "com.usebottles.bottles" }, tag = "+hyprglass_disabled" })
  -- hl.window_rule({ match = { title = "Terraria:*" }, tag = "+hyprglass_disabled" })
  hl.window_rule({ match = { class = "org.vinegarhq.Sober" }, tag = "+hyprglass_disabled" })

  -- -- -- -- 
  hg.config({
    default_theme = "light",
    default_preset = "glass",
    layers = { enabled = true },
  })

end

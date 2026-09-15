#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  setup_game.sh — Gaming dependencies, Wine, Vulkan & launchers
# =============================================================================

log()  { echo "▶  $*"; }
ok()   { echo " ✓ $*"; }
warn() { echo " ⚠ $*" >&2; }
die()  { echo " ✗ $*" >&2; exit 1; }
trap 'die "Unexpected error on line $LINENO."' ERR

echo "=== Gaming Setup ==="

# -----------------------------------------
# Pre-flight
# -----------------------------------------
command -v yay >/dev/null 2>&1 \
  || die "'yay' is not installed. Please install it first."

# Check multilib is enabled (required for lib32 packages)
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
  die "multilib repository is not enabled in /etc/pacman.conf. Enable it and re-run."
fi

# -----------------------------------------
# 32-bit Libraries & Dependencies
# -----------------------------------------
BIT=(
  giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap
  gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal
  v4l-utils lib32-v4l-utils libpulse lib32-libpulse
  alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib
  libjpeg-turbo lib32-libjpeg-turbo libxcomposite lib32-libxcomposite
  libxinerama lib32-libxinerama ncurses lib32-ncurses
  opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt
  libva lib32-libva gtk3 lib32-gtk3
  gst-plugins-base-libs lib32-gst-plugins-base-libs
  
  openssl lib32-openssl lib32-freetype2
   
  lib32-libxml2 sdl2 lib32-sdl2 
  cups samba dosbox
)

# -----------------------------------------
# Vulkan, Wine & Launchers
# -----------------------------------------
DEPS=(
  # Vulkan
  mesa mesa-utils lib32-mesa
  vulkan-radeon lib32-vulkan-radeon vdpauinfo
  vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools
  libva-utils libvdpau-va-gl libva-mesa-driver

  # Wine / DXVK
  wine winetricks wine-mono wine-gecko 
  dxvk-bin vkd3d

  # Launchers & tools
  lutris umu-launcher steam bottles
  gamemode gamescope mangohud
  usbutils joyutils
  # bluez-ps3 
)

# -----------------------------------------
# Install
# -----------------------------------------
install_pkgs() {
  log "Installing Vulkan / Wine / Launcher packages..."
  yay -S --needed --noconfirm "${DEPS[@]}" \
    || die "Failed to install DEPS packages."
  ok "Vulkan / Wine / Launchers installed."

  # log "Installing 32-bit dependencies..."
  # # Use --noconfirm here too — large package list, keep it non-interactive
  # yay -S --needed --noconfirm "${BIT[@]}" \
  #   || die "Failed to install 32-bit dependency packages."
  # ok "32-bit dependencies installed."
}

# -----------------------------------------
# Steam Native Runtime (steam-libs repo)
# -----------------------------------------
install_steam_native() {
  log "Checking for steam-libs repo (prebuilt steam-native-runtime)..."
  if grep -q '^\[steam-libs\]' /etc/pacman.conf; then
    ok "steam-libs repo already configured."
  else
    log "Adding steam-libs repo to /etc/pacman.conf..."
    sudo tee -a /etc/pacman.conf > /dev/null <<'EOF'

# Credits: Damglador
[steam-libs]
SigLevel = Optional DatabaseOptional
Server = https://damglador.github.io/$repo/$arch/
EOF
    ok "steam-libs repo added."
  fi

  log "Refreshing pacman databases..."
  sudo pacman -Syy \
    || die "Failed to refresh pacman databases."
  ok "Databases refreshed."

  log "Installing steam-native-runtime..."
  sudo pacman -S --needed --noconfirm steam-native-runtime \
    || die "Failed to install steam-native-runtime."
  ok "steam-native-runtime installed."
}

install_pkgs
install_steam_native

echo ""
ok "Gaming setup complete!"
echo "   → Launch Steam or Lutris to configure your games."
echo "   → Run 'vulkaninfo' to verify Vulkan is working."

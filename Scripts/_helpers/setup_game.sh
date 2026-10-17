#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

ENABLE_THIRD_PARTY_STEAM_LIBS="${ENABLE_THIRD_PARTY_STEAM_LIBS:-0}"
NONINTERACTIVE="${NONINTERACTIVE:-0}"
INSTALL_GAMING_32BIT="${INSTALL_GAMING_32BIT:-0}"

echo "=== Gaming Setup ==="

# multilib is required for the lib32-* packages below.
if ! awk '/^\[multilib\]/{found=1} END{exit !found}' /etc/pacman.conf; then
    die "multilib repository is not enabled in /etc/pacman.conf."
fi
ok "multilib is enabled."

# ---- Official packages -------------------------------------------------------
GAMING_REPO_PKGS=(
    # Vulkan / Mesa
    mesa mesa-utils lib32-mesa
    vulkan-radeon lib32-vulkan-radeon vdpauinfo
    vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools
    libva-utils libvdpau-va-gl libva-mesa-driver

    # Wine
    wine winetricks wine-mono wine-gecko

    # Launchers & tools
    lutris steam bottles
    gamemode gamescope mangohud
    usbutils joyutils
)

# ---- AUR packages ------------------------------------------------------------
GAMING_AUR_PKGS=(
    dxvk-bin
    umu-launcher
)

# ---- Optional 32-bit compatibility set ---------------------------------------
GAMING_BIT_PKGS=(
    giflib lib32-giflib
    libpng lib32-libpng
    libldap lib32-libldap
    gnutls lib32-gnutls
    mpg123 lib32-mpg123
    openal lib32-openal
    v4l-utils lib32-v4l-utils
    libpulse lib32-libpulse
    alsa-plugins lib32-alsa-plugins
    alsa-lib lib32-alsa-lib
    libjpeg-turbo lib32-libjpeg-turbo
    libxcomposite lib32-libxcomposite
    libxinerama lib32-libxinerama
    ncurses lib32-ncurses
    opencl-icd-loader lib32-opencl-icd-loader
    libxslt lib32-libxslt
    libva lib32-libva
    gtk3 lib32-gtk3
    gst-plugins-base-libs lib32-gst-plugins-base-libs
    openssl lib32-openssl
    lib32-freetype2 lib32-libxml2
    sdl2 lib32-sdl2
    cups samba dosbox
)

log "[1/3] Installing official gaming packages..."
sudo pacman -S --needed --noconfirm "${GAMING_REPO_PKGS[@]}" \
    || die "Failed to install official gaming packages."
ok "Official gaming packages installed."

if command -v yay >/dev/null 2>&1; then
    log "[2/3] Installing AUR gaming packages..."
    if (( NONINTERACTIVE )); then
        yay -S --needed --noconfirm "${GAMING_AUR_PKGS[@]}" \
            || warn "AUR gaming package installation failed."
    else
        yay -S --needed "${GAMING_AUR_PKGS[@]}" \
            || warn "AUR gaming package installation failed."
    fi
else
    warn "yay not installed — skipping AUR gaming packages."
fi

if [[ "$INSTALL_GAMING_32BIT" == "1" ]]; then
    log "Installing 32-bit compatibility libraries..."
    sudo pacman -S --needed --noconfirm "${GAMING_BIT_PKGS[@]}" \
        || warn "Some 32-bit packages failed to install."
    ok "32-bit compatibility libraries installed."
else
    log "Skipping 32-bit compat libraries (set INSTALL_GAMING_32BIT=1 to enable)."
fi

# ---- Third-party steam-libs repo (opt-in, disabled by default) ---------------
install_steam_native() {
    log "[3/3] Setting up steam-native-runtime..."

    if [[ "$ENABLE_THIRD_PARTY_STEAM_LIBS" != "1" ]]; then
        warn "Third-party 'steam-libs' repo is disabled by default."
        warn "It uses SigLevel=Optional DatabaseOptional, which weakens package"
        warn "signature verification. Set ENABLE_THIRD_PARTY_STEAM_LIBS=1 to opt in."
        return 0
    fi

    if grep -q '^\[steam-libs\]' /etc/pacman.conf; then
        ok "steam-libs repo already configured."
    else
        log "Adding steam-libs repo to /etc/pacman.conf..."
        sudo cp -- /etc/pacman.conf "/etc/pacman.conf.bak.$(date +%s)"

        sudo tee -a /etc/pacman.conf >/dev/null <<'EOF'

# Credits: Damglador — https://damglador.github.io/
# WARNING: optional signature level weakens verification.
[steam-libs]
SigLevel = Optional DatabaseOptional
Server = https://damglador.github.io/$repo/$arch/
EOF
        ok "steam-libs repo added."
    fi

    sudo pacman -Sy --noconfirm || { warn "Failed to refresh databases."; return 1; }
    ok "Package databases refreshed."

    if sudo pacman -S --needed --noconfirm steam-native-runtime; then
        ok "steam-native-runtime installed."
    else
        warn "Failed to install steam-native-runtime."
        return 1
    fi
}

install_steam_native || true

echo ""
ok "Gaming setup complete."
echo "   → Launch Steam or Lutris to configure your games."
echo "   → Run 'vulkaninfo' to verify Vulkan is working."
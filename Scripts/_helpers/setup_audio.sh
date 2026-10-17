#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "=== Audio & Bluetooth Setup ==="

# Everything here is in the official repos.
AUDIO_PKGS=(
    pipewire pipewire-audio pipewire-pulse pipewire-alsa
    wireplumber pipewire-jack
    sof-firmware gst-plugin-pipewire
    bluez bluez-utils
    blueman pavucontrol
)

# bluetooth-autoconnect is AUR-only.
AUDIO_AUR_PKGS=(
    bluetooth-autoconnect
)

log "[1/4] Installing audio and Bluetooth packages..."
sudo pacman -S --needed --noconfirm "${AUDIO_PKGS[@]}" \
    || die "Audio/Bluetooth package installation failed."
ok "Official audio packages installed."

if command -v yay >/dev/null 2>&1; then
    log "Installing AUR Bluetooth helpers..."
    if yay -S --needed --noconfirm "${AUDIO_AUR_PKGS[@]}"; then
        ok "AUR Bluetooth helpers installed."
    else
        warn "Failed to install AUR Bluetooth helpers — autoconnect unavailable."
    fi
else
    warn "yay not installed — skipping AUR Bluetooth helpers."
fi

log "[2/4] Enabling Bluetooth service..."
if systemctl list-unit-files --no-legend bluetooth.service >/dev/null 2>&1; then
    if sudo systemctl enable --now bluetooth.service; then
        ok "bluetooth.service enabled."
    else
        warn "Failed to enable bluetooth.service — may need manual start."
    fi
else
    warn "bluetooth.service not found — bluez may not have installed correctly."
fi

log "[3/4] Enabling Bluetooth autoconnect (if available)..."
if systemctl list-unit-files --no-legend bluetooth-autoconnect.service >/dev/null 2>&1; then
    if sudo systemctl enable --now bluetooth-autoconnect.service; then
        ok "bluetooth-autoconnect.service enabled."
    else
        warn "bluetooth-autoconnect.service failed to start."
    fi
else
    log "bluetooth-autoconnect.service not found — skipping."
fi

# NOTE: The old script added the user to the 'audio' and 'input' groups.
# Modern PipeWire/WirePlumber does not require 'audio' for desktop use, and
# 'input' broadens access to input devices. We no longer do this by default.
log "[4/4] Skipping 'audio'/'input' group changes."
log "     PipeWire runs as a user session via socket activation and does not"
log "     need these groups for a normal desktop environment."

echo ""
ok "Audio and Bluetooth setup complete."
echo "   → Log out and back in for service changes to take effect."
#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  setup_audio.sh — PipeWire, WirePlumber & Bluetooth setup
# =============================================================================

log()  { echo "[ + ] $*"; }
ok()   { echo " ✓  $*"; }
warn() { echo " ⚠  $*" >&2; }
die()  { echo " ✗  $*" >&2; exit 1; }

trap 'die "Unexpected error on line $LINENO."' ERR

echo "=== Audio & Bluetooth Setup ==="

# -----------------------------------------
# Pre-flight
# -----------------------------------------
command -v yay >/dev/null 2>&1 \
  || die "'yay' is not installed. Please install it first."

# -----------------------------------------
# Packages
# -----------------------------------------
AUDIO_PKGS=(
  pipewire pipewire-audio pipewire-pulse pipewire-alsa
  wireplumber pipewire-jack
  sof-firmware gst-plugin-pipewire
  bluez bluez-utils bluetooth-autoconnect
  blueman pavucontrol
)

log "[1/5] Installing audio and Bluetooth packages..."
yay -S --needed --noconfirm "${AUDIO_PKGS[@]}" \
  || die "Package installation failed."
ok "Packages installed."

# -----------------------------------------
# Bluetooth service
# -----------------------------------------
log "[2/5] Enabling Bluetooth service..."
if systemctl list-unit-files | grep -q '^bluetooth.service'; then
  sudo systemctl enable --now bluetooth.service \
    || warn "Failed to enable bluetooth.service — may need manual start."
  ok "bluetooth.service enabled."
else
  warn "bluetooth.service not found — bluez may not have installed correctly."
fi

# -----------------------------------------
# Bluetooth autoconnect (optional)
# -----------------------------------------
log "[3/5] Enabling Bluetooth autoconnect (if available)..."
if systemctl list-unit-files | grep -q 'bluetooth-autoconnect.service'; then
  sudo systemctl enable --now bluetooth-autoconnect.service \
    || warn "bluetooth-autoconnect.service failed to start."
  ok "bluetooth-autoconnect.service enabled."
else
  warn "bluetooth-autoconnect.service not found — skipping."
fi

# -----------------------------------------
# User groups
# -----------------------------------------
log "[4/5] Adding '$USER' to 'audio' and 'input' groups..."

for group in audio input; do
  if getent group "$group" >/dev/null 2>&1; then
    if id -nG "$USER" | grep -qw "$group"; then
      ok "User already in group '$group'."
    else
      sudo usermod -aG "$group" "$USER" \
        || warn "Failed to add '$USER' to group '$group'."
      ok "Added '$USER' to group '$group'."
    fi
  else
    warn "Group '$group' does not exist — skipping."
  fi
done

# -----------------------------------------
# Socket activation note
# -----------------------------------------
log "[5/5] PipeWire & WirePlumber will start via socket activation after reboot."

echo ""
ok "Audio and Bluetooth setup complete!"
echo "   → Reboot to apply group and service changes."
echo "   → Use 'pavucontrol' to manage audio after reboot."

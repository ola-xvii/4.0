#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  spicetify.sh — Spotify + Spicetify installer & configurator
# =============================================================================

log()  { echo " [ + ] $*"; }
ok()   { echo "  ✓  $*"; }
warn() { echo "  ⚠  $*" >&2; }
die()  { echo "  ✗  $*" >&2; exit 1; }

trap 'die "Unexpected error on line $LINENO."' ERR

echo "=== Spotify + Spicetify Setup ==="

# -----------------------------------------
# Pre-flight
# -----------------------------------------
command -v yay >/dev/null 2>&1 \
  || die "'yay' is not installed. Please install it first."

# -----------------------------------------
# Install Spotify
# -----------------------------------------
log "Checking Spotify..."
if yay -Qi spotify &>/dev/null; then
  ok "Spotify already installed — skipping."
else
  log "Installing Spotify..."
  yay -S --noconfirm spotify \
    || die "Failed to install Spotify."
  ok "Spotify installed."
fi

# -----------------------------------------
# Install Spicetify + Marketplace
# -----------------------------------------
log "Checking Spicetify..."
if yay -Qi spicetify-cli &>/dev/null && yay -Qi spicetify-marketplace-bin &>/dev/null; then
  ok "Spicetify already installed — skipping install."
else
  log "Installing Spicetify CLI and Marketplace..."
  yay -S --noconfirm --needed spicetify-cli spicetify-marketplace-bin \
    || die "Failed to install Spicetify."
  ok "Spicetify installed."

  log "Setting Spicetify permissions on /opt/spotify..."
  if [[ -d /opt/spotify ]]; then
    sudo chmod a+wr /opt/spotify \
      || die "Failed to chmod /opt/spotify"
    sudo chmod a+wr /opt/spotify/Apps -R \
      || die "Failed to chmod /opt/spotify/Apps"
    ok "Permissions set."
  else
    warn "/opt/spotify not found — Spotify may be installed to a different path."
  fi

  log "Initializing Spicetify (backup + apply)..."
  spicetify backup apply \
    || die "spicetify backup apply failed."
  ok "Spicetify initialized."
fi

# -----------------------------------------
# Apply Spicetify config
# -----------------------------------------
log "Applying Spicetify config..."
spicetify apply \
  || die "spicetify apply failed."
ok "Spicetify config applied."

# -----------------------------------------
# Patch Spotify launch flags for Wayland
# -----------------------------------------
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/spicetify/config-xpui.ini"
WAYLAND_FLAGS="--enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=auto"

if [[ ! -f "$CONFIG_FILE" ]]; then
  warn "Spicetify config not found at $CONFIG_FILE — skipping launch flag patch."
else
  log "Patching Spotify launch flags for Wayland..."

  # Check if flags are already correct to avoid duplicate patching
  current_flags=$(grep '^spotify_launch_flags' "$CONFIG_FILE" 2>/dev/null | sed 's/spotify_launch_flags[[:space:]]*=[[:space:]]*//' || echo "")

  if [[ "$current_flags" == "$WAYLAND_FLAGS" ]]; then
    ok "Launch flags already up to date."
  else
    if grep -q '^spotify_launch_flags' "$CONFIG_FILE"; then
      # Use @ as delimiter since flags contain slashes and pipes
      sed -i "s@^spotify_launch_flags.*@spotify_launch_flags   = $WAYLAND_FLAGS@" "$CONFIG_FILE" \
        || die "Failed to update spotify_launch_flags."
    else
      echo "spotify_launch_flags   = $WAYLAND_FLAGS" >> "$CONFIG_FILE" \
        || die "Failed to append spotify_launch_flags."
    fi
    ok "Wayland launch flags patched."
  fi

  # Re-apply after config change
  spicetify apply \
    || warn "spicetify re-apply after flag patch failed — run 'spicetify apply' manually."
fi

echo ""
ok "Spotify + Spicetify setup complete!"
echo "   → Launch Spotify to verify the theme is applied."

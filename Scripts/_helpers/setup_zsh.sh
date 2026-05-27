#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  setup_zsh.sh — Zsh installation & default shell setup
# =============================================================================

log()  { echo "  [ + ] $*"; }
ok()   { echo "   ✓  $*"; }
warn() { echo "   ⚠  $*" >&2; }
die()  { echo "   ✗  $*" >&2; exit 1; }

trap 'die "Unexpected error on line $LINENO."' ERR

DOT_DIR="$HOME/base-dot"

echo "=== Zsh Setup ==="

# -----------------------------------------
# Pre-flight
# -----------------------------------------
command -v yay >/dev/null 2>&1 \
  || die "'yay' is not installed. Please install it first."

# -----------------------------------------
# Install Zsh
# -----------------------------------------
if command -v zsh >/dev/null 2>&1; then
  ok "Zsh already installed ($(zsh --version))."
else
  log "Installing Zsh..."
  sudo pacman -S --noconfirm zsh \
    || die "Failed to install Zsh."
  ok "Zsh installed."
fi

# -----------------------------------------
# Set default shell
# -----------------------------------------
ZSH_PATH="$(command -v zsh)"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
  ok "Zsh is already the default shell for $USER."
else
  log "Setting Zsh as the default shell for $USER..."

  # chsh requires the shell to be listed in /etc/shells
  if ! grep -qx "$ZSH_PATH" /etc/shells; then
    warn "$ZSH_PATH not in /etc/shells — adding it..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null \
      || die "Failed to add $ZSH_PATH to /etc/shells."
  fi

  chsh -s "$ZSH_PATH" \
    || die "chsh failed — you may need to run this interactively or with sudo."
  ok "Default shell changed to $ZSH_PATH."
fi

echo ""
ok "Zsh setup complete!"
echo "   → Restart your terminal (or run 'exec zsh') to apply."

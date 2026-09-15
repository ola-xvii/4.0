#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "=== Zsh Setup ==="

# Zsh lives in the official repos — no yay required.
if command -v zsh >/dev/null 2>&1; then
    ok "Zsh already installed ($(zsh --version))."
else
    log "Installing Zsh..."
    sudo pacman -S --needed --noconfirm zsh \
        || die "Failed to install Zsh."
    ok "Zsh installed."
fi

ZSH_PATH="$(command -v zsh)"
USER_NAME="$(current_user)"
CURRENT_SHELL="$(getent passwd "$USER_NAME" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
    ok "Zsh is already the default shell for $USER_NAME."
else
    log "Setting Zsh as the default shell for $USER_NAME..."

    if ! grep -qx "$ZSH_PATH" /etc/shells; then
        warn "$ZSH_PATH not in /etc/shells — adding it."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null \
            || die "Failed to add $ZSH_PATH to /etc/shells."
    fi

    if chsh -s "$ZSH_PATH"; then
        ok "Default shell changed to $ZSH_PATH."
    else
        die "chsh failed — you may need to run it manually."
    fi
fi

echo ""
ok "Zsh setup complete."
echo "   → Restart your terminal (or run 'exec zsh') to apply."
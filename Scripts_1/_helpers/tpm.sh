#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

TMUX_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
TPM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm"

echo "=== TMUX + TPM Setup ==="

install_tpm() {
    log "Cloning TPM into $TPM_DIR..."
    mkdir -p "$(dirname "$TPM_DIR")"
    if git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
        ok "TPM installed."
    else
        warn "Failed to clone TPM repository."
        return 1
    fi
}

ensure_tpm() {
    if [[ -d "$TPM_DIR/.git" ]]; then
        ok "TPM already installed at $TPM_DIR."
        return 0
    fi
    install_tpm
}

install_plugins() {
    local installer="$TPM_DIR/bin/install_plugins"

    if [[ ! -f "$installer" ]]; then
        warn "TPM install_plugins not found at $installer."
        return 1
    fi

    log "Installing TPM plugins..."
    if "$installer"; then
        ok "TPM plugins installed."
    else
        warn "TPM plugin installation failed."
        return 1
    fi
}

# 1. Ensure TPM is present before anything else.
ensure_tpm || die "Could not install TPM."

# 2. If there is no tmux.conf, TPM is useless — report clearly and stop.
if [[ ! -f "$TMUX_CONF" ]]; then
    warn "No tmux.conf found at $TMUX_CONF — skipping tmux configuration."
    warn "TPM is installed but plugins won't load until a config is present."
    exit 0
fi

ok "Found tmux.conf at $TMUX_CONF."

# 3. Source the config if we're inside a tmux session.
if [[ -n "${TMUX:-}" ]]; then
    log "Sourcing tmux config..."
    if tmux source "$TMUX_CONF"; then
        ok "tmux config sourced."
    else
        warn "Failed to source tmux config — run 'tmux source $TMUX_CONF' manually."
    fi
else
    warn "Not inside a tmux session — skipping 'tmux source'."
fi

# 4. Install plugins (config is known to exist).
install_plugins || exit 1

echo ""
ok "TMUX + TPM setup complete."
echo "   → Start tmux and press prefix + I to reload plugins if needed."
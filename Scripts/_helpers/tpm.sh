#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  tpm.sh — Tmux Plugin Manager setup
# =============================================================================

log()  { echo "[ + ] $*"; }
ok()   { echo " ✓  $*"; }
warn() { echo " ⚠  $*" >&2; }
die()  { echo " ✗  $*" >&2; exit 1; }

trap 'die "Unexpected error on line $LINENO."' ERR

TMUX_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
TPM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm"

echo "=== TMUX + TPM Setup ==="

# -----------------------------------------
# Install TPM
# -----------------------------------------
install_tpm() {
  log "Cloning TPM into $TPM_DIR..."
  mkdir -p "$(dirname "$TPM_DIR")"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" \
    || die "Failed to clone TPM repository."
  ok "TPM installed at $TPM_DIR."
}

ensure_tpm() {
  if [[ -d "$TPM_DIR" ]]; then
    ok "TPM already installed at $TPM_DIR."
  else
    install_tpm
  fi
}

# -----------------------------------------
# Install TPM plugins
# -----------------------------------------
install_plugins() {
  local installer="$TPM_DIR/bin/install_plugins"

  if [[ ! -f "$installer" ]]; then
    die "TPM install_plugins script not found at $installer — TPM may not have cloned correctly."
  fi

  log "Installing TPM plugins..."
  "$installer" \
    || die "TPM plugin installation failed."
  ok "TPM plugins installed."
}

# -----------------------------------------
# Configure tmux
# -----------------------------------------
config_tmux() {
  if [[ ! -f "$TMUX_CONF" ]]; then
    warn "No tmux.conf found at $TMUX_CONF — skipping tmux configuration."
    warn "TPM is installed but plugins won't load until a config is present."
    return 0
  fi

  ok "Found tmux.conf at $TMUX_CONF."

  # TPM must be installed before sourcing config
  ensure_tpm

  # Source config — requires an active tmux session
  if [[ -n "${TMUX:-}" ]]; then
    log "Sourcing tmux config..."
    tmux source "$TMUX_CONF" \
      || warn "Failed to source tmux config — try running 'tmux source $TMUX_CONF' manually."
    ok "tmux config sourced."
  else
    warn "Not inside a tmux session — skipping 'tmux source'. Run it manually after starting tmux."
  fi

  install_plugins
}

config_tmux

echo ""
ok "TMUX + TPM setup complete!"
echo "   → Start tmux and press prefix + I to reload plugins if needed."

#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ---- Configuration (override via environment if needed) ----------------------
PLYMOUTH_THEME_NAME="${PLYMOUTH_THEME_NAME:-rings}"
PLYMOUTH_THEME_DIR="${PLYMOUTH_THEME_DIR:-$HOME/4.0/Patches/plymouth-themes}"
PLYMOUTH_THEME_ARCHIVE="$PLYMOUTH_THEME_DIR/$PLYMOUTH_THEME_NAME.tar.xz"
PLYMOUTH_THEME_DEST="/usr/share/plymouth/themes"

GRUB_THEME_NAME="${GRUB_THEME_NAME:-Sekiro_theme}"
GRUB_THEME_SRC="${GRUB_THEME_SRC:-$HOME/4.0/Patches/grub-themes/$GRUB_THEME_NAME}"
GRUB_THEME_DEST="/boot/grub/themes/$GRUB_THEME_NAME"

GRUB_CFG="/etc/default/grub"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

echo "=== Boot Theme Installer ==="

# -----------------------------------------------------------------------------
# 1. Plymouth package
# -----------------------------------------------------------------------------
log "[1/3] Installing Plymouth..."
if pacman -Qi plymouth >/dev/null 2>&1; then
    ok "Plymouth already installed."
else
    sudo pacman -S --needed --noconfirm plymouth \
        || die "Failed to install Plymouth."
    ok "Plymouth installed."
fi

# -----------------------------------------------------------------------------
# 2. Plymouth theme
# -----------------------------------------------------------------------------
log "[2/3] Installing Plymouth theme '$PLYMOUTH_THEME_NAME'..."

PLYMOUTH_SKIPPED=0

if [[ ! -f "$PLYMOUTH_THEME_ARCHIVE" ]]; then
    warn "Archive not found: $PLYMOUTH_THEME_ARCHIVE — skipping Plymouth theme."
    PLYMOUTH_SKIPPED=1
else
    sudo mkdir -p "$PLYMOUTH_THEME_DEST/$PLYMOUTH_THEME_NAME"

    if command -v pv >/dev/null 2>&1; then
        if ! pv "$PLYMOUTH_THEME_ARCHIVE" \
                | sudo tar -xJf - -C "$PLYMOUTH_THEME_DEST/$PLYMOUTH_THEME_NAME"; then
            warn "Failed to extract Plymouth theme archive."
            PLYMOUTH_SKIPPED=1
        fi
    else
        if ! sudo tar -xJf "$PLYMOUTH_THEME_ARCHIVE" \
                -C "$PLYMOUTH_THEME_DEST/$PLYMOUTH_THEME_NAME"; then
            warn "Failed to extract Plymouth theme archive."
            PLYMOUTH_SKIPPED=1
        fi
    fi

    (( PLYMOUTH_SKIPPED )) || ok "Plymouth theme extracted."
fi

# Ensure the plymouth hook is present before the single mkinitcpio regen.
if (( ! PLYMOUTH_SKIPPED )) && [[ -f "$MKINITCPIO_CONF" ]]; then
    if grep -Eq '^[[:space:]]*HOOKS=.*\bplymouth\b' "$MKINITCPIO_CONF"; then
        ok "Plymouth hook already present."
    else
        log "Adding 'plymouth' to mkinitcpio HOOKS..."
        sudo cp -- "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak.$(date +%s)"

        # Insert plymouth right after 'udev' or, if the systemd hook model is
        # in use, right after 'systemd'. Preserves the rest of the order.
        if sudo sed -i -E \
              's/^(HOOKS=\([^)]*\b)(udev|systemd)(\b[^)]*\))/\1\2 plymouth\3/' \
              "$MKINITCPIO_CONF" &&
           grep -Eq '^[[:space:]]*HOOKS=.*\bplymouth\b' "$MKINITCPIO_CONF"; then
            ok "Plymouth hook added."
        else
            warn "Could not patch HOOKS automatically."
            warn "Add 'plymouth' to $MKINITCPIO_CONF manually, then run:"
            warn "    sudo mkinitcpio -P"
        fi
    fi
fi

# Setting the theme with -R triggers exactly one initramfs regeneration.
if (( ! PLYMOUTH_SKIPPED )); then
    log "Applying Plymouth theme '$PLYMOUTH_THEME_NAME' (regenerates initramfs)..."
    if sudo plymouth-set-default-theme -R "$PLYMOUTH_THEME_NAME"; then
        ok "Plymouth theme applied."
    else
        warn "Failed to set Plymouth theme."
    fi
fi

# -----------------------------------------------------------------------------
# 3. GRUB theme (optional — GRUB may not be present on a fresh Arch system)
# -----------------------------------------------------------------------------
log "[3/3] Configuring GRUB theme (only if GRUB is installed)..."

if ! command -v grub-mkconfig >/dev/null 2>&1; then
    warn "GRUB is not installed — skipping GRUB theme configuration."
    echo ""
    ok "Boot theme setup finished (Plymouth only)."
    exit 0
fi

if [[ ! -f "$GRUB_CFG" ]]; then
    warn "$GRUB_CFG not found — skipping GRUB theme configuration."
    echo ""
    ok "Boot theme setup finished (Plymouth only)."
    exit 0
fi

if [[ ! -d "$GRUB_THEME_SRC" ]]; then
    warn "GRUB theme source not found: $GRUB_THEME_SRC — skipping GRUB theme."
    exit 0
fi

sudo mkdir -p "$GRUB_THEME_DEST"
if ! sudo cp -r "$GRUB_THEME_SRC/." "$GRUB_THEME_DEST/"; then
    warn "Failed to copy GRUB theme — skipping GRUB configuration."
    exit 0
fi
ok "GRUB theme copied to $GRUB_THEME_DEST."

sudo cp -- "$GRUB_CFG" "${GRUB_CFG}.bak.$(date +%s)"

# GRUB_THEME (idempotent).
if grep -q '^GRUB_THEME=' "$GRUB_CFG"; then
    sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$GRUB_THEME_DEST/theme.txt\"|" "$GRUB_CFG"
else
    printf 'GRUB_THEME="%s/theme.txt"\n' "$GRUB_THEME_DEST" \
        | sudo tee -a "$GRUB_CFG" >/dev/null
fi

# Ensure quiet + splash in GRUB_CMDLINE_LINUX_DEFAULT without duplicating.
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_CFG"; then
    current="$(sed -n 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/\1/p' "$GRUB_CFG")"
    new="$current"
    [[ " $new " == *" quiet "*  ]] || new="$new quiet"
    [[ " $new " == *" splash "* ]] || new="$new splash"
    new="${new#"${new%%[![:space:]]*}"}"
    sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$new\"|" "$GRUB_CFG"
else
    printf 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"\n' | sudo tee -a "$GRUB_CFG" >/dev/null
fi
ok "GRUB configuration updated."

# Conventional GRUB config path — do NOT infer from /boot/efi.
GRUB_OUT="/boot/grub/grub.cfg"
if sudo grub-mkconfig -o "$GRUB_OUT"; then
    ok "GRUB config regenerated at $GRUB_OUT."
else
    warn "grub-mkconfig failed."
fi

echo ""
ok "Boot theme setup complete."
echo "   → Reboot to see the Plymouth splash and GRUB theme."
#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  setup_boot_themes.sh — Plymouth splash + GRUB theme installer
# =============================================================================

log()  { echo "[ + ] $*"; }
ok()   { echo " ✓  $*"; }
warn() { echo " ⚠  $*" >&2; }
die()  { echo " ✗  $*" >&2; exit 1; }

trap 'die "Unexpected error on line $LINENO."' ERR

# -----------------------------------------
# Configuration
# -----------------------------------------
PLYMOUTH_THEME_NAME="rings"
PLYMOUTH_THEME_DIR="$HOME/base-dot/Patches/plymouth-themes"
PLYMOUTH_THEME_ARCHIVE="$PLYMOUTH_THEME_DIR/$PLYMOUTH_THEME_NAME.tar.xz"
PLYMOUTH_THEME_DEST="/usr/share/plymouth/themes"

GRUB_THEME_NAME="Sekiro_theme"
GRUB_THEME_SRC="$HOME/base-dot/Patches/grub-themes/$GRUB_THEME_NAME"
GRUB_THEME_DEST="/boot/grub/themes/$GRUB_THEME_NAME"

GRUB_CFG="/etc/default/grub"
GRUB_CFG_BAK="/etc/default/grub.bak.$(date +%s)"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
MKINITCPIO_CONF_BAK="/etc/mkinitcpio.conf.bak.$(date +%s)"

echo "=== Boot Theme Installer ==="

# -----------------------------------------
# 1. Install Plymouth
# -----------------------------------------
log "[1/6] Installing Plymouth..."
if pacman -Qi plymouth &>/dev/null; then
  ok "Plymouth already installed."
else
  sudo pacman -S --noconfirm plymouth \
    || die "Failed to install Plymouth."
  ok "Plymouth installed."
fi

# -----------------------------------------
# 1b. Extract Plymouth theme archive
# -----------------------------------------
log "[1b] Extracting Plymouth theme '$PLYMOUTH_THEME_NAME'..."

[[ -f "$PLYMOUTH_THEME_ARCHIVE" ]] \
  || die "Archive not found: $PLYMOUTH_THEME_ARCHIVE"

sudo mkdir -p "$PLYMOUTH_THEME_DEST/$PLYMOUTH_THEME_NAME"

if command -v pv >/dev/null 2>&1; then
  pv "$PLYMOUTH_THEME_ARCHIVE" | sudo tar -xJf - -C "$PLYMOUTH_THEME_DEST/$PLYMOUTH_THEME_NAME" \
    || die "Failed to extract Plymouth theme archive."
else
  warn "'pv' not found — extracting without progress bar."
  sudo tar -xJf "$PLYMOUTH_THEME_ARCHIVE" -C "$PLYMOUTH_THEME_DEST/$PLYMOUTH_THEME_NAME" \
    || die "Failed to extract Plymouth theme archive."
fi

ok "Plymouth theme extracted."

# -----------------------------------------
# 2. Set Plymouth theme
# -----------------------------------------
log "[2/6] Setting Plymouth theme to '$PLYMOUTH_THEME_NAME'..."

[[ -d "$PLYMOUTH_THEME_DEST/$PLYMOUTH_THEME_NAME" ]] \
  || die "Plymouth theme directory missing after extraction: $PLYMOUTH_THEME_DEST/$PLYMOUTH_THEME_NAME"

sudo plymouth-set-default-theme -R "$PLYMOUTH_THEME_NAME" \
  || die "Failed to set Plymouth theme."
ok "Plymouth theme set."

# -----------------------------------------
# 2b. Ensure Plymouth hook in mkinitcpio
# -----------------------------------------
log "[2b] Ensuring Plymouth hook is in mkinitcpio.conf..."

sudo cp "$MKINITCPIO_CONF" "$MKINITCPIO_CONF_BAK"
ok "mkinitcpio.conf backed up to $MKINITCPIO_CONF_BAK"

if grep -q 'plymouth' "$MKINITCPIO_CONF"; then
  ok "Plymouth hook already present in mkinitcpio.conf."
else
  # Insert 'plymouth' right after 'base udev'
  if grep -q 'base udev' "$MKINITCPIO_CONF"; then
    sudo sed -i 's/\(HOOKS=.*base udev\)/\1 plymouth/' "$MKINITCPIO_CONF" \
      || die "Failed to patch mkinitcpio.conf."
    ok "Plymouth hook added to HOOKS."
  else
    warn "Could not locate 'base udev' in HOOKS — please add 'plymouth' manually to $MKINITCPIO_CONF"
  fi
fi

log "Rebuilding initramfs (this may take a moment)..."
sudo mkinitcpio -P \
  || die "mkinitcpio rebuild failed."
ok "Initramfs rebuilt."

# -----------------------------------------
# 3. Install GRUB theme
# -----------------------------------------
log "[3/6] Installing GRUB theme '$GRUB_THEME_NAME'..."

[[ -d "$GRUB_THEME_SRC" ]] \
  || die "GRUB theme source not found: $GRUB_THEME_SRC"

sudo mkdir -p "$GRUB_THEME_DEST"
sudo cp -r "$GRUB_THEME_SRC/." "$GRUB_THEME_DEST/" \
  || die "Failed to copy GRUB theme."
ok "GRUB theme copied to $GRUB_THEME_DEST."

# -----------------------------------------
# 4. Update GRUB config
# -----------------------------------------
log "[4/6] Updating GRUB configuration..."

sudo cp "$GRUB_CFG" "$GRUB_CFG_BAK"
ok "GRUB config backed up to $GRUB_CFG_BAK"

# Set GRUB_THEME
if grep -q '^GRUB_THEME=' "$GRUB_CFG"; then
  sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$GRUB_THEME_DEST/theme.txt\"|" "$GRUB_CFG"
else
  echo "GRUB_THEME=\"$GRUB_THEME_DEST/theme.txt\"" | sudo tee -a "$GRUB_CFG" >/dev/null
fi
ok "GRUB_THEME set."

# Ensure quiet splash in kernel params (avoid duplicating if already present)
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_CFG"; then
  current_params=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_CFG" | sed 's/GRUB_CMDLINE_LINUX_DEFAULT=//;s/"//g')
  new_params="$current_params"
  echo "$current_params" | grep -qw 'quiet'  || new_params="$new_params quiet"
  echo "$current_params" | grep -qw 'splash' || new_params="$new_params splash"
  new_params="${new_params#"${new_params%%[![:space:]]*}"}"  # trim leading spaces
  sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$new_params\"|" "$GRUB_CFG"
else
  echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' | sudo tee -a "$GRUB_CFG" >/dev/null
fi
ok "Kernel params updated."

# -----------------------------------------
# 5. Regenerate GRUB config
# -----------------------------------------
log "[5/6] Regenerating GRUB config..."

# Detect UEFI vs BIOS
GRUB_OUT="/boot/grub/grub.cfg"
if [[ -d /boot/efi ]]; then
  # Try to find UEFI grub.cfg dynamically
  UEFI_CFG=$(find /boot/efi -name 'grub.cfg' 2>/dev/null | head -1 || true)
  if [[ -n "$UEFI_CFG" ]]; then
    log "UEFI system detected — writing to $UEFI_CFG"
    GRUB_OUT="$UEFI_CFG"
  else
    warn "UEFI directory found but no grub.cfg located — falling back to $GRUB_OUT"
  fi
fi

sudo grub-mkconfig -o "$GRUB_OUT" \
  || die "grub-mkconfig failed."
ok "GRUB config regenerated at $GRUB_OUT."

# -----------------------------------------
# 6. Done
# -----------------------------------------
echo ""
ok "[6/6] Boot themes installed and configured."
echo "   → Reboot to see Plymouth splash and GRUB theme."

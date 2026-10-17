#!/usr/bin/env bash
set -Eeuo pipefail

# =============================================================================
#  setup_kernels.sh — Chaotic-AUR repo + CachyOS/XanMod kernels
# =============================================================================
#  Adds the Chaotic-AUR binary repository (with its keyring) and installs:
#
#      linux-cachyos-bore            linux-cachyos-bore-headers
#      linux-xanmod-edge-x64v3       linux-xanmod-edge-x64v3-headers
#
#  Opt-in. Third-party repository. Chaotic-AUR uses the standard pacman
#  SigLevel (Required DatabaseOptional), so package-signature verification
#  is preserved — but packages are not maintained by Arch Linux.
#
#  Enable with:
#      ENABLE_CHAOTIC_AUR=1 ./setup.sh
# =============================================================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

ENABLE_CHAOTIC_AUR="${ENABLE_CHAOTIC_AUR:-0}"

echo "=== Chaotic-AUR + Kernel Setup ==="

if [[ "$ENABLE_CHAOTIC_AUR" != "1" ]]; then
    warn "Chaotic-AUR is disabled by default."
    warn "Set ENABLE_CHAOTIC_AUR=1 to enable it and install:"
    printf '    %s\n' \
        linux-cachyos-bore \
        linux-cachyos-bore-headers \
        linux-xanmod-edge-x64v3 \
        linux-xanmod-edge-x64v3-headers
    exit 0
fi

# ---- Configuration -----------------------------------------------------------
CHAOTIC_KEY_ID="3056513887B78AEB"
CHAOTIC_KEYSERVER="keyserver.ubuntu.com"
CHAOTIC_URL="https://cdn-mirror.chaotic.cx/chaotic-aur"
CHAOTIC_KEYRING_URL="$CHAOTIC_URL/chaotic-keyring.pkg.tar.zst"
CHAOTIC_MIRRORLIST_URL="$CHAOTIC_URL/chaotic-mirrorlist.pkg.tar.zst"

PACMAN_CONF="/etc/pacman.conf"
CHAOTIC_SECTION="[chaotic-aur]"
CHAOTIC_MIRRORLIST_FILE="/etc/pacman.d/chaotic-mirrorlist"

# ---- CPU check for the x64v3 kernels -----------------------------------------
# x64v3 implies AVX2. Booting a kernel the CPU can't execute is a hard fail,
# so we skip those packages rather than risk an unbootable system.
cpu_supports_x64v3() {
    grep -qw avx2 /proc/cpuinfo
}

# ---- Keyring -----------------------------------------------------------------
install_chaotic_keyring() {
    log "Installing Chaotic-AUR keyring..."

    if pacman -Qq chaotic-keyring >/dev/null 2>&1 \
       && pacman -Qq chaotic-mirrorlist >/dev/null 2>&1; then
        ok "Chaotic-AUR keyring and mirrorlist already installed."
        return 0
    fi

    log "Fetching Chaotic-AUR signing key $CHAOTIC_KEY_ID..."
    if ! sudo pacman-key --recv-key "$CHAOTIC_KEY_ID" \
            --keyserver "$CHAOTIC_KEYSERVER"; then
        warn "Failed to receive Chaotic-AUR signing key."
        return 1
    fi

    if ! sudo pacman-key --lsign-key "$CHAOTIC_KEY_ID"; then
        warn "Failed to locally sign Chaotic-AUR signing key."
        return 1
    fi
    ok "Chaotic-AUR signing key trusted."

    log "Installing chaotic-keyring and chaotic-mirrorlist packages..."
    if ! sudo pacman -U --needed --noconfirm \
            "$CHAOTIC_KEYRING_URL" "$CHAOTIC_MIRRORLIST_URL"; then
        warn "Failed to install chaotic keyring / mirrorlist packages."
        return 1
    fi
    ok "Chaotic-AUR keyring and mirrorlist installed."
}

# ---- pacman.conf -------------------------------------------------------------
enable_chaotic_repo() {
    if grep -qxF "$CHAOTIC_SECTION" "$PACMAN_CONF"; then
        ok "chaotic-aur section already present in $PACMAN_CONF."
        return 0
    fi

    if [[ ! -f "$CHAOTIC_MIRRORLIST_FILE" ]]; then
        warn "chaotic-mirrorlist file missing: $CHAOTIC_MIRRORLIST_FILE"
        return 1
    fi

    log "Adding $CHAOTIC_SECTION to $PACMAN_CONF..."
    sudo cp -- "$PACMAN_CONF" "${PACMAN_CONF}.bak.$(date +%s)"

    sudo tee -a "$PACMAN_CONF" >/dev/null <<'EOF'

# Chaotic-AUR — third-party binary repository.
# Mirrorlist and keyring are managed via the chaotic-* packages.
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

    ok "chaotic-aur section added."
}

# ---- Kernels -----------------------------------------------------------------
install_kernels() {
    local -a wanted=()

    # cachyos-bore runs on any x86_64 CPU.
    wanted+=(
        linux-cachyos-bore
        linux-cachyos-bore-headers
    )

    # xanmod-edge-x64v3 requires AVX2. Skip both packages if unsupported.
    if cpu_supports_x64v3; then
        ok "CPU supports AVX2 — x64v3 kernels OK."
        wanted+=(
            linux-xanmod-edge-x64v3
            linux-xanmod-edge-x64v3-headers
        )
    else
        warn "CPU does not advertise AVX2 — skipping linux-xanmod-edge-x64v3."
    fi

    ((${#wanted[@]})) || return 0

    log "Installing kernels from Chaotic-AUR:"
    printf '    %s\n' "${wanted[@]}"

    if sudo pacman -S --needed --noconfirm "${wanted[@]}"; then
        ok "Kernels installed."
    else
        warn "Kernel installation failed."
        return 1
    fi
}

# ---- Bootloader --------------------------------------------------------------
refresh_bootloader() {
    if command -v grub-mkconfig >/dev/null 2>&1 \
       && [[ -f /boot/grub/grub.cfg ]]; then
        log "Regenerating GRUB config so new kernels appear..."
        if sudo grub-mkconfig -o /boot/grub/grub.cfg; then
            ok "GRUB regenerated."
        else
            warn "grub-mkconfig failed — regenerate before rebooting."
        fi
        return 0
    fi

    if command -v bootctl >/dev/null 2>&1; then
        log "systemd-boot detected — verify that boot entries / UKIs are updated."
        return 0
    fi

    warn "No supported bootloader detected — regenerate it before rebooting."
}

# ---- Run ---------------------------------------------------------------------
install_chaotic_keyring || die "Chaotic-AUR keyring setup failed."
enable_chaotic_repo      || die "Could not enable the chaotic-aur repository."

log "Refreshing package databases..."
sudo pacman -Sy --noconfirm || die "pacman -Sy failed."

install_kernels || exit 1
refresh_bootloader || true

echo ""
ok "Chaotic-AUR kernel setup complete."
echo "   → Reboot to boot into a newly installed kernel."
echo "   → Pick a kernel at the bootloader menu (or configure the default)."

#!/usr/bin/env bash
set -Eeuo pipefail

# =============================================================================
#  setup.sh — Arch Linux post-install bootstrapper
# =============================================================================
#  Orchestrates: preflight → system update → bootstrap → packages → dotfiles →
#  helpers → summary. Helper scripts live in ./_helpers/ and are independently
#  runnable.
#
#  Environment variables:
#    NONINTERACTIVE=1                 Suppress AUR prompts.
#    ENABLE_THIRD_PARTY_STEAM_LIBS=1  Enable the third-party steam-libs repo
#                                     (disabled by default; weakens signature
#                                     verification).
#    DOT_REPO=<url>                   Override dotfiles repo.
#    DOT_DIR=<path>                   Override dotfiles checkout path.
#    INSTALL_GAMING_32BIT=1           Install the large 32-bit compat set.
# =============================================================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HELPER_DIR="$SCRIPT_DIR/_helpers"

# shellcheck source=_helpers/common.sh
source "$HELPER_DIR/common.sh"

# ---- Configuration -----------------------------------------------------------
DOT_REPO="${DOT_REPO:-https://github.com/0LA-X/4.0.git}"
DOT_DIR="${DOT_DIR:-$HOME/4.0}"

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/arch-bootstrap"
LOG_FILE="$LOG_DIR/setup.log"

NONINTERACTIVE="${NONINTERACTIVE:-0}"
ENABLE_THIRD_PARTY_STEAM_LIBS="${ENABLE_THIRD_PARTY_STEAM_LIBS:-0}"
INSTALL_GAMING_32BIT="${INSTALL_GAMING_32BIT:-0}"

export DOT_REPO DOT_DIR
export NONINTERACTIVE ENABLE_THIRD_PARTY_STEAM_LIBS INSTALL_GAMING_32BIT

FAILED_STAGES=()

# ---- Package lists -----------------------------------------------------------

BOOTSTRAP_PKGS=(
    base
    base-devel
    git
)

# Official repositories only.
REPO_PKGS=(
    # Core dev tools
    cmake clang lld llvm
    gcc gdb meson ninja
    uv rustup lldb
    nodejs-lts-iron npm
    python python-pip python-virtualenv
    stow tree-sitter-cli pkgfile

    # Utilities
    btop nvtop curl wget
    duf dysk
    fd ripgrep ncdu fzf jq pv
    man-db rsync tldr qbittorrent
    tmux neovim uwsm zoxide

    # Archiving
    7zip cdrtools squashfs-tools
    unarchiver unzip unrar

    # System tools
    samba xdg-user-dirs ufw
    acpi acpid brightnessctl
    udisks2 udiskie usbutils
    cifs-utils cpu-x cpupower tuned-ppd
    ddcutil geoclue gammastep polkit-gnome

    # Terminal apps
    kitty ghostty trash-cli
    eza fastfetch chafa

    # Media
    ffmpeg ffmpegthumbnailer
    imagemagick mpv mpv-mpris
    playerctl portmidi
    sdl2_image sdl2_mixer sdl2_ttf

    # Hyprland ecosystem
    hyprland hypridle hyprlock
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    loupe papers

    # File managers
    nautilus yazi

    # Fonts
    noto-fonts-emoji
    ttf-cascadia-code-nerd
    ttf-nerd-fonts-symbols
)

# AUR only — verify before adding new entries.
AUR_PKGS=(
    # Themes & appearance
    adw-gtk-theme
    nwg-look
    pokego-bin
    impala

    # Nautilus add-ons
    nautilus-admin-gtk4
    nautilus-image-converter

    # Apps
    bazarr
    spotify
    zen-browser-bin
    terraria-server
    flaresolverr-bin
    suwayomi-server-bin
)

# ---- Stages ------------------------------------------------------------------

show_header() {
cat <<'EOF'

     ██╗ ██╗███╗   ██╗██╗  ██╗
     ██║███║████╗  ██║╚██╗██╔╝
     ██║╚██║██╔██╗ ██║ ╚███╔╝
██   ██║ ██║██║╚██╗██║ ██╔██╗
╚█████╔╝ ██║██║ ╚████║██╔╝ ██╗
 ╚════╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝

EOF
}

check_environment() {
    log "Running pre-flight checks..."
    require_nonroot
    require_cmd pacman
    require_sudo
    ok "Pre-flight checks passed."
}

check_network() {
    log "Checking network connectivity..."
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSIL --max-time 10 https://archlinux.org >/dev/null; then
            ok "Network reachable."
            return 0
        fi
        die "Could not reach archlinux.org."
    fi
    warn "curl not available; skipping HTTP check — pacman will fail loudly if offline."
}

system_update() {
    log "Updating system packages..."
    sudo pacman -Syu --noconfirm || die "System update failed."
    ok "System updated."
}

bootstrap_packages() {
    log "Installing bootstrap packages..."
    sudo pacman -S --needed --noconfirm "${BOOTSTRAP_PKGS[@]}" \
        || die "Failed to install bootstrap packages."
    ok "Bootstrap packages installed."
}

install_yay() {
    log "Installing yay from AUR..."

    local build_dir
    build_dir="$(mktemp -d)"

    if ! git clone https://aur.archlinux.org/yay.git "$build_dir/yay"; then
        rm -rf "$build_dir"
        die "Failed to clone yay repo."
    fi

    if ( cd "$build_dir/yay" && makepkg -si --noconfirm ); then
        rm -rf "$build_dir"
        ok "yay installed."
    else
        rm -rf "$build_dir"
        die "makepkg failed for yay."
    fi
}

ensure_yay() {
    if command -v yay >/dev/null 2>&1; then
        ok "yay already installed ($(yay --version | head -1))."
    else
        install_yay
    fi
}

install_repo_packages() {
    log "Installing official repository packages..."
    sudo pacman -S --needed --noconfirm "${REPO_PKGS[@]}" \
        || die "Official package installation failed."
    ok "Official packages installed."
}

install_aur_packages() {
    ((${#AUR_PKGS[@]})) || return 0

    log "Installing AUR packages..."
    if (( NONINTERACTIVE )); then
        yay -S --needed --noconfirm "${AUR_PKGS[@]}" \
            || die "AUR package installation failed."
    else
        yay -S --needed "${AUR_PKGS[@]}" \
            || die "AUR package installation failed."
    fi
    ok "AUR packages installed."
}

# ---- Dotfiles ----------------------------------------------------------------

setup_dotfiles() {
    log "Setting up dotfiles from $DOT_REPO..."

    if [[ -d "$DOT_DIR/.git" ]]; then
        log "Dotfiles repo already exists — attempting fast-forward pull."
        git -C "$DOT_DIR" pull --ff-only \
            || warn "Could not fast-forward — manual merge may be required."
        return 0
    fi

    if [[ -e "$DOT_DIR" ]]; then
        die "$DOT_DIR exists but is not a git repository — refusing to overwrite."
    fi

    git clone "$DOT_REPO" "$DOT_DIR" \
        || die "Failed to clone dotfiles repository."
    ok "Dotfiles cloned to $DOT_DIR."
}

# Recursively clear stow conflicts by backing up the exact conflicting paths.
# Never rm -rf a parent directory just because a child conflicts.
clear_stow_conflicts() {
    local src="$1" dest="$2" backup_root="$3"

    shopt -s nullglob dotglob
    local -a entries=("$src"/*)
    shopt -u nullglob dotglob

    local entry name s d
    for entry in "${entries[@]}"; do
        name="$(basename "$entry")"
        s="$entry"
        d="$dest/$name"

        # Existing symlink: remove it so stow can recreate it.
        if [[ -L "$d" ]]; then
            rm -- "$d" && log "  Removed existing symlink: $d"
            continue
        fi

        # Nothing at the target — nothing to clear.
        [[ -e "$d" ]] || continue

        # Both are directories: descend.
        if [[ -d "$s" && -d "$d" ]]; then
            clear_stow_conflicts "$s" "$d" "$backup_root"
            continue
        fi

        # Real file/dir that conflicts — move it aside.
        local rel="${d#"$HOME"/}"
        local dst="$backup_root/$rel"
        mkdir -p "$(dirname "$dst")"
        if mv -- "$d" "$dst"; then
            log "  Backed up conflicting path: $d → $dst"
        else
            warn "  Failed to move conflicting path: $d"
        fi
    done
}

stow_dotfiles() {
    log "Stowing dotfiles..."
    require_cmd stow

    mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share"

    local backup_root="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_root"

    local stow_targets=(Config Local zsh)
    local target
    for target in "${stow_targets[@]}"; do
        if [[ ! -d "$DOT_DIR/$target" ]]; then
            warn "Stow target '$target' not found in $DOT_DIR — skipping."
            continue
        fi

        clear_stow_conflicts "$DOT_DIR/$target" "$HOME" "$backup_root"

        if stow -d "$DOT_DIR" -t "$HOME" "$target"; then
            ok "Stowed '$target'."
        else
            die "stow failed for '$target'."
        fi
    done

    ok "Config backup for this run: $backup_root"
}

# ---- Helpers -----------------------------------------------------------------

run_helpers() {
    run_helper "TMUX & TPM"        "$HELPER_DIR/tpm.sh"              || FAILED_STAGES+=("TMUX & TPM")
    run_helper "ZSH"               "$HELPER_DIR/setup_zsh.sh"         || FAILED_STAGES+=("ZSH")
    run_helper "Audio & Bluetooth" "$HELPER_DIR/setup_audio.sh"       || FAILED_STAGES+=("Audio & Bluetooth")
    run_helper "Gaming"            "$HELPER_DIR/setup_game.sh"        || FAILED_STAGES+=("Gaming")
    run_helper "Boot Themes"       "$HELPER_DIR/setup_boot_themes.sh" || FAILED_STAGES+=("Boot Themes")
}

# ---- Summary -----------------------------------------------------------------

print_summary() {
    printf '\n========================================\n'
    printf ' Arch Bootstrap Summary\n'
    printf '========================================\n\n'

    if ((${#FAILED_STAGES[@]} == 0)); then
        ok "All stages completed successfully."
    else
        warn "Some stages failed:"
        printf '  - %s\n' "${FAILED_STAGES[@]}"
    fi

    printf '\nManual actions:\n'
    printf '  - Log out and back in to refresh group membership.\n'
    printf '  - Reboot before testing any newly configured boot theme.\n'

    printf '\nLog:\n  %s\n' "$LOG_FILE"
    printf '========================================\n'
}

# ---- Main --------------------------------------------------------------------

main() {
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
    # Tee all output (this shell and children) into the log file.
    exec > >(tee -a "$LOG_FILE") 2>&1

    show_header

    check_environment
    check_network

    system_update
    bootstrap_packages
    ensure_yay

    install_repo_packages
    install_aur_packages

    setup_dotfiles
    stow_dotfiles

    run_helpers

    print_summary
}

main "$@"
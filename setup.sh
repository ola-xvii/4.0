#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  setup.sh — Arch Linux dotfile & package bootstrapper
# =============================================================================

DOT_REPO="https://github.com/0LA-X/4.0.git"
DOT_DIR="$HOME/4.0"
SCR_DIR="$DOT_DIR/Scripts/_helpers"
YAY_DIR="/tmp/yay"

LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/setup.log"
mkdir -p "$(dirname "$LOG_FILE")"

# -----------------------------------------
# Logging
# -----------------------------------------
log()  { local ts; ts=$(date '+%H:%M:%S'); echo "[$ts]  $*" | tee -a "$LOG_FILE"; }
ok()   { local ts; ts=$(date '+%H:%M:%S'); echo "[$ts] ✓ $*" | tee -a "$LOG_FILE"; }
warn() { local ts; ts=$(date '+%H:%M:%S'); echo "[$ts] ⚠  $*" | tee -a "$LOG_FILE" >&2; }
die()  { local ts; ts=$(date '+%H:%M:%S'); echo "[$ts] ✗ $*" | tee -a "$LOG_FILE" >&2; exit 1; }

# -----------------------------------------
# Trap
# -----------------------------------------
trap 'die "Unexpected error on line $LINENO — check $LOG_FILE for details."' ERR

# -----------------------------------------
# Pacman Packages
# -----------------------------------------
PACMAN_PKGS=(
  # ---- Core Dev Tools ----
  cmake clang lld llvm
  gcc gdb meson ninja
  uv rustup lldb git 
  nodejs-lts-iron npm
  python python-pip python-uv python-virtualenv
  stow tree-sitter-cli pkgfile

  # ---- Utilities ----
  btop nvtop curl wget
  duf dysk impala
  fd ripgrep ncdu fzf jq pv
  man-db rsync tldr qbittorrent
  tmux nvim uwsm zoxide

  # ---- File Archiving ----
  7zip cdrtools squashfs-tools
  unarchiver unzip unrar 

  # ---- System Tools ----
  samba xdg-user-dirs ufw
  acpi acpid brightnessctl
  udisks2 udiskie usbutils
  cifs-utils cpu-x cpupower tuned-ppd
  ddcutil geoclue gammastep polkit-gnome

  # ---- Terminal Apps ----
  kitty ghostty trash-cli
  eza fastfetch chafa 
  
  # ---- Media ----
  ffmpeg ffmpegthumbnailer
  imagemagick mpv mpv-mpris
  playerctl portmidi
  sdl2_image sdl2_mixer sdl2_ttf

  # ---- Hyprland Ecosystem ----
  hyprland hypridle hyprlock
  xdg-desktop-portal-gtk
  xdg-desktop-portal-hyprland
  loupe papers

  # ---- File Managers ----
  nautilus yazi

  # ---- Fonts ----
  noto-fonts-emoji
  ttf-cascadia-code-nerd
  ttf-nerd-fonts-symbols
)

# -----------------------------------------
# AUR Packages
# -----------------------------------------
AUR_PKGS=(
  # ---- Themes & Appearance ----
  adw-gtk-theme nwg-look pokego-bin

  # ---- Nautilus Addons ----
  nautilus-admin-gtk4
  nautilus-image-converter
  nautilus-share gvfs-mtp

  # ---- Apps ----
  bazarr breezy file-roller
  spotify libreoffice-fresh
  zen-browser-bin terraria-server 
  flaresolverr-bin  suwayomi-server-bin
)


# -----------------------------------------
# Header
# -----------------------------------------
show_header() {
cat << "EOF"

     ██╗ ██╗███╗   ██╗██╗  ██╗
     ██║███║████╗  ██║╚██╗██╔╝
     ██║╚██║██╔██╗ ██║ ╚███╔╝ 
██   ██║ ██║██║╚██╗██║ ██╔██╗ 
╚█████╔╝ ██║██║ ╚████║██╔╝ ██╗
 ╚════╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝

EOF
  log "Log file: $LOG_FILE"
}


# -----------------------------------------
# Pre-flight Checks
# -----------------------------------------
check_system() {
  log "Running pre-flight checks..."

  command -v pacman >/dev/null 2>&1 \
    || die "pacman not found. This script is for Arch Linux only."

  # Retry ping up to 3 times to handle transient network blips
  local attempts=3
  for ((i=1; i<=attempts; i++)); do
    if ping -c 1 -W 3 archlinux.org >/dev/null 2>&1; then
      ok "Network reachable."
      return 0
    fi
    warn "Ping attempt $i/$attempts failed. Retrying..."
    sleep 2
  done
  die "No internet connection after $attempts attempts."
}


# -----------------------------------------
# System Update
# -----------------------------------------
system_update() {
  log "Updating system packages..."
  sudo pacman -Syu --noconfirm \
    || die "System update failed."
  sudo pacman -S --needed --noconfirm git base base-devel \
    || die "Failed to install base packages."
  ok "System updated."
}


# -----------------------------------------
# Dotfiles
# -----------------------------------------
setup_dotfiles() {
  log "Setting up dotfiles from $DOT_REPO..."

  if [[ ! -d "$DOT_DIR" ]]; then
    git clone "$DOT_REPO" "$DOT_DIR" \
      || die "Failed to clone dotfiles repo."
    ok "Dotfiles cloned to $DOT_DIR."
  else
    log "Dotfiles directory exists. Pulling latest changes..."
    git -C "$DOT_DIR" pull --ff-only \
      || warn "Could not fast-forward dotfiles repo — may need manual merge at $DOT_DIR."
  fi
}


# -----------------------------------------
# yay (AUR helper)
# -----------------------------------------
install_yay() {
  log "Installing yay from AUR..."

  [[ -d "$YAY_DIR" ]] && rm -rf "$YAY_DIR"

  git clone https://aur.archlinux.org/yay.git "$YAY_DIR" \
    || die "Failed to clone yay repo."

  (
    cd "$YAY_DIR"
    makepkg -si --noconfirm \
      || die "makepkg failed for yay."
  )

  rm -rf "$YAY_DIR"
  ok "yay installed."
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    ok "yay already installed ($(yay --version | head -1))."
  else
    install_yay
  fi
}


# -----------------------------------------
# Package Installation
# -----------------------------------------
install_pkgs() {
  log "Installing pacman packages..."
  sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" \
    || die "pacman package installation failed."
  ok "Pacman packages installed."

  log "Installing AUR packages..."
  yay -S --needed --noconfirm "${AUR_PKGS[@]}" \
    || die "AUR package installation failed."
  ok "AUR packages installed."
}


# -----------------------------------------
# Dotfile Stow
# -----------------------------------------

# Back up ~/.config and remove any dirs/files that stow will try to symlink,
# so stow never hits a "conflicts with existing target" error.
backup_and_clear_conflicts() {
  local backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/config-backups"
  local backup_dir="$backup_root/$(date +%Y%m%d_%H%M%S)"

  log "Backing up ~/.config to $backup_dir ..."
  mkdir -p "$backup_dir"
  cp -a "$HOME/.config/*" "$backup_dir/" \
    || die "Failed to back up ~/.config — aborting to protect your data."
  ok "Backup saved to $backup_dir"

  # Walk every file/dir that stow would place under $HOME and remove the
  # real counterpart so stow can create its symlink cleanly.
  log "Removing conflicting targets in $HOME ..."

  local stow_targets=(Config Local zsh)
  for target in "${stow_targets[@]}"; do
    local src="$DOT_DIR/$target"
    [[ -d "$src" ]] || continue

    # find all first-level entries stow would link
    while IFS= read -r -d '' entry; do
      local rel="${entry#"$src"/}"          # path relative to stow package root
      local dest="$HOME/$rel"

      if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ -L "$dest" ]]; then
          log "  Removing existing symlink: $dest"
          rm "$dest"
        elif [[ -d "$dest" ]]; then
          log "  Removing existing directory: $dest"
          rm -rf "$dest"
        else
          log "  Removing existing file: $dest"
          rm -f "$dest"
        fi
      fi
    done < <(find "$src" -mindepth 1 -maxdepth 1 -print0)
  done

  ok "Conflicts cleared."
}

stow_dots() {
  log "Stowing dotfiles..."

  command -v stow >/dev/null 2>&1 \
    || sudo pacman -S --needed --noconfirm stow \
    || die "Failed to install stow."

  mkdir -p "$HOME"/{.config/XX,.local/bin/XY,.local/share/XZ}

  cd "$DOT_DIR" || die "Cannot cd into $DOT_DIR"

  backup_and_clear_conflicts

  # Stow each group separately so one failure doesn't block the rest
  local stow_targets=(Config Local zsh)
  for target in "${stow_targets[@]}"; do
    if [[ -d "$DOT_DIR/$target" ]]; then
      stow -v "$target" --target="$HOME" \
        || die "stow failed for '$target' — check $LOG_FILE for details."
    else
      warn "Stow target '$target' not found in $DOT_DIR — skipping."
    fi
  done

  ok "Dotfiles stowed."
}

# -----------------------------------------
# Helper Scripts
# -----------------------------------------
run_helper() {
  local label="$1"
  local script="$2"

  log "Running helper: $label"

  if [[ ! -f "$script" ]]; then
    warn "Helper script not found: $script — skipping."
    return 0
  fi

  if [[ ! -x "$script" ]] && ! bash --norc -n "$script" 2>/dev/null; then
    warn "Helper script has syntax errors: $script — skipping."
    return 0
  fi

  bash "$script" 2>&1 | tee -a "$LOG_FILE" \
    || warn "$label failed — continuing. Check $LOG_FILE for details."

  ok "$label complete."
}

helper_scripts() {
  run_helper "TMUX & TPM"         "$SCR_DIR/tpm.sh"
  run_helper "ZSH"                "$SCR_DIR/setup_zsh.sh"
  run_helper "Audio & Bluetooth"  "$SCR_DIR/setup_audio.sh"
  run_helper "Boot Themes"        "$SCR_DIR/setup_boot_themes.sh"
}


# -----------------------------------------
# Main
# -----------------------------------------
MAIN() {
  show_header
  check_system
  system_update
  # setup_dotfiles
  ensure_yay
  install_pkgs
 #  stow_dots
  helper_scripts

  ok "Setup complete! Log saved to $LOG_FILE"
}


MAIN

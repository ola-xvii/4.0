#!/usr/bin/env bash
# =============================================================================
#  common.sh — Shared helpers for the Arch bootstrap scripts.
# =============================================================================
#  Sourced by setup.sh and by every script in this directory. Provides
#  consistent logging, environment checks, and small utilities.
# =============================================================================

# ---- Logging -----------------------------------------------------------------
# Respects NO_COLOR and non-tty stderr.
if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
    _C_RESET=$'\033[0m'
    _C_INFO=$'\033[36m'
    _C_OK=$'\033[32m'
    _C_WARN=$'\033[33m'
    _C_ERR=$'\033[31m'
else
    _C_RESET="" _C_INFO="" _C_OK="" _C_WARN="" _C_ERR=""
fi

log()  { printf '%s[*]%s %s\n' "$_C_INFO" "$_C_RESET" "$*"; }
ok()   { printf '%s[+]%s %s\n' "$_C_OK"   "$_C_RESET" "$*"; }
warn() { printf '%s[!]%s %s\n' "$_C_WARN" "$_C_RESET" "$*" >&2; }
die()  { printf '%s[✗]%s %s\n' "$_C_ERR"  "$_C_RESET" "$*" >&2; exit 1; }

# ---- Environment checks ------------------------------------------------------

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

require_nonroot() {
    (( EUID != 0 )) || die "Do not run this script as root."
}

require_sudo() {
    require_cmd sudo
    sudo -v || die "Unable to authenticate with sudo."
}

current_user() {
    printf '%s' "${USER:-$(id -un)}"
}

user_in_group() {
    local group="$1"
    id -nG "$(current_user)" | tr ' ' '\n' | grep -qx "$group"
}

# Idempotent group membership.
add_user_to_group() {
    local group="$1" user="${2:-$(current_user)}"

    if ! getent group "$group" >/dev/null 2>&1; then
        warn "Group '$group' does not exist — skipping."
        return 1
    fi
    if user_in_group "$group"; then
        ok "User already in group '$group'."
        return 0
    fi
    if sudo usermod -aG "$group" "$user"; then
        ok "Added '$user' to group '$group'."
        return 0
    fi
    warn "Failed to add '$user' to group '$group'."
    return 1
}

# ---- Helper runner -----------------------------------------------------------
# Runs a helper script with a syntax check and consistent reporting.
# Never prints a success message after a failed script.
run_helper() {
    local label="$1" script="$2"

    log "Running helper: $label"

    if [[ ! -f "$script" ]]; then
        warn "$label: script not found ($script) — skipping."
        return 1
    fi

    if ! bash -n "$script"; then
        warn "$label: syntax check failed — skipping."
        return 1
    fi

    if bash "$script"; then
        ok "$label complete."
        return 0
    fi

    warn "$label failed."
    return 1
}

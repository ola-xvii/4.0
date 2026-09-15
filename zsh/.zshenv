#[ zsh_History filepath ] 
export HISTFILE="$HOME/.zsh_history"    

export TERMINAL="ghostty"
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"
export SYSTEMD_EDITOR="nvim"
export MANPAGER="nvim +Man!"

#=============
#   PATH
#=============
export CARGO_HOME="$HOME/.local/bin/cargo"
export RUSTUP_HOME="$HOME/.local/bin/rustup"
export BUN_INSTALL="$HOME/.local/bin/bun"

# GOLANG
export GOPATH="$HOME/.local/bin/go" # -- GOLANG PATH
export GOBIN="$HOME/.local/bin/go/bin"

# BUN
export BUN_INSTALL="$HOME/.local/bin/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

#[ PATH - :$HOME/.local/bin/env_01/bin: ]
export PATH="$HOME/.local/bin:$HOME/.local/share/cargo/bin:$GOBIN:$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin/platform-tools:$PATH"

[ -f "$HOME/.local/bin/cargo/env" ] && . "$HOME/.local/bin/cargo/env"
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

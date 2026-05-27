#[ zsh_History filepath ] 
export HISTFILE="$HOME/.zsh_history"    

export TERM='xterm-256color'
export TERMINAL="ghostty"

export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"
export SYSTEMD_EDITOR="nvim"
export MANPAGER="nvim +Man!"

#[ Xcompose IG ¯\_(ツ)_/¯]
# export GTK_IM_MODULE=xim
# export QT_IM_MODULE=xim
# export XMODIFIERS=@im=none

#=============
#   PATH
#=============
#[ PATH - :$HOME/env_01/bin: ]
export CARGO_HOME="$HOME/.local/bin/cargo"
export RUSTUP_HOME="$HOME/.local/bin/rustup"
export GOPATH="$HOME/.local/bin/go" # -- GOLANG PATH
export GOBIN="$HOME/.local/bin/go/bin"

export PATH="$HOME/.local/bin:$HOME/.local/share/cargo/bin:$GOBIN:$PATH"


# . "$HOME/.deno/env"
. "$HOME/.local/bin/cargo/env"

CORN="$HOME/Videos/yt-dlp/._tmp/.corn"
EXTV="/run/media/ola-x/game-drive/Videos/yt-dlp"
EXTD="/run/media/ola-x/game-drive/Videos/yt-dlp/._tmp/.corn"
EXTD="/run/media/ola-x/game-drive/Downloads"

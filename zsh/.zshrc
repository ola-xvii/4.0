#=====================
#  Session bootstrap   
#=====================
if [[ -o interactive ]]; then
  # -- Launch TMUX
  if [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
    tmux attach -t MAIN || tmux new -s MAIN
  fi

  # -- ¯\_(ツ)_/¯
  pokego -r 6,1,5,8,2,7 -no-title -s ## --name eevee --no-title # jigglypuff - eevee - delcatty - charmeleon - [##  # 1,3,5,7]
  # fastfetch
fi

# # -- Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#[ Completions ]
fpath+=~/.zfunc   # Custom-completions

autoload -Uz compinit
compinit -C       # fast, safe if you trust your plugins
# _comp_options+=(globdots)


# ============
#   ZINIT
# ============
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# --> Install zinit Pacman
if [ ! -d "$ZINIT_HOME" ]; then 
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# -- Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


# ============
#   PLUGINS 
# ============
#[Powerlevel10k]
zinit ice depth=1; zinit light romkatv/powerlevel10k

# # -- Starship
# zinit ice as"command" from"gh-r" \
#   atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
#   atpull"%atclone" src"init.zsh"
# zinit light starship/starship

# -- ZVM/zsh-vi-mode
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode

# -- zsh plugins
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting

# -- zsh-autosuggestions
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#E3E4FA"

# -- zsh-history-substring-search
zinit light zsh-users/zsh-history-substring-search
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=#39FF14'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=#0D1117'
#-- -- -- 
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
#-- -- -- 
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# -- Tools (lazy)
zinit snippet OMZL::completion.zsh  
zinit snippet OMZL::directories.zsh

zinit snippet OMZP::zoxide
zinit snippet OMZP::rust
zinit snippet OMZP::systemd
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::command-not-found

# -- Load 
zinit cdreplay -q


# -- Keybinds
for map in emacs viins vicmd; do
  bindkey -M $map '^[[1~' beginning-of-line   # Home
  bindkey -M $map '^[[4~' end-of-line         # End
  bindkey -M $map '^[[3~' delete-char         # Delete

  bindkey -M $map '^[[5~' up-line-or-history
  bindkey -M $map '^[[6~' down-line-or-history
  
  bindkey -M $map '^[[Z' reverse-menu-complete

  bindkey -M $map '^H' backward-kill-word 
  bindkey -M $map '^Z' undo
done


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


#============
#  History
#============
HISTSIZE=8000
SAVEHIST=$HISTSIZE
HISTFILE="$HOME/.zsh_history"
HISTDUP=erase
HIST_STAMPS="dd/mm/yyyy"

setopt APPENDHISTORY
setopt SHAREHISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS


#[Completion styling]
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"


#[Shell integration]
eval "$(zoxide init zsh)"
# eval "$(starship init zsh)"

#==============
#  Aliases
#==============
alias -- -='cd -'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias c='clear'
alias x='exit'

# Listing (eza)
# -- [Check if eza is installed]
if command -v eza >/dev/null; then
  alias l='eza -lh --icons=auto'
  alias ls='eza -G --icons=auto'
  alias lsa='eza -Ga --icons=auto'
  alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
  alias ld='eza -lhD --icons=auto'
  alias lt='eza --icons=auto --tree'
else 
  alias ls='ls --color'
  alias ll='ls -lh --color'
  alias la='ls --color'
fi

# Trash
alias tp='trash-put'

# Editor
alias vi='nvim'
alias vim='sudo nvim'
alias sudo-nvim='sudo env WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR HOME=/root nvim'
alias sudo-vi='sudo env WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR HOME=/root nvim'

# Git
alias ga='git add'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gs='git status'
alias gss='git status -s'
alias gr='git restore'

# Wi-Fi
alias wifilist='nmcli device wifi list'
alias wifiscan='nmcli device wifi list --rescan yes'
alias wificonnect='nmcli device wifi connect --ask'

# System
alias pacman='sudo pacman'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
# alias gparted='sudo -E gparted'

# yt-dlp
alias yt-480='yt-dlp -f "bestvideo[height=480]+bestaudio/best[height=480]"'
alias yt-720='yt-dlp -f "bestvideo[height=720]+bestaudio/best[height=720]"'

# Session
alias exit-user='pkill -TERM -u $USER'
alias logout-user='pkill Hyprland || pkill tmux || loginctl terminate-user $USER'


#==========
#  MISC
#==========
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"

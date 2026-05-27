#=====================================
#[ Start Graphical Session with UWSM ]
#=====================================
# if uwsm check may-start; then
#   exec uwsm start hyprland.desktop
# fi


# -- Env Path
export PATH="$HOME/.local/bin:$HOME/.local/bin/cargo/bin:$GOBIN:$PATH"

# . "$HOME/.deno/env"
. "$HOME/.local/bin/cargo/env"

if [[ -n "$KITTY_WINDOW_ID" ]]; then
    if [[ $(pgrep -u "$USER" -x kitty | wc -l) -eq 1 ]]; then
        fastfetch
    fi
fi

# 1ms
export KEYTIMEOUT=1

# alias
for f in $ZDOTDIR/alias/*.zsh; do source $f; done

# env
# for f in $ZDOTDIR/env/*.zsh; do source $f; done

# path
for f in $ZDOTDIR/path/*.zsh; do source $f; done

# # keybind
# for f in $ZDOTDIR/keybind/*.zsh; do source $f; done

# completion
for f in $ZDOTDIR/completion/*.zsh; do source $f; done

# plugins
for f in $ZDOTDIR/plugins/*.zsh; do source $f; done

eval "$(dircolors -b)"

# tools
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(atuin init zsh)"

function clear-command-line() {
    BUFFER=""
    CURSOR=0
}

zle -N clear-command-line
bindkey '\e' clear-command-line


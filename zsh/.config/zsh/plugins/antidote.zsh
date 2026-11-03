source /usr/share/zsh-antidote/antidote.zsh

antidote load $ZDOTDIR/plugins/plugins.txt

antidote bundle < $ZDOTDIR/plugins/plugins.txt > ~/.zsh_plugins.zsh
source ~/.zsh_plugins.zsh

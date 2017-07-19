if command -v bat &> /dev/null
then
    alias cat='bat --style=plain --paging=never'
fi

ostype=$(uname)
source "${HOME}/.config/bubski-dotfiles/aliases/aliases-${ostype}.zsh"

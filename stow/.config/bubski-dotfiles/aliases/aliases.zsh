alias cat='bat --style=plain --paging=never'
alias glog="git log --graph --pretty=format:'%Cgreen%ad%Creset %C(auto)%h%d %s %C(bold black)<%aN>%Creset' --date=format-local:'%Y-%m-%d %H:%M (%a)'"

alias l1='ls -1'
alias ll1='ls -1a'

source "${HOME}/.config/bubski-dotfiles/aliases/aliases-$(uname).zsh"

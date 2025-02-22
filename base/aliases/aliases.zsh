alias glog="git log --graph --pretty=format:'%Cgreen%ad%Creset %C(auto)%h%d %s %C(bold black)<%aN>%Creset' --date=format-local:'%Y-%m-%d %H:%M (%a)'"

if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
fi

if [[ $(uname) == 'Darwin' ]]; then
    alias ls='ls -1G'
    alias s='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'
    alias hop='hopperv4 -e'
fi

if [[ $(uname) == 'Linux' ]]; then
    alias ls='ls -1 --color=tty'
fi

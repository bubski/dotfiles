if [[ $(uname) == 'Darwin' ]]; then
    [[ $- == *i* ]] && source '/opt/homebrew/opt/fzf/shell/completion.zsh' 2> /dev/null
    source "$(dirname $(which fzf))/../opt/fzf/shell/key-bindings.zsh" 2> /dev/null
fi

if [[ $(uname) == 'Linux' ]]; then
    source '/usr/share/doc/fzf/examples/completion.zsh' 2> /dev/null
    source '/usr/share/doc/fzf/examples/key-bindings.zsh' 2> /dev/null
fi

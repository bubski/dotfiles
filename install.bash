fmt_red=$(printf '\033[31m')
fmt_green=$(printf '\033[32m')
fmt_yellow=$(printf '\033[33m')
fmt_bold=$(printf '\033[1m')
fmt_reset=$(printf '\033[0m')

clone_path="${HOME}/.dotfiles"

command_exists() {
    command -v "$@" &>/dev/null
}

print_error() {
    printf '%sError: %s%s\n' "${fmt_bold}${fmt_red}" "$*" "$fmt_reset" >&2
}

bail_with_message() {
    print_error "$@"
    exit 1
}

user_can_sudo() {
    command_exists 'sudo' || bail_with_message 'sudo not installed.'
    ! LANG='' sudo -n -v 2>&1 | grep -q "may not run sudo"
}

assert_user_can_sudo() {
    user_can_sudo || bail_with_message "Current user (${USER}) cannot sudo."
}

install_tool() {
    sudo whoami
    sudo echo "$@"
}

ensure_command_exists_single() {
    if ! command_exists "$1"; then
        install_tool "$1"
    fi
}

ensure_command_exists() {
    for cmd in "$@"; do
        ensure_command_exists_single "$cmd"
    done
}

assert_commands_exists() {
    for cmd in "$@"; do
        command_exists "$cmd" || {
            print_error "${cmd} not installed" >&2
            exit 1
        }
    done
}

install_if_needed() {
    for cmd in "$@"; do
        command_exists "$cmd" ||
            sudo apt install -y "$@" ||
            bail_with_message "Failed to install ${cmd}."
    done
}

_stow() {
    stow "$@" -v -d "$clone_path" -t "$HOME" 'stow' "stow-$(uname)"
}

do_stow() {
    _stow
}

do_unstow() {
    _stow -D
}

main() {
    local repo_url
    local clone_path
    local tools
    repo_url='https://github.com/bubski/dotfiles.git'

    assert_user_can_sudo

    tools=(
        'git'
        'stow'
        'zsh'
    )

    install_if_needed "${tools[@]}"

    git clone --recurse-submodules --shallow-submodules "$repo_url" "$clone_path" || bail_with_message "Failed to clone repo."

    mkdir ~/.config
    mkdir -p ~/.local/bin
    do_stow
    stow -d "$clone_path" -t "$HOME" 'stow' "stow-$(uname)" || bail_with_message 'Stow failed.'

    sudo chsh -s "$(command -v zsh)" "$USER" || bail_with_message "Changing default shell failed."

    cat <<EOF
${fmt_green}Installation complete.
Relog, or execute: ${fmt_yellow}SHELL=$(command -v zsh) zsh${fmt_reset}
EOF
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    # Script is being executed directly.
    main
elif [[ -z ${BASH_SOURCE[0]} ]]; then
    # Script is executed inline (e.g. via bash -c).
    main
else
    # Script is being sourced.
    true
fi

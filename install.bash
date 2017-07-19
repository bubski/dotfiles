#!/bin/bash

FMT_RED=$(printf '\033[31m')
FMT_GREEN=$(printf '\033[32m')
FMT_YELLOW=$(printf '\033[33m')
FMT_BLUE=$(printf '\033[34m')
FMT_BOLD=$(printf '\033[1m')
FMT_RESET=$(printf '\033[0m')

repo_url='https://github.com/bubski/dotfiles.git'
clone_path="${HOME}/.dotfiles"

command_exists() {
    command -v "$@" &>/dev/null
}

print_error() {
    printf '%sError: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

bail_with_message() {
    print_error "$@"
    exit 1
}

user_can_sudo() {
    command_exists 'sudo' || bail_with_message 'sudo not installed.'
    ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

assert_user_can_sudo() {
    user_can_sudo || bail_with_message "Current user (${USER}) cannot sudo."
}

install_tool() {
    sudo whoami
    sudo echo "$@"
}

ensure_command_exists_single() {
    if ! command_exists "$1"
    then
        install_tool "$1"
    fi
}

ensure_command_exists() {
    for cmd in "$@"
    do
        ensure_command_exists_single "$cmd"
    done
}

assert_commands_exists() {
    for cmd in "$@"
    do
        command_exists "$cmd" || {
            print_error "${cmd} not installed" >&2
            exit 1
        }
    done
}

install_if_needed() {
    for cmd in "$@"
    do
        command_exists "$cmd" \
            || sudo apt install -y "$@" \
            || bail_with_message "Failed to install ${cmd}."
    done
}

assert_user_can_sudo

tools=(
    'git'
    'stow'
    'zsh'
)

install_if_needed "${tools[@]}"

git clone --recurse-submodules --shallow-submodules "$repo_url" "$clone_path"
[[ $? -eq 0 ]] || bail_with_message "Failed to clone repo."

cd "$clone_path" && stow stow || bail_with_message "Stow failed."

sudo chsh -s "$(command -v zsh)" "$USER"
[[ $? -eq 0 ]] || bail_with_message "Changing default shell failed."

cat << EOF
${FMT_GREEN}Installation complete.
Relog, or execute: ${FMT_YELLOW}SHELL=$(command -v zsh) zsh${FMT_RESET}
EOF

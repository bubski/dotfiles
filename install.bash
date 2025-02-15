#!/usr/bin/env bash

FMT_RED=$(echo -e '\033[1;31m')
FMT_GREEN=$(echo -e '\033[1;32m')
FMT_YELLOW=$(echo -e '\033[1;33m')
FMT_BOLD=$(echo -e '\033[1;1m')
FMT_RESET=$(echo -e '\033[1;0m')

set -e

main() {
    "check_dependencies_$(uname -s)"

    local repo_url="https://github.com/bubski/dotfiles.git"
    local clone_path="${HOME}/.local/lib/bubash"

    git clone --recurse-submodules --shallow-submodules "${repo_url}" "${clone_path}"
    "${clone_path}/tools/activate"
    sudo chsh -s "$(command -v zsh)" "${USER}" || bail "Changing default shell failed."
    SHELL=$(command -v zsh) zsh
}

print_error() {
    echo "${FMT_BOLD}${FMT_RED}Error: $@${FMT_RESET}"
}

check_dependencies_Linux() {
    assert_installed \
        "zsh" "$(apt_install_cmd zsh)" \
        "git" "$(apt_install_cmd git)" \
        "stow" "$(apt_install_cmd stow)"
}

check_dependencies_Darwin() {
    assert_installed \
         "brew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' \
         "stow" "brew install stow"
}

prompt_and_do() {
    read -r -p "$1 [y/N] " REPLY
    shift
    case "$REPLY" in [yY]|[yY][eE][sS]) eval "$*" ;;
                                     *) exit 1 ;;
    esac
}

assert_installed() {
    while [ $# -gt 1 ]; do
        local cmd=$1
        local install_cmd=$2
        shift 2

        command_exists "${cmd}" && continue
        print_error "${cmd} is not installed."

        prompt_and_do \
            "Do you want to install ${cmd} via ${FMT_YELLOW}${install_cmd}${FMT_RESET}?" \
            "${install_cmd}"
    done
}

command_exists() {
    command -v "$@" &>/dev/null
}

apt_install_cmd() {
    echo "sudo bash -c 'apt update && apt install -y $@'"
}

main "$@"

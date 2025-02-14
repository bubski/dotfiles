#!/usr/bin/env bash

FMT_RED=$(echo -e '\033[1;31m')
FMT_GREEN=$(echo -e '\033[1;32m')
FMT_YELLOW=$(echo -e '\033[1;33m')
FMT_BOLD=$(echo -e '\033[1;1m')
FMT_RESET=$(echo -e '\033[1;0m')

set -e

main() {
    assert_installed git zsh stow

    local repo_url='https://github.com/bubski/dotfiles.git'
    local clone_path="${HOME}/.local/lib/bubdot"

    git clone --recurse-submodules --shallow-submodules "${repo_url}" "${clone_path}"

    cd "${clone_path}/stow"
    for path in */stow.conf; do
        do_stow "${path}"
    done

    sudo chsh -s "$(command -v zsh)" "${USER}" || bail "Changing default shell failed."

    echo "${FMT_GREEN}Installation complete.${FMT_RESET}"
    SHELL=$(command -v zsh) zsh
}

do_stow() {
    while IFS='=' read -r key value; do
        declare "CFG_${key}"="${value}"
    done < "$1"

    if should_skip; then return 0; fi

    [[ -n "${CFG_MKDIR}" ]] && mkdir -p "${HOME}/${CFG_MKDIR}"

    local package=$(dirname "$1")
    stow -t "${HOME}" "${package}" --ignore='stow\.conf'
}

should_skip() {
    case $(uname -s) in
      Linux) [[ "${CFG_LINUX}" != 1 ]] ;;
      Darwin) [[ "${CFG_MAC}" != 1 ]] ;;
      *) bail "Unexpected uname: $os" ;;
    esac
}

print_error() {
    echo "${FMT_BOLD}${FMT_RED}Error: $@${FMT_RESET}"
}

assert_installed() {
    for cmd in "$@"; do
        command_exists "${cmd}" || bail "${cmd} is not installed."
    done
}

command_exists() {
    command -v "$@" &>/dev/null
}

bail() {
    print_error "$@"
    exit 1
}

main

#!/usr/bin/env bash

FMT_RED=$(echo -e '\033[1;31m')
FMT_GREEN=$(echo -e '\033[1;32m')
FMT_YELLOW=$(echo -e '\033[1;33m')
FMT_BOLD=$(echo -e '\033[1;1m')
FMT_RESET=$(echo -e '\033[1;0m')

set -e

main() {
    check_dependencies_$(uname -s)

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

check_dependencies_Linux() {
    assert_installed \
        'zsh' "$(apt_install_cmd git)" \
        'git' "$(apt_install_cmd git)" \
        'stow' "$(apt_install_cmd stow)"
}

check_dependencies_Darwin() {
    true
}

prompt_and_do() {
    read -r -p "$1 [y/N] " REPLY
    shift
    case "$REPLY" in [yY]|[yY][eE][sS]) eval "$*" ;;
                                     *) exit 1 ;;
    esac
}

handle_not_installed() {
    print_error "${cmd} is not installed."
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

bail() {
    print_error "$@"
    exit 1
}

apt_install_cmd() {
    echo "sudo bash -c 'apt update && apt install -y $@'"
}

main

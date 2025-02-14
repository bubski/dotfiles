fmt_red=$(printf '\033[31m')
fmt_green=$(printf '\033[32m')
fmt_yellow=$(printf '\033[33m')
fmt_bold=$(printf '\033[1m')
fmt_reset=$(printf '\033[0m')

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
    printf '%sError: %s%s\n' "${fmt_bold}${fmt_red}" "$*" "${fmt_reset}" >&2
}

print_error() {
    printf '%sError: %s%s\n' "${fmt_bold}${fmt_red}" "$*" "${fmt_reset}" >&2
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

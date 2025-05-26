#!/bin/bash



# helper functions 

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

user_can_sudo() {
  # Check if sudo is installed
  command_exists sudo || return 1
  # Termux can't run sudo, so we can detect it and exit the function early.
  case "$PREFIX" in
  *com.termux*) return 1 ;;
  esac
  # The following command has 3 parts:
  #
  # 1. Run `sudo` with `-v`. Does the following:
  #    • with privilege: asks for a password immediately.
  #    • without privilege: exits with error code 1 and prints the message:
  #      Sorry, user <username> may not run sudo on <hostname>
  #
  # 2. Pass `-n` to `sudo` to tell it to not ask for a password. If the
  #    password is not required, the command will finish with exit code 0.
  #    If one is required, sudo will exit with error code 1 and print the
  #    message:
  #    sudo: a password is required
  #
  # 3. Check for the words "may not run sudo" in the output to really tell
  #    whether the user has privileges or not. For that we have to make sure
  #    to run `sudo` in the default locale (with `LANG=`) so that the message
  #    stays consistent regardless of the user's locale.
  #
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

# The [ -t 1 ] check only works when the function is not called from
# a subshell (like in `$(...)` or `(...)`, so this hack redefines the
# function at the top level to always return false when stdout is not
# a tty.
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi

fmt_link() {
  # $1: text, $2: url, $3: fallback mode
  if supports_hyperlinks; then
    printf '\033]8;;%s\033\\%s\033]8;;\033\\\n' "$2" "$1"
    return
  fi

  case "$3" in
  --text) printf '%s\n' "$1" ;;
  --url|*) fmt_underline "$2" ;;
  esac
}

fmt_underline() {
  is_tty && printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

# shellcheck disable=SC2016 # backtick in single-quote
fmt_code() {
  is_tty && printf '`\033[2m%s\033[22m`\n' "$*" || printf '`%s`\n' "$*"
}

fmt_error() {
  printf '%sError: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}


if [ "$(id -u)" = "0" ]; then
    Sudo=''
elif which sudo; then
    Sudo='sudo'
else
    echo "WARNING: 'sudo' command not found. Skipping the installation of dependencies. "
    echo "If this fails, you need to do one of these options:"
    echo "   1) Install 'sudo' before calling this script"
    echo "OR"
    echo "   2) Install the required dependencies: git curl zsh"
    return
fi


$Sudo apt-get update
pkgs=(fzf zsh kubectx git tree unzip locales locales-all bat ripgrep)
$Sudo apt-get -y --ignore-missing install "${pkgs[@]}" 




curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

OK="$(cat kubectl.sha256)  kubectl" | sha256sum --check

$Sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm -rf kubectl
rm kubectl.sha256

curl -LO "https://github.com/asdf-vm/asdf/releases/download/v0.16.7/asdf-v0.16.7-linux-amd64.tar.gz"
$Sudo tar -xvzf asdf-v0.16.7-linux-amd64.tar.gz -C /usr/local/bin
rm asdf-v0.16.7-linux-amd64.tar.gz

asdf plugin add kubelogin
asdf install kubelogin latest
asdf set -u kubelogin latest


if [ ! -d "$HOME"/.oh-my-zsh ]; then
    sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
fi


curl -o $HOME/.zshrc "https://raw.githubusercontent.com/pietergobin/settings/refs/heads/main/linux/.zshrc"


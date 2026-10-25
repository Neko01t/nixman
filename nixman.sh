#!/usr/bin/env bash

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nixman"
CONFIG_FILE="$CONFIG_DIR/config"

# Defualt values these values are taken from config
gitdir="/etc/nixos"
programs_file="modules/programs.nix"
host_name="Neko01t"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

programs_module_path="$gitdir/$programs_file"

cmd_update() {
  sudo git -C "$gitdir" add -Av
  echo "Updating NixOS configuration..."

  if ! sudo git -C "$gitdir" diff --quiet ||
    ! sudo git -C "$gitdir" diff --cached --quiet; then
    (
      set -o pipefail
      sudo git -C "$gitdir" commit -am "Update NixOS configuration" 2>&1 |
        sed 's/^/git-log > /'
    ) || return 1
  fi
  # sudo git --git-dir="${gitdir}/.git" --work-tree="${gitdir}" add "${gitdir}" >/dev/null 2>&1 || exit 1
  sudo nixos-rebuild switch --flake ${gitdir}#"${host_name}"

}
cmd_install() {
  local name="$1"
  local pkgAdded=false

  [ -n "$name" ] || {
    printf "\e[31mERROR\e[0m: Please provide a package name.\n\e[32mUsage\e[0m: ${0##*/} install \e[33m<package_name> \e[0m \n" >&2
    exit 1
  }
  local newpackage=$name
  sudo sed -i -e "/];/i \ \ \ \ $newpackage" "$programs_module_path" && pkgAdded=true

  if gum confirm "Open Nvim to verify"; then
    sudo nvim "$programs_module_path"
  else
    printf ":"
  fi

  if [ "$pkgAdded" = true ]; then
    cmd_update
    [ $? -eq 0 ] && echo "Sucess 200" || echo "Error 500"
  else
    echo "Sed command failed"
  fi
}

cmd_test() {
  echo "ehco"
}

# --- Main Section ---

COMMAND="$1"
shift
case "$COMMAND" in
update)
  cmd_update
  ;;
test)
  cmd_test "$@"
  ;;
install)
  cmd_install "$@"
  ;;
*)
  if [[ -n $COMMAND ]]; then
    printf "\e[31mUnknown command\e[0m: ${COMMAND}\n" >&2
  fi
  printf "\e[32mUsage\e[0m: ${0##*/} \e[33m<command> [arguments]\e[0m \n" >&2
  ;;
esac

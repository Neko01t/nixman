#!/usr/bin/env bash

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nixman"
CONFIG_FILE="$CONFIG_DIR/config"

gitdir="/etc/nixos"
programs_file="modules/programs.nix"
host_name="Neko01t"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

programs_module_path="$gitdir/$programs_file"

cmd_update() {
  local real_update=false
  real_update="$1"
  gum log --level info "$(echo -e "\e[34mStaging changes in $gitdir...\e[0m")"
  sudo git -C "$gitdir" add -Av
  if ! sudo git -C "$gitdir" diff --quiet ||
    ! sudo git -C "$gitdir" diff --cached --quiet; then
    (
      set -o pipefail
      sudo git -C "$gitdir" commit -m "Update NixOS configuration" 2>&1 |
        sed 's/^/git-log > /'
    ) || return 1
  fi
  # sudo git --git-dir="${gitdir}/.git" --work-tree="${gitdir}" add "${gitdir}" >/dev/null 2>&1 || exit 1
  if [ "$real_update" == true ]; then
    gum log --level info "$(echo -e "\e[33mUpdating flake inputs...\e[0m")"
    (
      set -o pipefail
      sudo nix flake update --flake "${gitdir}" 2>&1 |
        sed 's/^/nix-log > /'
    ) || return 1
  fi
  cmd_rebuild
}

cmd_rebuild() {
  sudo nixos-rebuild switch --flake ${gitdir}#"${host_name}"
  gum log --level info "$(echo -e "\e[32mBuilding NixOS configuration (${host_name})...\e[0m")"
}

cmd_clean() {
  echo "Starting Nix garbage collection..."
  if gum confirm "Are you sure you want to delete old generations and free up disk space?"; then
    sudo nix-collect-garbage -d
    echo -e "\e[32mCleanup complete! Disk space reclaimed.\e[0m"
  else
    echo "Cleanup cancelled."
  fi
}

cmd_install() {
  local name="$1"
  local pkgAdded=false

  [ -n "$name" ] || {
    printf "\e[31mERROR\e[0m: Please provide a package name.\n\e[32mUsage\e[0m: ${0##*/} install \e[33m<package_name> \e[0m \n" >&2
    exit 1
  }
  local newpackage=$name
  # Adding the package in repo right above your comment marker
  sudo sed -i -e "/# -- ADD PACKAGES HERE --/i \ \ \ \ $newpackage" "$programs_module_path" && pkgAdded=true

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
  cmd_update true
  ;;
test)
  cmd_test "$@"
  ;;
install)
  cmd_install "$@"
  ;;
clean)
  cmd_clean
  ;;
build)
  cmd_rebuild
  ;;
*)
  if [[ -n $COMMAND ]]; then
    gum log --level error "$(echo -e ": \e[31mUnknown command\e[0m: ${COMMAND}")"
  fi
  gum log --level info "$(echo -e " : ${0##*/} \e[33m<command> [arguments]\e[0m\n")"
  ;;
esac

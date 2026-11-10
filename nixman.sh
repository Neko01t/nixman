#!/usr/bin/env bash

# Lets make error codes for errors
# git fail 0-9
# 1 - commit fail
# nix command fail 10-19
# 10 : nix update commmand fail
# 11 : nix rebuild failed
# 20-29 script command fails
# 20 : cmd_rebuild fail
# 21 : cmd_update faild
# 255 : user is failure
# 30-29 : external package fail  = [gum : 31 ,sed :32 ]

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nixman"
CONFIG_FILE="$CONFIG_DIR/config"

gitdir="/etc/nixos"
programs_file="modules/programs.nix"
host_name="nova"
test="Fail"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

programs_module_path="$gitdir/$programs_file"

cmd_update() {
  local real_update=false
  real_update="$1"
  local package_name=${2:-"Channel"}
  gum log --level info "$(echo -e "\e[34mStaging changes in $gitdir...\e[0m")"
  sudo git -C "$gitdir" add -Av
  if ! sudo git -C "$gitdir" diff --quiet ||
    ! sudo git -C "$gitdir" diff --cached --quiet; then
    (
      set -o pipefail
      sudo git -C "$gitdir" commit -m "Update NixOS configuration : pkg ${package_name}" 2>&1 |
        sed 's/^/git-log > /'
    ) || return 2
  fi
  # sudo git --git-dir="${gitdir}/.git" --work-tree="${gitdir}" add "${gitdir}" >/dev/null 2>&1 || exit 1
  if [ "$real_update" == true ]; then
    gum log --level info "$(echo -e "\e[33mUpdating flake inputs...\e[0m")"
    (
      set -o pipefail
      sudo nix flake update --flake "${gitdir}" 2>&1 |
        sed 's/^/nix-log > /'
    ) || return 10
  fi
  cmd_rebuild || return 20
}

cmd_rebuild() {
  gum log --level info "$(echo -e "\e[32mBuilding NixOS configuration (${host_name})...\e[0m")"
  sudo nixos-rebuild switch --flake ${gitdir}#"${host_name}" || return 11
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
    exit 255
  }
  local newpackage=$name
  if cmd_list | grep -q "$newpackage"; then
    echo "Pacakge alredy exists"
    return 255
  fi

  # sudo sed -i -e "/];/i \ \ \ \ $newpackage" "$programs_module_path" && pkgAdded=true
  # Adding the package in repo right above your comment marker
  sudo sed -i -e "/# -- ADD PACKAGES HERE --/i \ \ \ \ $newpackage" "$programs_module_path" && pkgAdded=true
  if gum confirm "Open Nvim to verify" --default=false; then
    sudo nvim "$programs_module_path"
  else
    printf ""
  fi

  if [ "$pkgAdded" = true ]; then
    local status=0
    cmd_update false $newpackage
    status=$?
    if [ $status -eq 0 ]; then
      echo "Sucess 200"
    else
      cmd_undo
      echo "Error 21 [undo auto]"
    fi
  else
    echo "Error : 32"
  fi
}

cmd_test() {
  echo "ehco"
}

cmd_undo() {
  if ! sudo git -C "$gitdir" diff --quiet || ! sudo git -C "$gitdir" diff --cached --quiet; then
    gum log --level error "$(echo -e "\e[31mUncommitted changes in $gitdir. Please commit or stash first.\e[0m")"
    return 1
  fi

  sudo git -C "$gitdir" branch -f redo HEAD
  sudo git -C "$gitdir" reset --hard HEAD~1

  cmd_update false
  local status=$?
  [ $status -eq 0 ] && echo "Sucess 200" || echo "Error 21"
}

cmd_redo() {
  if ! sudo git -C "$gitdir" diff --quiet || ! sudo git -C "$gitdir" diff --cached --quiet; then
    gum log --level error "$(echo -e "\e[31mUncommitted changes in $gitdir. Please commit or stash first.\e[0m")"
    return 1
  fi

  if ! sudo git -C "$gitdir" show-ref --quiet refs/heads/redo; then
    gum log --level error "Nothing to redo!"
    return 1
  fi
  sudo git -C "$gitdir" reset --hard redo
  sudo git -C "$gitdir" branch -D redo

  cmd_update false
  local status=$?
  [ $status -eq 0 ] && echo "Sucess 200" || echo "Error 21"

}

cmd_run() {
  local package_name="$1"
  shift
  if [ -z $package_name ]; then
    gum log --level error "$(echo -e "\e[31mPlease provide a package name to run.\e[0m")"
    return 22
  fi
  gum log --level info "$(echo -e "\e[34mRunning nixpkgs#${package_name}...\e[0m")"
  nix run "nixpkgs#${package_name}" -- "$@"
}

cmd_list() {
  local LinesNumber=$(grep -n -E '\[|\]' "$gitdir/$programs_file" | cut -d : -f 1)
  local topLineNumber=$(($(echo "$LinesNumber" | head -n 1) + 1))
  local lastLineNumber=$(($(echo "$LinesNumber" | tail -n 1) - 2))
  local output=$(sed -n "${topLineNumber},${lastLineNumber}p" "$gitdir/$programs_file" | sed 's/^[ \t]*//; /^$/d; /^#/d ')
  echo "$output"
}

cmd_help() {
  echo -e "\e[32mNixMan\e[0m - A NixOS Configuration Manger"
  echo -e "Usage: ${0##*/} \e[33m<command> [arguments]\e[0m\n"

  echo -e "\e[34mPackage Management:\e[0m"
  echo "  install <pkg>   Add a package and rebuild"
  echo "  run <pkg>       Run a package temporarily without installing"
  echo "  list            List currently installed packages"
  echo ""
  echo -e "\e[34mSystem Management:\e[0m"
  echo "  update          Update flake inputs and rebuild the system"
  echo "  build           Rebuild the system without updating inputs"
  echo "  clean           Run garbage collection to free disk space"
  echo ""
  echo -e "\e[34mVersion Control (Time Travel):\e[0m"
  echo "  undo            Instantly revert to the previous configuration"
  echo "  redo            Jump forward to the configuration you just undid"
  echo ""
}

# --- Main Section ---

COMMAND="$1"
shift
case "$COMMAND" in
update) cmd_update true ;;
test) cmd_test "$@" ;;
install) cmd_install "$@" ;;
clean) cmd_clean ;;
build) cmd_rebuild ;;
run) cmd_run "$@" ;;
undo) cmd_undo ;;
redo) cmd_redo ;;
list) cmd_list ;;
help) cmd_help ;;
*)
  if [[ -n $COMMAND ]]; then
    gum log --level error "$(echo -e ": \e[31mUnknown command\e[0m: ${COMMAND}")"
    # printf "\e[31mUnknown command\e[0m: ${COMMAND}\n" >&2
  fi
  gum log --level info "$(echo -e " : ${0##*/} \e[33m<command> [arguments]\e[0m\n")"
  ;;
esac

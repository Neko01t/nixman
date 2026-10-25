#!/usr/bin/env bash

echo "Installing NIXMAN"
hostname=$(uname -n)
packname="nixman"
echo "Hostname : $hostname"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

init() {
  mkdir -p "$CONFIG_DIR" && mkdir -p "$CONFIG_DIR/$packname" || return 1
  local curr_path="$(pwd)"
  local curr_dir="${curr_path##*/}"
  if [[ $curr_dir == "nixman" ]]; then
    cat ./config/nixman/config-example >"${CONFIG_DIR}/${packname}/config"
  else
    echo "Error : use script inside the nixman folder"
    return 1
  fi
  sleep 0.2
  echo "Config Added : "
  cat "$CONFIG_DIR/${packname}/config"
}
init

#!/usr/bin/env bash

echo "Installing NIXMAN"
hostname=$(uname -n)
packname="nixman"
echo "Hostname : $hostname"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
init() {
  local target_dir="$CONFIG_DIR/$packname"
  if ! mkdir -p "$target_dir"; then
    echo "Error: Failed to create configuration directory."
    return 1
  fi
  local example-conf="$SCRIPT_DIR/config/nixman/config-example"

  if [ -f "example-conf" ] ; then
    cp ./config/nixman/config-example "$target_dir/config"
  else
    echo "Error : use script inside the nixman folder"
    return 1
  fi
  sleep 0.2
  echo -e "\e[32mConfig Added Successfully:\e[0m"
  cat "$target_dir/config"
}
init

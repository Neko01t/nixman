#!/usr/bin/env bash

echo "Installing NIXMAN"
hostname=$(uname -n)
packname="nixman"
echo "Hostname : $hostname"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
init() {
  local target_dir="$CONFIG_DIR/$packname"
  local target_dir_fish="$CONFIG_DIR/fish/completions"
  if ! mkdir -p "$target_dir" "$target_dir_fish"; then
    echo "Error: Failed to create configuration directory."
    return 1
  fi
  local example_conf="$SCRIPT_DIR/config/nixman/config-example"
  local fish_completion="$SCRIPT_DIR/config/fish/completions/nixman.fish"
  if [ -f "$example_conf" ] && [ -f "$fish_completion" ]; then
    cp ./config/nixman/config-example "$target_dir/config"
    cp ./config/fish/completions/nixman.fish "$target_dir_fish/nixman.fish"
  else
    echo "Error : use script inside the nixman folder"
    return 1
  fi
  sleep 0.2
  echo -e "\e[32mConfig Added Successfully:\e[0m"
  echo && echo "------- Config for Nixman ----------" && echo
  cat "$target_dir/config"
  echo && echo "----- completions for fish ---------" && echo
  cat "$target_dir_fish/nixman.fish"
}
init

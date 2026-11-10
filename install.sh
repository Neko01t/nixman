#!/usr/bin/env bash

echo "Installing NIXMAN"
hostname=$(uname -n)
packname="nixman"
echo "Hostname : $hostname"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
init() {
  local target_dir="$CONFIG_DIR/$packname"
  local target_dir_fish="$CONFIG_DIR/fish/completions"
  if ! mkdir -p "$target_dir" "$target_dir_fish" "$LOCAL_DIR"; then
    echo "Error: Failed to create configuration directory."
    return 1
  fi
  local example_conf="$SCRIPT_DIR/config/nixman/config-example"
  local fish_completion="$SCRIPT_DIR/config/fish/completions/nixman.fish"

  if [ -f "$example_conf" ] && [ -f "$fish_completion" ]; then
    cp "$example_conf" "$target_dir/config"
    cp "$fish_completion" "$target_dir_fish/nixman.fish"
    sed -i "s/host_name=\"nova\"/host_name=\"$hostname\"/" "$target_dir/config"
  else
    echo "Error : use script inside the nixman folder"
    return 1
  fi
  sleep 0.2
  if cp "$SCRIPT_DIR/nixman.sh" "$LOCAL_DIR/nixman"; then
    chmod +x "$LOCAL_DIR/nixman"
  else
    echo "Error: Failed to copy executable to $LOCAL_DIR"
    return 1
  fi

  echo -e "\e[32mInstallation Finished\e[0m"
  # echo -e "\e[32mConfig Added Successfully:\e[0m"
  # echo && echo "------- Config for Nixman ----------" && echo
  # cat "$target_dir/config"
  # echo && echo "----- completions for fish ---------" && echo
  # cat "$target_dir_fish/nixman.fish"
}
init

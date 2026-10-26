# NIXMAN

A tool that is made to for nixos folks for easing the life of editing the file over and over and doing `nix-rebuild switch`, fear not coz i am here 

> [!IMPORTANT]
> - **Flakes Only:** This tool is designed strictly for NixOS Flakes environments.
> - **Root Privileges:** Requires `sudo` to run system rebuilds and update configuration files.
> - **Text Replacement:** This script uses `sed` to automatically inject packages.
> - **Audit First:** Always read scripts before running them with `sudo` for peace of mind!

--- 

## How to install 

### Method 1 
Install using script

```bash
git clone https://github.com/Neko01t/nixman.git 
cd nixman 
./install.sh
```

### Method 2
Install manually (by copy pasting files by hand)

```md
DIY 
```

## Required Stuff 

- Git & NixOS: Mandatory (Flakes require Git to track files).
- Gum : For interactive confirmation prompts & Logs 
- Separated Packages: Your package list should be moved into a dedicated module file (e.g., modules/programs.nix).
- Fish : For auto-completion and tab-suggestion

## Configuration Example

Your target package file (programs.nix or similar) must include the anchor comment. The script searches for this comment to know where to insert new packages:

```bash
{ pkgs, ... }:

{
  environment.systemPackages = [
    git
    neovim
    # -- ADD PACKAGES HERE --
  ];
}
# You can do ur shenanigans here below 
```

> [!IMPORTANT]
> The comment `# -- ADD PACKAGES HERE --` is mandatory. Without it, the script's sed insertion will fail!



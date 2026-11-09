# Disable file completions for the main command unless needed
# installed by Nixman Neko
complete -c nixman -f

complete -c nixman -n __fish_use_subcommand -a update -d "Update current nix package"
complete -c nixman -n __fish_use_subcommand -a build -d "Rebuild NixOS system configuration"
complete -c nixman -n __fish_use_subcommand -a install -d "Install a new package to programs.nix"
complete -c nixman -n __fish_use_subcommand -a clean -d "Run Nix garbage collection and free disk space"
complete -c nixman -n __fish_use_subcommand -a run -d "Runs the package provided"
complete -c nixman -n __fish_use_subcommand -a undo -d "Go back one step from the git tree"
complete -c nixman -n __fish_use_subcommand -a list -d "List all Packages in the in programs"
# complete -c nixman -n "__fish_seen_subcommand_from install" -a eza -d "example package"

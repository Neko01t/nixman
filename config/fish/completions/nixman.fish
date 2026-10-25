# Disable file completions for the main command unless needed
complete -c nixman -f

complete -c nixman -n __fish_use_subcommand -a update -d "Update current nix package"
complete -c nixman -n __fish_use_subcommand -a install -d "install a new package"

# complete -c nixman -n "__fish_seen_subcommand_from install" -a eza -d "example package"

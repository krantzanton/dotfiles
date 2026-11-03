# Basic fish config (keep minimal for now)

# Aliases
alias ls="eza --icons"
alias ll="eza -lah --icons"

# Environment
set -gx EDITOR nvim

# Greeting (disable default)
set -g fish_greeting ""

# Path additions (~/.local/bin has nvim/go/node on Ubuntu, see bootstrap.sh)
fish_add_path $HOME/.local/bin $HOME/go/bin

fish_add_path $HOME/.local/opt/cmake/bin
fish_add_path $HOME/.local/bin/easyeda2kicad

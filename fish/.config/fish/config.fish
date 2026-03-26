# Basic fish config (keep minimal for now)

# Aliases
alias ls="eza --icons"
alias ll="eza -lah --icons"
alias cat="bat"

# Environment
set -gx EDITOR nvim

# Greeting (disable default)
set -g fish_greeting ""

# Path additions (example)
# set -gx PATH $HOME/.local/bin $PATH

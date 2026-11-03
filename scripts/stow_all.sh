#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

backup_if_exists() {
  local target="$1"

  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "==> backing up $target -> $target.bak"
    mv "$target" "$target.bak"
  fi
}

# Handle known conflicts (start minimal, expand later)
backup_if_exists "$HOME/.config/fish/config.fish"
backup_if_exists "$HOME/.config/kitty/kitty.conf"
backup_if_exists "$HOME/.config/tmux/tmux.conf"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.zshrc"

packages=(
  fish
  zsh
  git
  nvim
  tmux
  kitty
  ghostty
)

for pkg in "${packages[@]}"; do
  if [[ -d "$pkg" ]]; then
    echo "==> stowing $pkg"
    stow -Rv --target="$HOME" "$pkg"
  fi
done

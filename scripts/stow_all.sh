#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$REPO_ROOT"

backup_if_exists() {
  local target="$1"

  # Skip files that are already ours, including ones reached through a symlinked
  # folder (e.g. ~/.config/tmux -> this repo), which `-L` alone doesn't catch.
  if [[ -e "$target" && ! -L "$target" && "$(realpath "$target")" != "$REPO_ROOT"/* ]]; then
    echo "==> backing up $target -> $target.bak"
    mv "$target" "$target.bak"
  fi
}

# Handle known conflicts (start minimal, expand later)
backup_if_exists "$HOME/.config/fish/config.fish"
backup_if_exists "$HOME/.config/kitty/kitty.conf"
backup_if_exists "$HOME/.config/tmux/tmux.conf"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.claude/CLAUDE.md"

# fish and Claude write runtime files (fish_variables, history, credentials) into these
# folders, so they must be real directories, not symlinks into this repo.
mkdir -p "$HOME/.config/fish" "$HOME/.claude"
no_folding=(fish claude)

packages=(
  fish
  nvim
  tmux
  kitty
  claude
)

for pkg in "${packages[@]}"; do
  if [[ -d "$pkg" ]]; then
    echo "==> stowing $pkg"
    if [[ " ${no_folding[*]} " == *" $pkg "* ]]; then
      stow -Rv --no-folding --target="$HOME" "$pkg"
    else
      stow -Rv --target="$HOME" "$pkg"
    fi
  fi
done

# Claude rewrites ~/.claude/settings.json itself, so it isn't symlinked. Instead, add our
# hooks (scripts/claude-settings.json) to it, keeping everything already there.
merge_claude_settings() {
  local settings="$HOME/.claude/settings.json" add="$REPO_ROOT/scripts/claude-settings.json" tmp
  command -v jq >/dev/null 2>&1 || { echo "!!  jq not found; skipping Claude settings merge" >&2; return; }
  [[ -s $settings ]] || echo '{}' >"$settings"
  tmp="$(mktemp)"
  jq -s '
    .[0] as $cur | .[1].hooks as $add
    | $cur | .hooks = reduce ($add | to_entries[]) as $e (($cur.hooks // {});
        .[$e.key] as $have
        | .[$e.key] = (($have // []) + [$e.value[] | select(. as $x | ($have // []) | any(. == $x) | not)]))
  ' "$settings" "$add" >"$tmp" && mv "$tmp" "$settings"
  echo "==> merged Claude hooks into $settings"
}
merge_claude_settings

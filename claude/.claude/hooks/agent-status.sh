#!/usr/bin/env bash
# Claude Code hook: marks the tmux window when an agent needs you.
#   agent-status.sh waiting   (Notification / Stop hooks)  -> pink ● in the tmux status bar,
#                                                             desktop notification if you're looking elsewhere
#   agent-status.sh working   (UserPromptSubmit / PostToolUse) -> clears the ●
# Registered in ~/.claude/settings.json by scripts/stow_all.sh. Never fails the hook.

input="$(cat 2>/dev/null)"
[[ -n ${TMUX_PANE:-} ]] && command -v tmux >/dev/null 2>&1 || exit 0

case "${1:-}" in
  working)
    tmux set-option -w -u -t "$TMUX_PANE" @agent_waiting 2>/dev/null
    ;;
  waiting)
    tmux set-option -w -t "$TMUX_PANE" @agent_waiting 1 2>/dev/null
    # Only notify if this window isn't the one currently on screen
    seen="$(tmux display-message -p -t "$TMUX_PANE" '#{&&:#{window_active},#{session_attached}}' 2>/dev/null)"
    if [[ $seen != 1 ]] && command -v notify-send >/dev/null 2>&1; then
      where="$(tmux display-message -p -t "$TMUX_PANE" '#S:#I #W' 2>/dev/null)"
      msg=""
      command -v jq >/dev/null 2>&1 && msg="$(jq -r '.message // empty' <<<"$input" 2>/dev/null)"
      notify-send -a "Claude Code" "Claude needs you ($where)" "${msg:-Finished, waiting for your input}" 2>/dev/null
    fi
    ;;
esac
exit 0

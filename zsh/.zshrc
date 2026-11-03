# zsh config — no framework, just built-ins + a few Fedora packages
# (zsh-autosuggestions, zsh-syntax-highlighting, fzf, zoxide; see bootstrap.sh)

# --- Environment ------------------------------------------------------------
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export MANPAGER="nvim +Man!"
export GOPATH="$HOME/go"

typeset -U path   # no duplicate PATH entries
path=(
  $HOME/.local/bin
  $GOPATH/bin
  $HOME/.local/opt/cmake/bin
  $HOME/.local/bin/easyeda2kicad
  $path
)

# --- History ----------------------------------------------------------------
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE \
       HIST_REDUCE_BLANKS HIST_VERIFY SHARE_HISTORY INC_APPEND_HISTORY

# --- Options ----------------------------------------------------------------
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt INTERACTIVE_COMMENTS NO_BEEP EXTENDED_GLOB
setopt COMPLETE_IN_WORD ALWAYS_TO_END

# --- Completion -------------------------------------------------------------
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# --- Keys (emacs-style line editing, like fish) -----------------------------
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line
bindkey '^[[A' up-line-or-beginning-search     # up: history matching prefix
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[1;5C' forward-word                  # ctrl+right
bindkey '^[[1;5D' backward-word                 # ctrl+left
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^X^E' edit-command-line                # open command in nvim
bindkey -M menuselect '^[[Z' reverse-menu-complete

# --- Prompt -----------------------------------------------------------------
# dir  branch*  ❯   (prompt turns red if the last command failed)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' %F{magenta} %b%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{magenta} %b|%a%u%c%f'
precmd() { vcs_info }
setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %(?.%F{cyan}.%F{red})❯%f '

# --- Aliases ----------------------------------------------------------------
if (( $+commands[eza] )); then
  alias ls='eza --icons'
  alias ll='eza -lah --icons --git'
  alias lt='eza --tree --level=2 --icons'
fi
alias v='nvim'
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias ta='tmux new-session -A -s main'
alias ..='cd ..'
alias ...='cd ../..'

# yazi: `y` changes into the directory you were in when you quit
y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(<"$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# --- Tools ------------------------------------------------------------------
# fzf: ctrl+r history, ctrl+t files, alt+c cd
for f in \
  /usr/share/fzf/shell/key-bindings.zsh \
  /usr/share/doc/fzf/examples/key-bindings.zsh; do   # Fedora, Ubuntu
  [[ -f $f ]] && { source $f; break; }
done
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border
  --color=bg+:#262626,fg+:#f2f4f8,hl:#33b1ff,hl+:#33b1ff,pointer:#ee5396,prompt:#78a9ff,info:#525252'

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"     # `z <dir>`
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Plugins from distro packages (same path on Fedora and Ubuntu) (syntax highlighting must be sourced last)
for f in \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -f $f ]] && source $f
done
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#525252'

# Machine-specific stuff that shouldn't be in git
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

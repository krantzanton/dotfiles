# fish config — mirrors zsh/.zshrc. Works with fish 3.7+ (Ubuntu 24.04) and newer.
# Functions (prompt, y, wt) live in ./functions/.

# --- Environment ------------------------------------------------------------
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx MANPAGER "nvim +Man!"
set -gx GOPATH $HOME/go

# ~/.local/bin has nvim, claude (and go/node on Ubuntu), see bootstrap.sh.
# Machine-specific PATH entries go in config.local.fish (see the bottom of this file).
fish_add_path $HOME/.local/bin $GOPATH/bin

set -g fish_greeting ""

status is-interactive; or return

# --- Abbreviations (expand as you type) and aliases -------------------------
abbr -a v nvim
abbr -a g git
abbr -a gs git status
abbr -a gd git diff
abbr -a gl git log --oneline --graph --decorate -20
abbr -a ta tmux new-session -A -s main

if type -q eza
    alias ls "eza --icons"
    alias ll "eza -lah --icons --git"
    alias lt "eza --tree --level=2 --icons"
end

# --- fzf: ctrl+r history, ctrl+t files, alt+c cd ----------------------------
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --color=bg+:#262626,fg+:#f2f4f8,hl:#33b1ff,hl+:#33b1ff,pointer:#ee5396,prompt:#78a9ff,info:#525252'

if type -q fzf
    # fzf 0.48+ ships its own fish integration; Ubuntu 24.04 has 0.44, so fall back
    if fzf --fish >/dev/null 2>&1
        fzf --fish | source
    else
        for f in /usr/share/doc/fzf/examples/key-bindings.fish /usr/share/fzf/shell/key-bindings.fish
            if test -f $f
                source $f
                fzf_key_bindings
                break
            end
        end
    end
end

# --- Tools ------------------------------------------------------------------
type -q zoxide; and zoxide init fish | source # `z <dir>`
type -q direnv; and direnv hook fish | source

# Machine-specific stuff that shouldn't be in git
test -f ~/.config/fish/config.local.fish; and source ~/.config/fish/config.local.fish

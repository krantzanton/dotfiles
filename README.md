# dotfiles
all my dotfiles (or my attempt at it)

Configs for fish, zsh, kitty, ghostty, tmux, Neovim and Claude Code, symlinked into `$HOME` with
[GNU stow](https://www.gnu.org/software/stow/).

**Works on Ubuntu 24.04 LTS** (main target) and Fedora 41+. `bootstrap.sh` detects which
one you're on. Other Debian/Ubuntu-based distros will probably work but aren't tested.

## Install

### 1. Clone

```sh
sudo apt install -y git          # Fedora: sudo dnf install -y git
git clone https://github.com/krantzanton/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Install everything

```sh
./bootstrap.sh
```

It asks for your sudo password once, and is safe to re-run. It:

- updates package lists, enables `universe` on Ubuntu / RPM Fusion on Fedora
- upgrades the system
- installs the base packages (list below)
- installs the latest **Neovim** from the official download into `~/.local/opt/nvim` (linked into
  `~/.local/bin`) on both distros: the config needs 0.12+, Ubuntu 24.04 ships 0.9 and Fedora 43 0.11
- **Ubuntu only:** same for **Go** and **Node.js LTS** (apt's are too old). Also links
  `fdfind` → `fd` and `batcat` → `bat`.
- installs [yazi](https://github.com/sxyazi/yazi) (file manager, `<leader>-` in nvim) and
  [lazygit](https://github.com/jesseduffield/lazygit) (git UI, `<leader>gg` in nvim) into `~/.local/bin`
- installs the **Cascadia Code NF** font kitty uses (into `~/.local/share/fonts` on Ubuntu)
- installs NVIDIA drivers **only if an NVIDIA GPU is detected** (`ubuntu-drivers install` on
  Ubuntu, `akmod-nvidia` on Fedora)
- installs [Claude Code](https://code.claude.com) (AI coding agent) into `~/.local/bin`
- makes fish the default shell
- enables Git LFS, installs the Neovim Python and Node providers

Options:

| flag           | does |
|----------------|------|
| `--no-upgrade` | skip the system upgrade |
| `--no-chsh`    | keep your current default shell |
| `--nvidia`     | install NVIDIA drivers even if no GPU is detected |
| `--no-nvidia`  | never install NVIDIA drivers |
| `--no-extras`  | skip yazi, lazygit and the font |
| `--no-claude`  | don't install Claude Code |
| `--ghostty`    | also install ghostty (snap on Ubuntu, COPR on Fedora) |
| `--update`     | reinstall Neovim / yazi / lazygit / font from upstream even if present (Go and Node always update to latest) |

To add a package, put it in `APT_PACKAGES` and/or `DNF_PACKAGES` at the top of `bootstrap.sh`.
On Ubuntu, packages apt doesn't have are skipped with a warning instead of failing the run
(e.g. `fastfetch` isn't in 24.04).

<details>
<summary>Base packages</summary>

| group          | packages |
|----------------|----------|
| shell/terminal | fish, zsh, zsh-autosuggestions, zsh-syntax-highlighting, tmux, kitty, zoxide |
| editor/search  | git, git-lfs, ripgrep, fd, fzf, bat, eza, tree, unzip, zip, 7zip, jq, yq, curl, wget |
| build          | gcc, g++, clang, clangd, cmake, ninja, make, gdb, lldb, valgrind, pkg-config |
| python         | python3, pip, venv, pipx, pynvim |
| node / go      | upstream on Ubuntu (see above), distro packages on Fedora |
| graphics       | glxinfo (mesa-utils / mesa-demos), vulkan-tools |
| utilities      | htop, btop, fastfetch, wl-clipboard, xclip, direnv, stow, shellcheck, notify-send |
| misc           | sqlite, just |

</details>

### 3. Symlink the configs

```sh
./scripts/stow_all.sh
```

Runs `stow` for each package folder (`fish`, `zsh`, `nvim`, `tmux`, `kitty`, `ghostty`, `claude`) into `$HOME`.
It also adds the Claude Code hooks from `scripts/claude-settings.json` to `~/.claude/settings.json`
(merged with `jq`, keeping your existing settings; safe to re-run).
Existing files that would conflict (`config.fish`, `kitty.conf`, `tmux.conf`, `~/.tmux.conf`,
`~/.zshrc`) are moved to `<file>.bak` first.

To stow a single package by hand:

```sh
stow -Rv --target="$HOME" nvim     # link / relink
stow -Dv --target="$HOME" nvim     # unlink
```

If stow complains about some other existing file, move it out of the way and run it again.

### 4. Log out and back in

So the new default shell and `~/.local/bin` on your `PATH` take effect. On Ubuntu this matters:
otherwise you'll get the old apt `nvim` (if installed) instead of the new one.

### 5. First Neovim launch

```sh
nvim
```

The first launch installs everything automatically. Give it a few minutes, then restart nvim:

- Neovim's built-in plugin manager (`vim.pack`) asks to install the plugins: say yes
- Mason installs the language servers and tools (`:Mason`):
  gopls, vtsls, eslint, tailwindcss, emmet, html, cssls, jsonls, lua_ls, bashls,
  prettierd, stylua, goimports, gofumpt, delve, shfmt, shellcheck, tree-sitter-cli
- Treesitter compiles its parsers once tree-sitter-cli is there (`:TSUpdate`)
- clangd comes from the system package, not Mason

Run `:checkhealth` if something looks off.

Optional: [`glsl_analyzer`](https://github.com/nolanderc/glsl_analyzer) on your `PATH` for
GLSL support. It's skipped if it isn't installed.

### Check it worked

```sh
nvim --version                       # 0.12 or newer
go version
node --version
fish --version
tmux -V
fc-list | grep -i "Cascadia Code NF" # font kitty uses
glxinfo | grep "OpenGL renderer"
nvidia-smi                           # NVIDIA only
```

## Updating

```sh
cd ~/dotfiles
git pull
./bootstrap.sh --no-upgrade   # new packages; also updates Go/Node on Ubuntu
./scripts/stow_all.sh         # picks up any new files
```

`./bootstrap.sh --update` also pulls the latest Neovim, yazi and lazygit.

In nvim: `:lua vim.pack.update()` for plugins (shows what changed; `:w` to apply),
`:MasonUpdate` for tools, `:TSUpdate` for parsers. Plugin versions are pinned in
`nvim/.config/nvim/nvim-pack-lock.json`; commit it after updating.

## What's in here

| package  | what                                                               |
|----------|--------------------------------------------------------------------|
| fish     | default shell: git prompt, fzf, `z`, abbreviations, `y`, `wt`      |
| zsh      | alternative shell: no framework, git prompt, fzf, zoxide, autosuggest |
| kitty    | terminal, oxocarbon, starts inside tmux                             |
| ghostty  | terminal                                                           |
| tmux     | prefix `C-a`, oxocarbon status bar, no plugin manager              |
| nvim     | Neovim 0.12, `vim.pack`, LSP via Mason (Go, TS/React, C/C++, Lua, ...) |
| claude   | `~/.claude/CLAUDE.md` (personal preferences) + tmux status hook    |

Each folder mirrors where its files go under `$HOME`, e.g. `nvim/.config/nvim/init.lua` →
`~/.config/nvim/init.lua`.

The Neovim config (structure borrowed from [craftzdog's](https://github.com/craftzdog/dotfiles)):

```
nvim/.config/nvim/
  init.lua                 loads the rest
  lua/anton/config/        options, plain keymaps, autocmds
  lua/anton/plugins/
    init.lua               the list of every plugin (add / remove plugins here)
    ui.lua editor.lua treesitter.lua lsp.lua debug.lua util.lua   plugin setup by topic
    keymaps.lua            every plugin shortcut, each with a description
```

Kitty opens straight into a tmux session called `main` (a new session if `main` is
already attached somewhere else). tmux copies to the clipboard with `wl-copy`, so it expects
Wayland (the default on Ubuntu 24.04 and Fedora).

## AI workflow (Claude Code)

The setup: nvim on the left, Claude on the right (`<prefix> a`), lazygit to review (`<prefix> g`).
When Claude finishes or needs permission, its tmux window gets a pink **●** and, if you're
looking at another window, a desktop notification.

Habits that make it work:

1. **Commit before each task.** Then `git diff` shows exactly what the agent did, and
   `git restore .` undoes all of it.
2. **Small, specific tasks**: name the file, the expected behaviour, and how to check it.
3. **Plan first for anything bigger**: `Shift+Tab` switches to plan mode (reads code, proposes
   steps, changes nothing).
4. **Review every diff** in lazygit (`<prefix> g`) before committing.
5. **Let it check itself**: tell it which tests / linter / build to run.
6. **`/init`** in a repo writes a project `CLAUDE.md`; keep adding to it. Personal preferences
   for every project are in `claude/.claude/CLAUDE.md`.
7. **`/clear`** between unrelated tasks.

**Parallel agents:** give each one its own checkout with `wt` (fish):

```fish
wt fix-login        # creates ../<repo>-fix-login on branch fix-login and cd's into it
claude              # or <prefix> A for a new tmux window
wt                  # list worktrees
wt rm fix-login     # remove it when merged (the branch is kept)
```

## Keys worth remembering

**tmux** (prefix `C-a`)
- `|` / `-` split, `c` new window, `M-1..5` jump to window, `r` reload
- `C-h/j/k/l` move between tmux panes *and* nvim splits (no prefix)
- `a` Claude in a split on the right, `A` Claude in a new window, `g` lazygit pop-up
- `v` copy mode, `v` select, `y` copy to clipboard; `C-a C-l` clears the screen

**fish**
- abbreviations: `g` git, `gs` status, `gd` diff, `gl` log graph, `v` nvim, `ta` attach tmux
- `Ctrl-r` history, `Ctrl-t` files, `Alt-c` cd (fzf); `z <dir>` jump to a visited folder
- `y` yazi (cd on quit), `wt` git worktrees
- machine-specific settings go in `~/.config/fish/config.local.fish` (not in git)

**nvim** (leader `Space`). Don't memorise this: press `Space` and wait for the menu, or
`Space ?` to search every shortcut. The start screen lists the common ones too.
- `<leader>f…` find: `ff` files, `fw` grep, `fr` recent, `<leader><leader>` buffers, `f.` resume,
  `fs` symbols, `ft` TODOs, `fd` diagnostics, `fn` nvim config
- `gd` / `gr` / `gi` / `gy` / `K` LSP navigation; `<leader>c…` code: `ca` action, `cr` rename,
  `cf` format, `cd` line diagnostics
- `<leader>u…` toggles: `uf` format on save, `uh` inlay hints, `uw` wrap, `ud` diagnostics
- `<leader>g…` git: `gg` lazygit, `gs` / `gr` stage / reset hunk, `gp` preview, `gb` blame;
  `]h` / `[h` next/prev hunk
- `<leader>x…` Trouble lists, `]d` / `[d` next/prev diagnostic
- `<leader>db` breakpoint, `F5` debug, `<leader>dt` debug Go test
- `-` oil file explorer, `<leader>e` oil float, `<leader>-` yazi
- completion: `Enter` accept, `Tab` / `S-Tab` move, `C-Space` open
- `sa` / `sd` / `sr` add/delete/replace surroundings

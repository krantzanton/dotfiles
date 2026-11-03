# dotfiles
all my dotfiles (or my attempt at it)

Configs for fish, zsh, kitty, ghostty, tmux and Neovim, symlinked into `$HOME` with
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
- **Ubuntu only:** installs the latest **Neovim**, **Go** and **Node.js LTS** from their
  official downloads into `~/.local/opt` (linked into `~/.local/bin`). The apt versions are too
  old: Ubuntu 24.04 ships Neovim 0.9, and this config needs 0.11+. Also links `fdfind` → `fd`
  and `batcat` → `bat`.
- installs [yazi](https://github.com/sxyazi/yazi) (file manager, `<leader>-` in nvim) and
  [lazygit](https://github.com/jesseduffield/lazygit) (git UI, `<leader>lg` in nvim) into `~/.local/bin`
- installs the **Cascadia Code NF** font kitty uses (into `~/.local/share/fonts` on Ubuntu)
- installs NVIDIA drivers **only if an NVIDIA GPU is detected** (`ubuntu-drivers install` on
  Ubuntu, `akmod-nvidia` on Fedora)
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
| utilities      | htop, btop, fastfetch, wl-clipboard, xclip, direnv, stow, shellcheck |
| misc           | sqlite, just |

</details>

### 3. Symlink the configs

```sh
./scripts/stow_all.sh
```

Runs `stow` for each package folder (`fish`, `zsh`, `nvim`, `tmux`, `kitty`, `ghostty`) into `$HOME`.
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

The first launch installs everything automatically. Give it a minute, then restart nvim:

- [lazy.nvim](https://github.com/folke/lazy.nvim) installs the plugins (`:Lazy`)
- Mason installs the language servers and tools (`:Mason`):
  gopls, ts_ls, eslint, tailwindcss, html, cssls, jsonls, lua_ls, bashls,
  prettierd, stylua, goimports, gofumpt, delve, shfmt
- Treesitter installs its parsers (`:TSUpdate`)
- clangd comes from the system package, not Mason

Run `:checkhealth` if something looks off.

Optional: [`glsl_analyzer`](https://github.com/nolanderc/glsl_analyzer) on your `PATH` for
GLSL support. It's skipped if it isn't installed.

### Check it worked

```sh
nvim --version                       # 0.11 or newer
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

On Ubuntu, `./bootstrap.sh --update` also pulls the latest Neovim, yazi and lazygit.

In nvim: `:Lazy sync` for plugins, `:MasonUpdate` for tools, `:TSUpdate` for parsers.
Plugin versions are pinned in `nvim/.config/nvim/lazy-lock.json`, commit it after updating.

## What's in here

| package  | what                                                               |
|----------|--------------------------------------------------------------------|
| fish     | default shell                                                      |
| zsh      | alternative shell: no framework, git prompt, fzf, zoxide, autosuggest |
| kitty    | terminal, oxocarbon, starts inside tmux                             |
| ghostty  | terminal                                                           |
| tmux     | prefix `C-a`, oxocarbon status bar, no plugin manager              |
| nvim     | lazy.nvim, LSP via Mason (Go, TS/React, C/C++, Lua, ...)           |

Each folder mirrors where its files go under `$HOME`, e.g. `nvim/.config/nvim/init.lua` →
`~/.config/nvim/init.lua`.

Kitty opens straight into a tmux session called `main` (a new session if `main` is
already attached somewhere else). tmux copies to the clipboard with `wl-copy`, so it expects
Wayland (the default on Ubuntu 24.04 and Fedora).

## Keys worth remembering

**tmux** (prefix `C-a`)
- `|` / `-` split, `c` new window, `M-1..5` jump to window, `r` reload
- `C-h/j/k/l` move between tmux panes *and* nvim splits (no prefix)
- `v` copy mode, `v` select, `y` copy to clipboard; `C-a C-l` clears the screen

**nvim** (leader `Space`, press it and wait for which-key)
- `<leader>f…` find: `ff` files, `fw` grep, `fr` recent, `fs` symbols, `ft` TODOs
- `gd` / `gr` / `gi` / `gy` / `K` LSP navigation, `<leader>rn` rename, `<leader>ca` code action
- `<leader>cf` format (also on save; `:FormatToggle`), `<leader>ch` inlay hints
- `<leader>x…` Trouble diagnostics list, `]d` / `[d` next/prev diagnostic
- `<leader>g…` git hunks, `]h` / `[h` next/prev hunk, `<leader>lg` lazygit
- `<leader>db` breakpoint, `F5` debug, `<leader>dt` debug Go test
- `-` oil file explorer, `<leader>-` yazi
- `sa` / `sd` / `sr` add/delete/replace surroundings

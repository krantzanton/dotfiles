#!/usr/bin/env bash
set -euo pipefail

# Developer machine bootstrap. Safe to re-run.
#
# Supported: Ubuntu 24.04 LTS (main target), Fedora (41+).
# Other Debian/Ubuntu-based distros will probably work but aren't tested.
#
# Usage: ./bootstrap.sh [options]
# Opt-in extras (not installed unless asked for):
#   --cpp          C/C++ toolchain + debuggers: clang, clangd, cmake, ninja, gdb, lldb, valgrind
#   --graphics     graphics sanity tools: glxinfo, vulkaninfo
#   --nvidia       NVIDIA drivers + nvidia-smi
#   --ghostty      the ghostty terminal
#
# Other options:
#   --no-upgrade   don't upgrade system packages first
#   --no-chsh      don't make fish the default shell
#   --no-extras    skip yazi, lazygit and JetBrainsMono Nerd Font
#   --no-claude    don't install Claude Code
#   --update       reinstall tools from upstream even if already installed
#   -h, --help     show this help
#
# To add a package: put it in APT_PACKAGES and/or DNF_PACKAGES below (or the *_CPP /
# *_GRAPHICS lists for the opt-in groups).
# On apt, packages that don't exist are skipped with a warning instead of failing.

# --- Packages ---------------------------------------------------------------

# Ubuntu / Debian. neovim, go and node are NOT here on purpose: the apt versions
# are too old for this config, so they come from upstream (see install_upstream_*).
# Neovim comes from upstream on Fedora too (the config needs 0.12+).
APT_PACKAGES=(
  # shell / terminal
  fish tmux kitty zoxide ncurses-term

  # editor + search + file tools
  git git-lfs ripgrep fd-find fzf bat eza tree unzip zip p7zip-full jq yq
  curl wget ca-certificates tar gzip xz-utils

  # basic build tools (Neovim compiles treesitter parsers with gcc)
  build-essential gcc g++ make pkg-config

  # Python (python3-pynvim is the Neovim Python provider)
  python3 python3-pip python3-venv pipx python3-pynvim

  # utilities
  htop btop fastfetch wl-clipboard xclip direnv stow shellcheck pciutils fontconfig
  libnotify-bin # notify-send, used by the Claude Code hook

  # misc dev niceties
  sqlite3 just
)

# Fedora
DNF_PACKAGES=(
  # shell / terminal
  fish tmux kitty zoxide

  # editor + search + file tools
  git git-lfs ripgrep fd-find fzf bat eza tree unzip zip p7zip jq yq
  curl wget tar gzip xz

  # basic build tools (Neovim compiles treesitter parsers with gcc)
  gcc gcc-c++ make pkgconf-pkg-config

  # Python (python3-neovim is the Neovim Python provider)
  python3 python3-pip python3-virtualenv pipx python3-neovim

  # Node.js + Go (Neovim tooling, language servers)
  nodejs npm golang

  # utilities
  htop btop fastfetch wl-clipboard xclip direnv stow ShellCheck pciutils fontconfig
  libnotify # notify-send, used by the Claude Code hook

  # misc dev niceties
  sqlite just
)

# Opt-in groups. clangd is the C/C++ language server Neovim uses when it's installed.
APT_CPP=(clang clangd clang-format cmake ninja-build gdb lldb valgrind)
DNF_CPP=(clang clang-tools-extra cmake ninja-build gdb lldb valgrind)
APT_GRAPHICS=(mesa-utils vulkan-tools)
DNF_GRAPHICS=(mesa-demos vulkan-tools)

# --- Options ----------------------------------------------------------------

DO_UPGRADE=1
DO_CHSH=1
WITH_CPP=0
WITH_GRAPHICS=0
WITH_NVIDIA=0
DO_EXTRAS=1
DO_CLAUDE=1
WITH_GHOSTTY=0
FORCE_UPDATE=0

usage() { awk 'NR >= 4 && /^#/ { sub(/^# ?/, ""); print; next } NR > 4 { exit }' "$0"; }

while (($#)); do
  case "$1" in
    --no-upgrade) DO_UPGRADE=0 ;;
    --no-chsh) DO_CHSH=0 ;;
    --cpp) WITH_CPP=1 ;;
    --graphics) WITH_GRAPHICS=1 ;;
    --nvidia) WITH_NVIDIA=1 ;;
    --no-extras) DO_EXTRAS=0 ;;
    --no-claude) DO_CLAUDE=0 ;;
    --ghostty) WITH_GHOSTTY=1 ;;
    --update) FORCE_UPDATE=1 ;;
    -h | --help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

# --- Helpers ----------------------------------------------------------------

LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
FONT_DIR="$HOME/.local/share/fonts"
export PATH="$LOCAL_BIN:$PATH"

log() { printf '\n==> %s\n' "$*"; }
warn() { printf '\n!!  %s\n' "$*" >&2; }
die() { printf '\nerror: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
fetch() { curl -fsSL --retry 3 "$@"; }

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

detect_distro() {
  [[ -r /etc/os-release ]] || die "can't read /etc/os-release"
  # shellcheck disable=SC1091
  . /etc/os-release
  DISTRO_ID="${ID:-unknown}"
  DISTRO_VERSION="${VERSION_ID:-}"

  case "$DISTRO_ID ${ID_LIKE:-}" in
    *ubuntu* | *debian*) PKG=apt ;;
    *fedora*) PKG=dnf ;;
    *) die "unsupported distro: $DISTRO_ID (supported: Ubuntu, Fedora)" ;;
  esac

  if [[ $DISTRO_ID == ubuntu && $DISTRO_VERSION != 24.04 ]]; then
    warn "tested on Ubuntu 24.04, you're on $DISTRO_VERSION; continuing anyway"
  fi
  log "Detected $DISTRO_ID $DISTRO_VERSION (using $PKG)"
}

detect_arch() {
  case "$(uname -m)" in
    x86_64) ARCH_GO=amd64 ARCH_NODE=x64 ARCH_NVIM=x86_64 ARCH_RUST=x86_64 ARCH_LAZYGIT=x86_64 ;;
    aarch64 | arm64) ARCH_GO=arm64 ARCH_NODE=arm64 ARCH_NVIM=arm64 ARCH_RUST=aarch64 ARCH_LAZYGIT=arm64 ;;
    *) die "unsupported CPU architecture: $(uname -m)" ;;
  esac
}

apt_install() {
  local available=() missing=() p
  for p in "$@"; do
    if apt-cache show "$p" >/dev/null 2>&1; then available+=("$p"); else missing+=("$p"); fi
  done
  if ((${#missing[@]})); then
    warn "not in apt, skipping: ${missing[*]}"
  fi
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${available[@]}"
}

dnf_install() {
  sudo dnf install -y --skip-unavailable "$@"
}

# --- System packages --------------------------------------------------------

prepare_package_manager() {
  case $PKG in
    apt)
      if [[ $DISTRO_ID == ubuntu ]] && ! grep -rqs '^[^#].*universe' /etc/apt/sources.list /etc/apt/sources.list.d/; then
        log "Enabling the universe repository"
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
        sudo add-apt-repository -y universe
      fi
      log "Updating apt package lists"
      sudo apt-get update
      ;;
    dnf)
      enable_rpmfusion
      ;;
  esac
}

enable_rpmfusion() {
  if rpm -q rpmfusion-free-release rpmfusion-nonfree-release >/dev/null 2>&1; then
    log "RPM Fusion already enabled"
    return
  fi
  local ver
  ver="$(rpm -E %fedora)"
  log "Enabling RPM Fusion for Fedora $ver"
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${ver}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${ver}.noarch.rpm"
}

upgrade_system() {
  ((DO_UPGRADE)) || return 0
  log "Upgrading system packages"
  case $PKG in
    apt) sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y ;;
    dnf) sudo dnf upgrade -y ;;
  esac
}

install_base_packages() {
  log "Installing base packages"
  case $PKG in
    apt) apt_install "${APT_PACKAGES[@]}" ;;
    dnf) dnf_install "${DNF_PACKAGES[@]}" ;;
  esac
}

install_optional_packages() {
  if ((WITH_CPP)); then
    log "Installing C/C++ toolchain + debuggers (--cpp)"
    case $PKG in
      apt) apt_install "${APT_CPP[@]}" ;;
      dnf) dnf_install "${DNF_CPP[@]}" ;;
    esac
  fi
  if ((WITH_GRAPHICS)); then
    log "Installing graphics tools (--graphics)"
    case $PKG in
      apt) apt_install "${APT_GRAPHICS[@]}" ;;
      dnf) dnf_install "${DNF_GRAPHICS[@]}" ;;
    esac
  fi
}

# Debian ships fd as `fdfind` and bat as `batcat`; give them their usual names.
link_debian_binary_names() {
  [[ $PKG == apt ]] || return 0
  mkdir -p "$LOCAL_BIN"
  if have fdfind && ! have fd; then ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"; fi
  if have batcat && ! have bat; then ln -sf "$(command -v batcat)" "$LOCAL_BIN/bat"; fi
}

# --- Upstream tools (apt versions are too old) -------------------------------

# Neovim: this config needs 0.12+ (built-in vim.pack). Ubuntu 24.04 ships 0.9, Fedora 43 0.11.
install_upstream_neovim() {
  local dest="$LOCAL_OPT/nvim"
  if [[ -x $dest/bin/nvim ]] && ((!FORCE_UPDATE)); then
    log "Neovim already installed ($("$dest/bin/nvim" --version | head -1)); --update to reinstall"
    return
  fi
  log "Installing latest Neovim release into $dest"
  fetch "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${ARCH_NVIM}.tar.gz" |
    tar -xz -C "$TMP_DIR"
  mkdir -p "$LOCAL_OPT" "$LOCAL_BIN"
  rm -rf "$dest"
  mv "$TMP_DIR/nvim-linux-${ARCH_NVIM}" "$dest"
  ln -sf "$dest/bin/nvim" "$LOCAL_BIN/nvim"
}

# Go: gopls needs a recent Go, Ubuntu 24.04 ships 1.22.
install_upstream_go() {
  local dest="$LOCAL_OPT/go" version
  version="$(fetch 'https://go.dev/VERSION?m=text' | head -1)"
  if [[ -x $dest/bin/go ]] && [[ "$("$dest/bin/go" env GOVERSION)" == "$version" ]]; then
    log "Go $version already installed"
    return
  fi
  log "Installing $version into $dest"
  mkdir -p "$LOCAL_OPT" "$LOCAL_BIN"
  rm -rf "$dest"
  fetch "https://go.dev/dl/${version}.linux-${ARCH_GO}.tar.gz" | tar -xz -C "$LOCAL_OPT"
  ln -sf "$dest/bin/go" "$LOCAL_BIN/go"
  ln -sf "$dest/bin/gofmt" "$LOCAL_BIN/gofmt"
}

# Node.js LTS: Ubuntu 24.04 ships 18, which is end-of-life.
install_upstream_node() {
  local dest="$LOCAL_OPT/node" version name
  version="$(fetch https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts)][0].version')"
  if [[ -x $dest/bin/node ]] && [[ "$("$dest/bin/node" --version)" == "$version" ]]; then
    log "Node.js $version already installed"
    return
  fi
  name="node-${version}-linux-${ARCH_NODE}"
  log "Installing Node.js $version (LTS) into $dest"
  fetch "https://nodejs.org/dist/${version}/${name}.tar.xz" | tar -xJ -C "$TMP_DIR"
  mkdir -p "$LOCAL_OPT" "$LOCAL_BIN"
  rm -rf "$dest"
  mv "$TMP_DIR/$name" "$dest"
  local bin
  for bin in node npm npx corepack; do
    if [[ -e $dest/bin/$bin ]]; then ln -sf "$dest/bin/$bin" "$LOCAL_BIN/$bin"; fi
  done
}

install_upstream_tools() {
  install_upstream_neovim
  [[ $PKG == apt ]] || return 0 # Fedora's Go and Node are new enough
  install_upstream_go
  install_upstream_node
}

# --- Extras -----------------------------------------------------------------

install_yazi() {
  if have yazi && ((!FORCE_UPDATE)); then
    log "yazi already installed"
    return
  fi
  local name="yazi-${ARCH_RUST}-unknown-linux-gnu"
  log "Installing yazi into $LOCAL_BIN"
  fetch -o "$TMP_DIR/yazi.zip" "https://github.com/sxyazi/yazi/releases/latest/download/${name}.zip"
  unzip -qo "$TMP_DIR/yazi.zip" -d "$TMP_DIR"
  mkdir -p "$LOCAL_BIN"
  install -m 755 "$TMP_DIR/$name/yazi" "$TMP_DIR/$name/ya" "$LOCAL_BIN/"
}

# lazygit: git TUI, opened with <leader>lg in nvim. Not in Ubuntu 24.04's apt.
install_lazygit() {
  if have lazygit && ((!FORCE_UPDATE)); then
    log "lazygit already installed"
    return
  fi
  local version
  version="$(fetch https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name)"
  [[ $version == v* ]] || { warn "couldn't find the latest lazygit release; skipping"; return; }
  log "Installing lazygit $version into $LOCAL_BIN"
  fetch "https://github.com/jesseduffield/lazygit/releases/download/${version}/lazygit_${version#v}_Linux_${ARCH_LAZYGIT}.tar.gz" |
    tar -xz -C "$TMP_DIR" lazygit
  mkdir -p "$LOCAL_BIN"
  install -m 755 "$TMP_DIR/lazygit" "$LOCAL_BIN/"
}

# kitty uses "JetBrainsMono Nerd Font": JetBrains Mono (Ghostty's built-in default) plus the
# Nerd Font icons. Same release on both distros, from github.com/ryanoasis/nerd-fonts.
install_jetbrains_font() {
  if fc-list | grep -qi 'JetBrainsMono Nerd Font' && ((!FORCE_UPDATE)); then
    log "JetBrainsMono Nerd Font already installed"
    return
  fi
  log "Installing JetBrainsMono Nerd Font into $FONT_DIR"
  mkdir -p "$FONT_DIR/JetBrainsMono"
  fetch "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" |
    tar -xJ -C "$FONT_DIR/JetBrainsMono" --wildcards 'JetBrainsMonoNerdFont-*.ttf' ||
    { warn "couldn't download JetBrainsMono Nerd Font; skipping"; return; }
  fc-cache -f >/dev/null
}

install_extras() {
  ((DO_EXTRAS)) || return 0
  install_yazi
  install_lazygit
  install_jetbrains_font
}

install_ghostty() {
  ((WITH_GHOSTTY)) || return 0
  if have ghostty; then
    log "ghostty already installed"
    return
  fi
  log "Installing ghostty"
  case $PKG in
    apt)
      if have snap; then
        sudo snap install ghostty --classic
      else
        warn "snap not available; see https://ghostty.org/docs/install/binary for other options"
      fi
      ;;
    dnf)
      sudo dnf copr enable -y scottames/ghostty
      sudo dnf install -y ghostty
      ;;
  esac
}

# Claude Code (AI coding agent), official native installer -> ~/.local/bin/claude.
# It updates itself after that.
install_claude_code() {
  ((DO_CLAUDE)) || return 0
  if have claude; then
    log "Claude Code already installed ($(claude --version 2>/dev/null | head -1))"
    return
  fi
  log "Installing Claude Code"
  fetch https://claude.ai/install.sh | bash || warn "Claude Code install failed; see https://code.claude.com/docs"
}

# --- NVIDIA -----------------------------------------------------------------

install_nvidia() {
  ((WITH_NVIDIA)) || return 0
  if ! lspci 2>/dev/null | grep -qi nvidia; then
    warn "--nvidia given but no NVIDIA GPU detected; installing anyway"
  fi

  case $PKG in
    apt)
      log "Installing recommended NVIDIA driver (ubuntu-drivers)"
      apt_install ubuntu-drivers-common
      sudo ubuntu-drivers install
      ;;
    dnf)
      log "Installing NVIDIA driver + nvidia-smi (RPM Fusion)"
      sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
      ;;
  esac
}

# --- Shell & tooling setup --------------------------------------------------

configure_fish_as_default_shell() {
  ((DO_CHSH)) || return 0
  have fish || { warn "fish not found; skipping shell change"; return; }

  local fish_path current
  fish_path="$(command -v fish)"
  current="$(getent passwd "$USER" | cut -d: -f7)"
  if [[ $current == "$fish_path" ]]; then
    log "Default shell already fish"
    return
  fi
  grep -qx "$fish_path" /etc/shells || echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  log "Changing default shell to fish"
  sudo chsh -s "$fish_path" "$USER"
}

setup_git_lfs() {
  log "Enabling Git LFS"
  git lfs install --skip-repo || true
}

install_neovim_node_provider() {
  have npm || { warn "npm not found; skipping Neovim Node.js provider"; return; }

  # Keep global npm installs in ~/.local so they never need sudo
  if [[ "$(npm config get prefix)" == /usr* ]]; then
    npm config set prefix "$HOME/.local"
  fi
  if npm list -g neovim --depth=0 >/dev/null 2>&1; then
    log "Neovim Node.js provider already installed"
    return
  fi
  log "Installing Neovim Node.js provider"
  npm install -g neovim
}

print_next_steps() {
  cat <<'EOF'

Next steps:
  1. ./scripts/stow_all.sh     symlink the configs into $HOME
  2. log out and back in       picks up the new default shell + PATH
  3. nvim                      first launch installs plugins + language servers
  4. claude                    log in once; then <prefix> a in tmux opens it beside nvim

Quick checks:
  nvim --version     (should be 0.12 or newer)
  go version
  node --version
  claude --version
  fc-list | grep -i "JetBrainsMono Nerd Font"
EOF
}

main() {
  detect_distro
  detect_arch
  sudo -v

  prepare_package_manager
  upgrade_system
  install_base_packages
  install_optional_packages
  link_debian_binary_names
  install_upstream_tools
  install_extras
  install_ghostty
  install_claude_code
  install_nvidia
  configure_fish_as_default_shell
  setup_git_lfs
  install_neovim_node_provider
  print_next_steps

  log "Bootstrap complete"
}

main

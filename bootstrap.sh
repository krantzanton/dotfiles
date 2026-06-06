#!/usr/bin/env bash
set -euo pipefail

# Fedora workstation bootstrap for a fresh developer machine.
# Intended to live in your dotfiles/setup repo and grow over time.
#
# Current goals:
# - fresh Fedora developer environment
# - fish as interactive shell
# - Neovim-based workflow
# - graphics/OpenGL sanity tools
# - easy to re-run after reinstall
#
# Example:
#   ./bootstrap.sh
#
# Future direction:
# - split package groups into separate files
# - symlink dotfiles with GNU stow
# - optional flags for graphics / gaming / extras

log() {
  printf '
==> %s
' "$*"
}

require_sudo() {
  sudo -v
}

fedora_version() {
  rpm -E %fedora
}

enable_rpmfusion() {
  if rpm -q rpmfusion-free-release >/dev/null 2>&1 && rpm -q rpmfusion-nonfree-release >/dev/null 2>&1; then
    log "RPM Fusion already enabled"
    return
  fi

  local fedora_ver
  fedora_ver="$(fedora_version)"
  log "Enabling RPM Fusion for Fedora ${fedora_ver}"
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_ver}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_ver}.noarch.rpm"
}

upgrade_system() {
  log "Upgrading system packages"
  sudo dnf upgrade -y
}

install_base_packages() {
  local packages=(
    # shell / terminal
    fish tmux

    # editor + search + file tools
    neovim git git-lfs ripgrep fd-find fzf bat eza tree unzip zip p7zip jq yq

    # build tools
    gcc gcc-c++ clang clang-tools-extra cmake ninja-build make gdb lldb valgrind pkgconf-pkg-config

    # Python
    python3 python3-pip python3-virtualenv pipx

    # Node.js (needed for some Neovim tooling)
    nodejs npm

    # graphics / debug sanity tools
    mesa-demos vulkan-tools

    # utilities
    htop btop fastfetch wl-clipboard xclip direnv stow ShellCheck

    # fonts / terminal icons
    cascadia-code-nf-fonts

    # misc dev niceties
    sqlite just
  )

  log "Installing base packages"
  sudo dnf install -y "${packages[@]}"
}

install_nvidia_utils() {
  log "Installing NVIDIA utility package for nvidia-smi"
  sudo dnf install -y xorg-x11-drv-nvidia-cuda
}

configure_fish_as_default_shell() {
  if ! command -v fish >/dev/null 2>&1; then
    log "fish not found; skipping shell change"
    return
  fi

  local fish_path
  fish_path="$(command -v fish)"

  if [[ "$SHELL" != "$fish_path" ]]; then
    log "Changing default shell to fish"
    chsh -s "$fish_path"
  else
    log "Default shell already set to fish"
  fi
}

setup_git_lfs() {
  log "Enabling Git LFS"
  git lfs install --skip-repo || true
}

install_neovim_python_provider() {
  log "Installing pynvim for Neovim Python provider"
  python3 -m pip install --user --upgrade pynvim
}

install_neovim_node_provider() {
  log "Ensuring Neovim Node.js provider is installed"

  if npm list -g neovim --depth=0 >/dev/null 2>&1; then
    log "Neovim Node.js provider already installed globally"
    return
  fi

  if npm config get prefix 2>/dev/null | grep -q '^/usr'; then
    log "Global npm prefix is system-owned; installing Neovim Node.js provider in user prefix"
    mkdir -p "$HOME/.local"
    npm config set prefix "$HOME/.local"
  fi

  npm install -g neovim
}

refresh_font_cache() {
  if command -v fc-cache >/dev/null 2>&1; then
    log "Refreshing font cache"
    fc-cache -fv >/dev/null
  fi
}

print_next_steps() {
  cat <<'EOF'

Next suggested steps for the dotfiles repo:
  1. Add GNU stow-managed directories:
       dotfiles/
         fish/
         nvim/
         tmux/
         git/
  2. Add a bootstrap README with exact first-run instructions.
  3. Add a packages list file to avoid one giant script.
  4. Add optional extras later (Steam, podman, more fonts, GUI apps, etc).

Manual checks:
  - nvim --version
  - fish --version
  - git lfs version
  - python3 -c "import pynvim; print(pynvim.__version__)"
  - npm config get prefix
  - npm list -g neovim --depth=0
  - fc-list | grep -i "Cascadia.*NF"
  - glxinfo | grep "OpenGL renderer"
  - vulkaninfo | grep deviceName
  - nvidia-smi

You may need to log out and back in for the shell change to take effect.
EOF
}

main() {
  require_sudo
  upgrade_system
  enable_rpmfusion
  install_base_packages
  install_nvidia_utils
  configure_fish_as_default_shell
  setup_git_lfs
  install_neovim_python_provider
  install_neovim_node_provider
  refresh_font_cache
  print_next_steps

  log "Bootstrap complete"
}

main "$@"


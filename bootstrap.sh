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

    # graphics / debug sanity tools
    mesa-demos vulkan-tools

    # utilities
    htop btop fastfetch wl-clipboard xclip direnv stow ShellCheck

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
  4. Add optional extras later (Steam, podman, fonts, GUI apps, etc).

Manual checks:
  - nvim --version
  - fish --version
  - git lfs version
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
  print_next_steps

  log "Bootstrap complete"
}

main "$@"

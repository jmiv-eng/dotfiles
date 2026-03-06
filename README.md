# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). One branch (`main`), all machines.

---

## Packages

| Package | Description |
|---|---|
| `shell` | Unified shell environment (.zprofile, .zshrc, .bashrc, .bash_profile, .p10k.zsh) |
| `sway` | Sway window manager (unified config + local.conf include) |
| `waybar` | Wayland status bar (exec-if for hardware-conditional modules) |
| `shikane` | Display profile management (all machines' profiles in one file) |
| `alacritty` | Terminal emulator (JetBrainsMono Nerd Font) |
| `nvim` | Neovim configuration |
| `git` | Git configuration |
| `wofi` | Wayland application launcher |
| `swaylock` | Screen lock |
| `dunst` | Notification daemon |
| `bin` | Custom scripts and executables |
| `ranger` | Terminal file manager |
| `legacy/` | Old configs kept for reference (i3, i3blocks, kanshi, rofi, desktop_xorg) |

---

## Setup

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
stow shell sway waybar shikane alacritty nvim git wofi swaylock dunst bin ranger
cp ~/.config/sway/local.conf.example ~/.config/sway/local.conf
# Edit local.conf with your monitor names, wallpapers, and workspace mapping
```

### Machine-specific config

Sway loads `~/.config/sway/local.conf` for machine-specific values (monitor names, wallpapers, workspace mapping, lock screen images). This file is not in git — copy from `local.conf.example` and customize per machine.

GPU detection happens in `.zprofile` / `.bash_profile` via hostname case statement. Nvidia machines get `--unsupported-gpu` and related env vars.

---

## Stow Commands

| Command | Description |
|---|---|
| `stow <pkg>` | Create symlinks for a package |
| `stow -D <pkg>` | Remove symlinks for a package |
| `stow -R <pkg>` | Restow (unstow + stow) |
| `stow --adopt <pkg>` | Adopt existing files into the repo |

---

## Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [DevInsideYou — Dotfiles with GNU Stow](https://youtu.be/CFzEuBGPPPg) (YouTube)

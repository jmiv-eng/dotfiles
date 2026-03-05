# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Clone this repo to `$HOME`, then stow whichever packages apply to the current machine.

---

## Packages

| Package | Description |
|---|---|
| `alacritty` | Terminal emulator |
| `bin` | Custom scripts and executables |
| `git` | Git configuration |
| `nvim` | Neovim configuration |
| `sway` | Sway window manager |
| `waybar` | Wayland status bar |
| `wofi` | Wayland application launcher |
| `swaylock` | Screen lock |
| `shikane` | Display profile management |
| `rofi` | X11 application launcher |
| `ranger` | Terminal file manager |
| `i3` | i3 window manager |
| `i3blocks` | i3 status bar |
| `laptop_wayland` | Laptop-specific shell environment (Nvidia/Wayland) |
| `desktop_wayland` | Desktop-specific shell environment (AMD/Wayland) |
| `desktop_xorg` | Legacy desktop shell environment (X11) |
| `kanshi` | Legacy display configuration (superseded by shikane) |

---

## Usage

Clone to your home directory:

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
```

> **Note:** The `-n` flag used throughout enables **simulation mode** — it prints what would happen without modifying the filesystem. Remove `-n` to apply for real.

### Stow a package

Creates symlinks in `~` pointing to the files in `<package>`:

```bash
stow -nvSt ~ <package>
```

### Unstow a package

Removes the symlinks for a package (repository files are untouched):

```bash
stow -nvDt ~ <package>
```

### Restow a package

Useful after adding or removing files from a package — equivalent to unstow then stow:

```bash
stow -nvRt ~ <package>
```

### Adopt existing files

Moves pre-existing dotfiles into the repo and replaces them with symlinks. Use with care — this overwrites files in the repo:

```bash
stow --adopt -nvSt ~ <package>
```

### Stow multiple packages at once

```bash
stow -nvSt ~ nvim alacritty git sway waybar wofi swaylock shikane bin
```

---

## Typical Setup

For a Wayland machine, stow the common packages plus the appropriate system-specific package:

```bash
# Common
stow -St ~ nvim alacritty git sway waybar wofi swaylock shikane bin

# Laptop (Nvidia + Wayland)
stow -St ~ laptop_wayland

# Desktop (AMD + Wayland)
stow -St ~ desktop_wayland
```

---

## Verifying Symlinks

Check that symlinks were created correctly:

```bash
ls -la ~ | grep '\->'
```

Check where a specific file links to:

```bash
readlink -f ~/.zshrc
```

---

## Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [GNU Stow — man page](https://linux.die.net/man/8/stow)
- [DevInsideYou — Dotfiles with GNU Stow](https://youtu.be/CFzEuBGPPPg) (YouTube)

# dotfiles — Context for AI Assistance

## Repository Purpose

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package — running `stow <package>` from `~/dotfiles` symlinks its contents into `$HOME`. One branch (`main`), all machines.

## Owner

- Username: `jmichael` (primary), `jmiv` (older alias on some machines)
- Git: `jmiv-eng` / `github@jmiv.dev`
- Shell: zsh (Powerlevel10k + oh-my-zsh), bash as fallback
- Editor: Neovim (lazy.nvim plugin manager)
- WM: Sway (Wayland)
- Terminal: Alacritty (JetBrainsMono Nerd Font)
- Display management: Shikane

## Machines

| Hostname | GPU | Type |
|---|---|---|
| vu | Nvidia | Work laptop (BOE 3840x2160 + Samsung ultrawide dock) |
| wave | Nvidia | Work laptop (1080p + triple-monitor dock) |
| — | Intel | Home laptop |
| jarvis | AMD | Home PC (LG 27GL850 144Hz + Dell U2715H portrait) |

All machines run Arch Linux + Sway (Wayland).

## Architecture

### Multi-machine strategy

All packages are shared — stow everything on every machine. Machine-specific values are handled by:

1. **`~/.config/sway/local.conf`** — not in git, not stowed. Contains monitor names, wallpapers, workspace mapping, lock screen config. Template at `sway/.config/sway/local.conf.example`.
2. **Hostname case in `.zprofile`/`.bash_profile`** — Nvidia machines get GPU env vars and `--unsupported-gpu`.
3. **Waybar `exec-if`** — GPU temp module only renders on machines with the AMD GPU hwmon path.
4. **Shikane profiles** — all machines' display profiles in one file; they self-select based on connected hardware.
5. **Waybar `include`** — optional `~/.config/waybar/machine.json` for per-machine module overrides.

### Package structure

```
shell/             unified shell environment (.zprofile, .zshrc, .bashrc, .bash_profile, .p10k.zsh)
sway/              sway config + local.conf.example
waybar/            status bar (exec-if for conditional modules)
shikane/           display profiles for all machines
alacritty/         terminal emulator
nvim/              neovim (lazy.nvim, LSP, treesitter, telescope, vimtex)
git/               git config
wofi/              app launcher
swaylock/          screen lock
dunst/             notification daemon
bin/               custom scripts
ranger/            file manager
legacy/            old configs for reference (i3, i3blocks, kanshi, rofi, desktop_xorg)
```

### Files NOT in git (machine-local)

- `~/.config/sway/local.conf` — monitor/wallpaper/workspace config
- `~/.config/waybar/machine.json` — optional waybar overrides
- `~/.vutility_secure` — work-specific secrets/exports

## Key Conventions

- Stow target is `$HOME` (run `stow <pkg>` from `~/dotfiles`)
- `stow --adopt` to pull existing files into the repo
- Audio uses `@DEFAULT_SINK@` (not deprecated `pacmd`)
- Cursor theme: capitaine-cursors
- GTK theme: Adwaita-dark
- Sway silently ignores missing `include` files
- Shikane profiles use vendor/serial matching where possible, port-name matching as fallback

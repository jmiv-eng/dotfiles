# Dotfiles Consolidation — Implementation Plan

## Goal

Consolidate three machine-specific branches (`work-laptop`, `origin/pc`, `origin/work-2`) into a single unified `main` branch. All packages are shared — stow everything on every machine. Machine-specific values (wallpapers, monitor names, workspace mapping) live in a single `local.conf` file per machine, not in git.

All work happens on the `work-laptop` branch, then merges to `main`.

### Source branches:

- **work-laptop** — Nvidia laptop, current machine (BOE 3840x2160 panel, Samsung ultrawide dock)
- **origin/pc** — AMD desktop (LG 27GL850 144Hz + Dell U2715H portrait)
- **origin/work-2** — Nvidia work laptop #2 (eDP-1 1920x1080, triple-monitor dock setup)

---

## Phase 0: Unstow existing packages

Before creating new packages, unstow the old machine-specific packages on the current machine to avoid symlink collisions:

```bash
stow -Dt ~ laptop_wayland
```

---

## Phase 1: Create the unified `shell/` package

Create `shell/` with six files, merging the best of all three branches.

### `shell/.zprofile`

```zsh
# Default programs
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"
export READER="evince"
export LANG=en_US.UTF-8

# Secrets (not in git)
[ -f ~/.vutility_secure ] && source ~/.vutility_secure

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Launch sway on TTY1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export MOZ_ENABLE_WAYLAND=1
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_TYPE=wayland

    case "$(hostname)" in
        work-laptop-1|work-laptop-2)
            export GBM_BACKEND=nvidia-drm
            export WLR_NO_HARDWARE_CURSORS=1
            exec sway --unsupported-gpu 2>&1
            ;;
        *)
            exec sway
            ;;
    esac
fi
```

### `shell/.zshrc`

Based on work-laptop version (cleaned up), incorporating improvements from work-2:
- Powerlevel10k instant prompt at top
- `$HOME/bin`, `/usr/local/bin`, `$HOME/.cargo/bin` in PATH
- Full plugin list: `archlinux gitfast colored-man-pages colorize command-not-found cp dirhistory sudo`
- Aliases: `ls`, `ll`, `l`, `vim`, `vi`, `rm` safety, `cl`
- Conditional oh-my-zsh source: `[[ -f /usr/share/oh-my-zsh/oh-my-zsh.sh ]] && source ...`
- Conditional cargo source: `[[ -f ~/.cargo/env ]] && source ~/.cargo/env`
- SSH agent detection from work-2 (find existing socket or start new agent)
- Source `~/.zprofile`
- Source `~/.zshrc.local` if it exists (escape hatch)
- p10k configuration at bottom

### `shell/.p10k.zsh`

Taken from either branch (both have it). This is the Powerlevel10k theme config.

### `shell/.bashrc`

Merge of all versions:
- Aliases: `ls`, `ll`, `l`, `vim`, `vi`, `rm` safety
- Bash prompt with colors
- `$HOME/bin` in PATH (no hardcoded username)
- `QT_QPA_PLATFORMTHEME="qt5ct"`
- Conditional cargo source
- SSH agent detection (same as .zshrc)
- Source `~/.bashrc.local` if it exists (escape hatch)

### `shell/.bash_profile`

Same structure as `.zprofile` but for bash login shells. Sources `.vutility_secure`, sources `.bashrc`, has the same sway launch block.

---

## Phase 2: Create unified sway config with `local.conf` include

One sway config for all machines. Machine-specific values come from `~/.config/sway/local.conf` (not in git).

### Top of sway config:

```
include ~/.config/sway/local.conf
exec test -f ~/.config/sway/local.conf || notify-send -u critical "sway" "Missing ~/.config/sway/local.conf — copy from local.conf.example in dotfiles/sway/"
```

If `local.conf` is missing, sway still loads (variables are empty — things look broken but don't crash) and a notification tells you what to do.

### `sway/.config/sway/local.conf.example` (in git, stowed as reference):

```
# Copy this to ~/.config/sway/local.conf and fill in your values.
# This file is NOT managed by stow — it stays machine-local.

# Wallpapers
set $bg_left ~/pictures/backgrounds/your_wallpaper.jpg
set $bg_right ~/pictures/backgrounds/your_wallpaper.jpg
set $bg_laptop ~/pictures/backgrounds/your_wallpaper.jpg

# Monitor names (run: swaymsg -t get_outputs)
set $left_monitor DP-4
set $right_monitor DP-3
set $laptop_monitor eDP-1

# Startup workspace
set $startup_workspace 1

# Workspace-to-monitor mapping (uncomment and adjust for your setup):
# workspace 1 output $laptop_monitor
# workspace 2 output $left_monitor $laptop_monitor
# workspace 3 output $left_monitor $laptop_monitor
# workspace 4 output $left_monitor $laptop_monitor
# workspace 5 output $left_monitor $laptop_monitor
# workspace 6 output $right_monitor $laptop_monitor
# workspace 7 output $right_monitor $laptop_monitor
# workspace 8 output $right_monitor $laptop_monitor
# workspace 9 output $right_monitor $laptop_monitor
# workspace 10 output $right_monitor $laptop_monitor

# Machine-specific window rules:
# for_window [class="hmi_qt"] floating enable
# for_window [app_id="hmi_qt"] floating enable

# Machine-specific keybindings:
# bindsym $mod+u exec grim -g "3969,669 802x483" ~/screenshots/ui-capture-$(date +"%Y-%m-%d_%H-%M-%S").png
```

### Unified sway config adopts from all branches:

- **Audio:** `@DEFAULT_SINK@` (from PC/work-2, replaces deprecated `pacmd`)
- **Brightness:** `brightnessctl set +5%` / `brightnessctl set -5%`
- **Cursor theme:** `seat * xcursor_theme capitaine-cursors 30`
- **GTK theming:** gsettings block for Adwaita-dark + capitaine-cursors
- **Gaming rules:** `$game` macro, discord→ws1, steam→ws5 (harmless if apps absent)
- **sway-audio-idle-inhibit:** `exec sway-audio-idle-inhibit`
- **polkit agent:** `exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1`
- **Mod+p+s suspend:** `bindsym $mod+p+s exec '$lock && systemctl suspend'`
- **dunst:** `exec dunst`
- **udiskie:** `exec_always pkill udiskie; exec udiskie --no-automount --notify --tray`
- **Background via swaybg:** per-monitor images using variables from `local.conf`
- **wofi:** `--allow-images` flag
- **Lock screen:** per-monitor images using variables from `local.conf`

### Idle config (standardized on PC branch values):

```
exec swayidle -w \
    timeout 800 '$lock' \
    timeout 1000 'swaymsg "output * dpms off"' \
    timeout 1800 '$lock && systemctl suspend' \
    resume 'swaymsg "output * dpms on"'
```

### Input devices (all in config — sway ignores absent devices):

- Logitech G Pro: flat accel profile, pointer_accel 0.5
- Logitech MX Vertical: flat accel, pointer_accel 0.5
- Elan TrackPoint: pointer_accel -0.5, scroll_factor 0.5

### Startup:

```
exec --no-startup-id {
    swaymsg "workspace $startup_workspace; exec $term"
}
```

---

## Phase 3: Create unified waybar config

One waybar config for all machines. Use `exec-if` and auto-discovery to handle hardware differences:

- **Battery:** Include `battery` module everywhere — waybar hides it automatically on machines without `/sys/class/power_supply/BAT*`
- **Temperature (CPU):** Use generic `"temperature"` module without `hwmon-path` for auto-discovery
- **Temperature (GPU):** Use `custom/gpu-temp` module with `exec-if` to check if the hwmon path exists. Only shows on PC.
- **sway-audio-idle-inhibit:** Already uses `exec-if "which sway-audio-idle-inhibit"`

### GPU temperature (only renders on machines with the AMD GPU):

```json
"custom/gpu-temp": {
    "exec": "cat /sys/class/hwmon/hwmon0/temp1_input | awk '{printf \"%.0f°C\", $1/1000}'",
    "exec-if": "test -d /sys/devices/pci0000:00/0000:00:03.1/0000:0a:00.0/hwmon",
    "interval": 5,
    "format": "{}  ",
    "tooltip": true
}
```

**Note:** The PC's hwmon path for GPU temperature was specifically chosen because auto-discovery wasn't sufficient. This `exec-if` approach preserves that precision while hiding the module on machines without that hardware.

### Optional machine-specific waybar overrides:

If the unified config isn't sufficient on a particular machine, waybar supports `include` with first-defined-wins. A `machine.json.example` in the waybar stow package documents this:

```json
// ~/.config/waybar/machine.json (optional, not in git)
// Override modules-right or add machine-specific modules here.
// First-defined wins, so values here take priority over the stowed config.
{
    "modules-right": ["custom/gpu-temp", "pulseaudio", "network", "cpu", "memory", "temperature#cpu", "temperature#gpu", "clock", "tray"]
}
```

The common waybar config includes it at the top:

```json
{
    "include": ["~/.config/waybar/machine.json"],
    ...
}
```

If `machine.json` doesn't exist, waybar ignores the include and uses the common config as-is.

---

## Phase 4: Consolidate shikane profiles

Merge all profiles from all three branches into one `shikane/.config/shikane/config.toml`. Profiles self-select based on connected hardware.

### Work laptop 1 profiles (from work-laptop branch):

1. **laptop1-docked-ultrawide** — Samsung C49RG9x (5120x1440@120Hz) + BOE 3840x2160 laptop panel
2. **laptop1-conference** — BOE laptop panel + HDMI conference display (4096x2160@24Hz)
3. **laptop1-standalone** — BOE laptop panel only

These use `search = ["m=...", "s=...", "v=..."]` (vendor/serial matching) — already correct.

### Work laptop 2 profiles (from work-2 branch):

4. **laptop2-standalone** — eDP-1 1920x1080, disable DP and HDMI
5. **laptop2-conference** — eDP-1 + HDMI-A-1 (2560x1440@60Hz)
6. **laptop2-docked-three** — eDP-1 + DP-3 + DP-4 (2560x1440@60Hz each)
7. **laptop2-docked-lid-closed** — DP-3 + DP-4 only (2560x1440@144Hz)

These use port-name matching. Leave as-is; convert to vendor/serial on-device later if needed.

### PC profiles (from PC branch):

8. **desktop-dual** — LG 27GL850 (2560x1440@144Hz) + Dell U2715H (2560x1440@60Hz, portrait)

Uses vendor/serial matching — already correct.

### Delete:

- `shikane/.config/shikane/config_old.toml` (from work-2 branch) — not needed

---

## Phase 5: Update alacritty config

### Font change:

Switch all font families to `JetBrainsMono Nerd Font`.

### Keep from work-laptop branch:

- Shift+Return keybinding (`\u001B\r`)
- Updated config format (`[terminal.shell]`, `[general]`)
- All color scheme, cursor, scrolling settings

### Delete:

- `alacritty/.config/alacritty/alacritty.yml` (old format, deleted on both remote branches)
- `alacritty/.config/alacritty/alacritty.toml.*.bak` (backup files, gitignored)

---

## Phase 6: Update git config

Merge the best settings from all three branches:

```gitconfig
[user]
    name = jmiv-eng
    email = github@jmiv.dev
[core]
    editor = nvim
[init]
    defaultBranch = main
[credential]
    helper = cache --timeout=3600
[color]
    ui = auto
[pull]
    rebase = true
[push]
    default = current
    autoSetupRemote = true
[branch]
    autoSetupMerge = always
```

**Removed:**
- `excludesFile` with hardcoded `/home/jmichael/` path (use `~/.config/git/ignore` which git finds automatically)
- `[url "git@github.com:"]` rewrite (was commented out on PC and work-2; set per-machine if needed)

---

## Phase 7: Update wofi config

Add `term=alacritty` to wofi config.

---

## Phase 8: Add dunst config

Adopt `dunst/.config/dunst/dunstrc` from the PC branch as a new stow package.

---

## Phase 9: Add bin scripts from remote branches

Add to `bin/bin/`:

- `bakkes_plug.sh` — BakkesMod plugin installer
- `borg_backup.sh` — Borg backup script
- `media-notify.sh` — Media notification script

**Do not add:**
- `bin/bin/.repo/` — repo tool metadata, shouldn't be in dotfiles

---

## Phase 10: Consolidate nvim config

**Strategy:** Take work-laptop's nvim config as the definitive base (most recent plugin versions, cleanest state). Surgically add only what's missing from the other branches:

- **Add from PC/work-2:** `texlab` LSP server in lspconfig.lua
- **Already on work-laptop (no action):** vimtex plugin, rust-analyzer settings, harpoon `list():add()` fix, treesitter `C-b`/`C-B` swap keybinds, wrap=true, colorcolumn=120
- **Lazy-lock:** use work-laptop's version (most recent plugin hashes)
- **Remap changes:** verify PC/work-2 remap.lua diff and cherry-pick if meaningful

---

## Phase 11: Clean up old packages

### Delete (consolidated into `shell/`):

- `laptop_wayland/`
- `desktop_wayland/`

### Move to `legacy/` directory (kept for reference):

- `i3/` → `legacy/i3/`
- `i3blocks/` → `legacy/i3blocks/`
- `kanshi/` → `legacy/kanshi/`
- `rofi/` → `legacy/rofi/`
- `desktop_xorg/` → `legacy/desktop_xorg/`

These are no longer active stow packages but stay in the repo under `legacy/` for future reference.

---

## Phase 12: Update README.md

Update the package table to reflect new structure. Replace "Typical Setup" with simple stow-all command. Document the `local.conf` setup step.

---

## Phase 13: Update CLAUDE.md

Rewrite to reflect the new architecture.

---

## Phase 14: Update .gitignore

```
tags
nvim/.config/nvim/plugged/
nvim_old/
*.bak
bin/bin/hammer
bin/bin/host_terminal
bin/bin/.repo/
.claude/
```

---

## File operations summary

### New files:
- `shell/.zprofile`
- `shell/.zshrc`
- `shell/.p10k.zsh`
- `shell/.bashrc`
- `shell/.bash_profile`
- `shell/.local/bin/sway-launch.sh`
- `sway/.config/sway/local.conf.example`
- `waybar/.config/waybar/machine.json.example` (optional override reference)
- `dunst/.config/dunst/dunstrc` (from PC branch)
- `bin/bin/bakkes_plug.sh` (from PC/work-2 branches)
- `bin/bin/borg_backup.sh` (from PC/work-2 branches)
- `bin/bin/media-notify.sh` (from PC branch)

### Modified files:
- `sway/.config/sway/config` — unified from all 3 branches, includes `local.conf`, startup check
- `shikane/.config/shikane/config.toml` — all machines' profiles consolidated
- `alacritty/.config/alacritty/alacritty.toml` — JetBrainsMono Nerd Font, modern config format
- `waybar/.config/waybar/config` — unified with `exec-if` for hardware-conditional modules
- `wofi/.config/wofi/config` — add `term=alacritty`
- `git/.gitconfig` — unified settings from all branches
- `nvim/.config/nvim/` — merged plugin/LSP changes from all branches
- `README.md` — reflect new structure
- `CLAUDE.md` — reflect new architecture
- `.gitignore` — clean up

### Deleted:
- `laptop_wayland/` (consolidated into `shell/`)
- `desktop_wayland/` (consolidated into `shell/`)
- `alacritty/.config/alacritty/alacritty.yml` (old format)
- `shikane/.config/shikane/config_old.toml` (from work-2, not needed)

### Moved to `legacy/`:
- `i3/` → `legacy/i3/`
- `i3blocks/` → `legacy/i3blocks/`
- `kanshi/` → `legacy/kanshi/`
- `rofi/` → `legacy/rofi/`
- `desktop_xorg/` → `legacy/desktop_xorg/`

---

## Machine-local files (NOT in git, created once per machine):

```
~/.config/sway/local.conf         # copy from local.conf.example, fill in wallpapers/monitors/workspaces
~/.config/waybar/machine.json     # optional, only if waybar defaults need overriding
```

---

## Setting up a new machine:

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
stow shell nvim git alacritty sway shikane waybar wofi swaylock dunst bin ranger
cp ~/.config/sway/local.conf.example ~/.config/sway/local.conf
# Edit local.conf with your wallpapers, monitor names, workspace mapping
```

That's it. Three commands.

---

## Verification steps:

1. On current machine (work laptop 1): stow all, create `local.conf`, verify sway launches with nvidia flags
2. Verify shikane activates correct profile
3. Verify all keybindings, audio, brightness, screenshots work
4. Verify waybar shows battery (laptop) and hides GPU temp (no AMD GPU)
5. Open new terminal — verify zsh loads with all plugins, SSH agent detection works
6. On PC: clone, stow all, create `local.conf`, verify sway launches without nvidia flags
7. Verify waybar shows GPU temp and hides battery
8. On all machines: `git pull && stow -R shell sway waybar` picks up any changes

---

## Git strategy:

1. All work done on `work-laptop` branch
2. When complete and verified on this machine, merge `work-laptop` → `main`
3. On other machines: `git checkout main && git pull`, stow all, create `local.conf`
4. Delete `origin/pc` and `origin/work-2` branches after verifying on those machines
5. Going forward: all machines track `main`, no machine-specific branches

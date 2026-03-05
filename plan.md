# Dotfiles Consolidation — Implementation Plan

## Goal

Collapse machine-specific packages (`laptop_wayland/`, `desktop_wayland/`, `desktop_xorg/`) into a single `shell/` package. Make sway and shikane configs machine-aware via native `include` and additive profiles. Remove legacy X11 packages. Add `setup.sh` for bootstrapping new machines.

All work happens on the `work-laptop` branch, then merges to `main`.

---

## Phase 1: Create the unified `shell/` package

Create `shell/` with four files, merging the best of `laptop_wayland/` and `desktop_wayland/`:

### `shell/.zprofile`

```zsh
# Default programs
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"
export READER="evince"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lav --ignore=.. --color=auto'
alias l='ls -lav --ignore=.?* --color=auto'
alias vim="nvim"
alias vi="nvim"
alias rm="echo 'This is not the command you are looking for'; false"
alias cl="clear"

# Machine-specific config
[ -f ~/.config/dotfiles/machine.env ] && source ~/.config/dotfiles/machine.env

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

    case "$DOTFILES_GPU" in
        nvidia)
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

Based on the laptop version (cleaned up, full plugin set). Changes from current:
- Use `$HOME/bin` not hardcoded username
- Include `$HOME/.cargo/bin` in PATH
- Keep the full plugin list (archlinux, gitfast, colored-man-pages, etc.)
- Source `~/.zprofile` and oh-my-zsh
- Source cargo env
- Source `~/.zshrc.local` if it exists (escape hatch for one-off machine config)

### `shell/.bashrc`

Merge of both versions. Changes:
- Use `$HOME/bin` instead of hardcoded `/home/jmichael/bin` or `/home/jmiv/bin`
- Keep bash prompt settings
- Keep cargo env sourcing
- Source `~/.bashrc.local` if it exists (escape hatch)

### `shell/.bash_profile`

Same structure as `.zprofile` but for bash login shells. Sources `machine.env`, has the same GPU `case` block, sources `.vutility_secure`.

---

## Phase 2: Update sway config to use `include`

Modify `sway/.config/sway/config` to extract machine-specific values into an included file.

### Add to top of sway config:

```
include ~/.config/sway/machine.conf
```

### Replace hardcoded values with variables:

| Current hardcoded value | Variable |
|---|---|
| `~/pictures/backgrounds/james_webb_cosmic_cliffs.jpg` | `$bg_left` (already a variable, just needs to move to machine.conf) |
| `~/pictures/backgrounds/james_webb_cosmic_cliffs_ultrawide.jpg` | `$bg_right` (same) |
| `swaymsg "workspace 1; exec $term"` | `swaymsg "workspace $startup_workspace; exec $term"` |
| `timeout 600 '$lock'` | `timeout $idle_lock_timeout '$lock'` |

### Remove from sway config, add to machine.conf:

The `set $bg_left`, `set $bg_right` lines move out of the config and into `~/.config/sway/machine.conf`.

### Add optional workspace include at bottom:

```
include ~/.config/sway/workspaces.conf
```

This file only exists on multi-monitor desktops (like the PC) and maps workspaces to monitors. On single-display machines or laptops, the file doesn't exist and sway silently skips it.

### Fix audio commands:

Replace deprecated `pacmd list-sinks` approach with `@DEFAULT_SINK@`:

```
bindsym --locked XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym --locked XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym --locked XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
```

### Keep in sway config (common to all machines):

- All keybindings, gaps, borders, layout
- All input device blocks (sway ignores blocks for devices not connected)
- shikane exec, udiskie exec, dunst exec
- waybar, swaylock config
- Screenshot bindings

---

## Phase 3: Consolidate shikane profiles

Merge profiles from both branches into one `shikane/.config/shikane/config.toml`.

### Convert PC profiles to `search` matching:

The PC branch uses `match = "DP-1"` (port names). Convert to vendor/serial matching to be hardware-aware and port-independent:

```toml
# PC: LG 27GL850 (primary, 144Hz)
[[profile.output]]
search = ["m=27GL850", "v=Goldstar Company Ltd"]

# PC: Dell U2715H (portrait)
[[profile.output]]
search = ["m=DELL U2715H", "v=Dell Inc."]
```

**Note:** The exact `search` values will need to be verified on the PC. The monitor serial numbers and vendor strings must match what shikane sees. The user should run `swaymsg -t get_outputs` on the PC to get the exact strings. We'll add placeholder values and note that they need verification.

### Final shikane config will contain profiles for:

1. `laptop-docked-ultrawide` — Samsung C49RG9x + BOE laptop panel
2. `laptop-conference` — BOE laptop panel + HDMI conference display
3. `laptop-standalone` — BOE laptop panel only
4. `desktop-dual` — LG 27GL850 + Dell U2715H (needs verification on PC)
5. `desktop-single` — fallback (needs to be defined on PC)

Each profile matches by vendor/model/serial, so only the profiles for connected hardware activate.

---

## Phase 4: Update wofi config

Adopt the `term=alacritty` addition from the PC branch:

```
term=alacritty
```

And add `--allow-images` to the sway `$menu` variable (also from PC branch, harmless everywhere).

---

## Phase 5: Create `setup.sh`

Interactive script that:

1. Prompts for GPU type (`nvidia` / `amd` / `intel`)
2. Writes `~/.config/dotfiles/machine.env`
3. Prompts for wallpaper paths, startup workspace, idle timeout
4. Writes `~/.config/sway/machine.conf`
5. Optionally prompts for multi-monitor workspace mapping → writes `~/.config/sway/workspaces.conf`
6. Runs `stow` for all common packages
7. Prints summary of what was done

Provides sensible defaults so you can just hit enter for most prompts.

---

## Phase 6: Clean up old packages

### Delete (consolidated into `shell/`):

- `laptop_wayland/`
- `desktop_wayland/`

### Move to `legacy/` directory (kept for reference):

- `i3/` → `legacy/i3/`
- `i3blocks/` → `legacy/i3blocks/`
- `kanshi/` → `legacy/kanshi/`
- `rofi/` → `legacy/rofi/`
- `desktop_xorg/` → `legacy/desktop_xorg/`

These are no longer active stow packages but stay in the repo under `legacy/` for future reference. The `legacy/` directory is not stowed — it's just an archive.

---

## Phase 7: Update README.md

Update the package table to reflect new structure. Update the "Typical Setup" section to reference `setup.sh` instead of manual stow commands. Remove references to deleted packages.

---

## Phase 8: Update CLAUDE.md

Rewrite to reflect the new architecture: `shell/` + `machine.env`, sway `include`, consolidated shikane, `work/` package pattern.

---

## Phase 9: Update .gitignore

Add any new entries if needed. Verify `kanshi/` directory removal means the gitignore entry can be removed too.

---

## File operations summary

### New files:
- `shell/.zprofile`
- `shell/.zshrc`
- `shell/.bashrc`
- `shell/.bash_profile`
- `setup.sh`

### Modified files:
- `sway/.config/sway/config` — add `include`, extract variables, fix audio
- `shikane/.config/shikane/config.toml` — add PC profiles
- `wofi/.config/wofi/config` — add `term=alacritty`
- `README.md` — reflect new structure
- `CLAUDE.md` — reflect new architecture
- `.gitignore` — clean up

### Deleted (consolidated):
- `laptop_wayland/`
- `desktop_wayland/`

### Moved to `legacy/`:
- `i3/` → `legacy/i3/`
- `i3blocks/` → `legacy/i3blocks/`
- `kanshi/` → `legacy/kanshi/`
- `rofi/` → `legacy/rofi/`
- `desktop_xorg/` → `legacy/desktop_xorg/`

---

## Machine-local files created by `setup.sh` (NOT in git):

```
~/.config/dotfiles/machine.env        # GPU type + work/home context
~/.config/sway/machine.conf           # wallpapers, idle timeouts, startup workspace
~/.config/sway/workspaces.conf        # workspace-to-monitor mapping (multi-monitor only)
```

---

## Verification steps after implementation:

1. On current machine (work laptop): run `setup.sh`, verify sway launches correctly with nvidia flags
2. Verify shikane activates correct profile (laptop-standalone or laptop-docked-ultrawide)
3. Verify all keybindings, audio, brightness controls work
4. Open new terminal — verify zsh loads correctly with all plugins
5. On PC (when available): clone, run `setup.sh`, verify sway launches without nvidia flags
6. Verify shikane activates desktop profile with correct monitors
7. On both machines: `git pull` should bring all changes with zero conflicts

---

## Git strategy:

1. All work done on `work-laptop` branch
2. When complete and verified, merge `work-laptop` → `main`
3. On PC: `git checkout main && git pull` then run `setup.sh`
4. Delete `origin/pc` branch after verifying PC setup works
5. Going forward: all machines track `main`, no machine-specific branches

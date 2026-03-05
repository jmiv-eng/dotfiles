# dotfiles — Context for AI Assistance

## Repository Purpose

This is a personal dotfiles repository managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package — running `stow -St ~ <package>` symlinks its contents into `$HOME`, making the repo the source of truth for system configuration.

## Owner

- Username: `jmichael` (primary), `jmiv` (older alias, appears in some configs)
- Shell: zsh (Powerlevel10k + oh-my-zsh), bash as fallback
- Editor: Neovim (lazy.nvim plugin manager)
- WM: Sway (Wayland)
- Terminal: Alacritty
- Display management: Shikane (profile-based, matches monitors by vendor/serial)

## Machines

The owner operates across four machines, each with different hardware:

| Machine | GPU | Notes |
|---|---|---|
| Work laptop 1 | Nvidia | Primary development machine, current branch |
| Work laptop 2 | Nvidia | Secondary work machine |
| Home laptop | Intel integrated | Personal portable |
| Home PC | AMD | Personal desktop |

All machines run Arch Linux + Sway (Wayland).

## Current Package Structure

```
alacritty/         terminal emulator config
bin/               custom scripts (bash/shell utilities, embedded debug tools)
desktop_wayland/   shell environment for AMD desktop (.zshrc, .zprofile)
desktop_xorg/      legacy X11 shell environment (mostly commented out, deprecated)
git/               git config
i3/                i3 window manager (legacy, unused)
i3blocks/          i3 status bar (legacy, unused)
kanshi/            legacy display config (superseded by shikane, gitignored)
laptop_wayland/    shell environment for Nvidia laptops (.bash_profile, .bashrc, .zprofile, .zshrc)
nvim/              Neovim config (lazy.nvim, LSP, Treesitter, Telescope, vimtex)
nvim_old/          archived legacy Neovim config (not tracked)
ranger/            file manager config
rofi/              X11 app launcher
shikane/           display profile management (TOML, matches monitors by vendor/serial/model)
sway/              Sway window manager config (unified, references shikane for displays)
swaylock/          screen lock config
waybar/            Wayland status bar
wofi/              Wayland app launcher
```

## The Core Problem

The repo was originally structured for a single machine and has grown organically to support multiple machines without a clear multi-machine strategy. The following issues exist:

### 1. Machine-specific packages are monolithic

`laptop_wayland/` and `desktop_wayland/` each contain full copies of `.zshrc`, `.zprofile`, `.bashrc`, and `.bash_profile`. These files are ~70–80% identical. The differences are:

- **GPU environment variables**: Nvidia machines need `GBM_BACKEND=nvidia-drm`, `WLR_NO_HARDWARE_CURSORS=1`, and `exec sway --unsupported-gpu`. AMD/Intel machines do not.
- **Sway launch flags**: `--unsupported-gpu` is Nvidia-only.
- **Shell plugins**: `laptop_wayland/.zshrc` loads 7 oh-my-zsh plugins; `desktop_wayland/.zshrc` loads only `git`.
- **SSH keychain**: `desktop_wayland` includes keychain setup for `id_ed25519` and `google_compute_engine`; `laptop_wayland` does not.
- **PATH hardcoding**: `laptop_wayland` uses `/home/jmichael/bin`; `desktop_wayland` uses `/home/jmiv/bin` (old username).

There are no packages yet for the Intel home laptop or the second work laptop — those machines would need new packages or would reuse existing ones despite potential mismatches.

### 2. GNU Stow cannot merge files

Stow works at the file level: a given file (e.g. `.zshrc`) can only be symlinked from one package at a time. There is no built-in mechanism to layer or compose files from multiple packages. This means any shared content must either be duplicated across packages or sourced from a separate file — neither of which is currently implemented.

### 3. No installation automation

There is no script to define which packages belong on which machine. Setting up a new machine requires knowing manually which packages to stow. This is currently documented only in the README in general terms.

### 4. Divergence is accelerating

The `work-laptop` branch (current) contains changes that are specific to one Nvidia work laptop — shikane profiles tuned to specific monitor serials, sway brightness controls, jdebug embedded tooling. As work machines accumulate work-specific tools and personal machines accumulate personal config, the shared packages (`nvim`, `sway`, `alacritty`) may also begin to diverge.

### 5. Branch strategy is undefined

There is a `main` branch, a `work-laptop` branch (in progress), and a remote `origin/pc` branch whose contents and purpose are unclear. There is no established convention for how machine-specific changes flow between branches or how shared changes (e.g. nvim plugin updates) get propagated to all machines.

### 6. Secrets handling

`laptop_wayland/.zprofile` and `.zshrc` source `~/.vutility_secure`, a file containing credentials that is intentionally not in the repo. This pattern works but is informal — there is no documented convention for what belongs in that file or how to bootstrap it on a new machine.

## What Is Already Working Well

- **Neovim, Alacritty, Waybar, Wofi, Swaylock, Ranger, Git** configs are fully unified — one package, no machine-specific variants needed.
- **Sway** config is unified and delegates display layout to Shikane profiles, which handle hardware differences at the display-manager level rather than in the WM config.
- **Shikane** profiles match monitors by vendor/serial/model string, so the same config file works across machines that may have different output port names.
- The repo is already using Stow correctly and the symlinking workflow is established.

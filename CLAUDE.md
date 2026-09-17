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
| ace | Intel | Home laptop |
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

## System prerequisites

Packages that must be installed for a stowed config to work (all in the official Arch repos):

| Package | Needed by | Symptom if missing |
|---|---|---|
| `tree-sitter-cli` | `nvim` | Parsers fail to compile. Neovim falls back to the stale system parsers from Arch's `tree-sitter-*` packages under `/usr/lib/tree_sitter/`, which mismatch Neovim's bundled queries and throw errors like `Query error: Invalid field name "operator"` on every buffer. |

### Neovim

- Plugin manager is lazy.nvim. `init.lua` only bootstraps it — every plugin is one file under `lua/plugins/` with its configuration inlined in the spec. There is deliberately no `lua/config/` directory; keeping a plugin's spec and its setup in separate files is what let them drift out of sync.
- nvim-treesitter tracks the **`main`** branch. Upstream froze `master` for backward compatibility only (one commit in the last year, vs ~276 on `main`), and `main` is now the GitHub default. The two have incompatible APIs: `main` has no `ensure_installed` setup option, no `highlight`/`indent`/`incremental_selection` modules, and does not take textobject keymaps in `setup`.
- Because `main` dropped `incremental_selection`, the `<c-space>` / `<c-s>` / `<M-space>` bindings are reimplemented directly on `vim.treesitter` in `lua/plugins/treesitter.lua`.
- Parsers install to `~/.local/share/nvim/site/`. Passing `install_dir` to `require('nvim-treesitter').setup{}` is what prepends that directory to the runtimepath, which is how locally built parsers win over the system ones.
- `lazy-lock.json` is committed and pins exact plugin commits — that is the cross-machine reproducibility mechanism. nvim-treesitter publishes no release tags on `main`, so there is no version to pin instead.

## Key Conventions

- Stow target is `$HOME` (run `stow <pkg>` from `~/dotfiles`)
- `stow --adopt` to pull existing files into the repo
- Audio uses `@DEFAULT_SINK@` (not deprecated `pacmd`)
- Cursor theme: capitaine-cursors
- GTK theme: Adwaita-dark
- Sway silently ignores missing `include` files
- Shikane profiles use vendor/serial matching where possible, port-name matching as fallback

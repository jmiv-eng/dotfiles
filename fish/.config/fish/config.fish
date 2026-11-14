# ~/.config/fish/config.fish -- mirrors ~/.zprofile and ~/.zshrc. Optional tools
# (eza, bat, fastfetch, expac) are guarded with `type -q`.
#
#   functions/         prompt + helpers (autoloaded)
#   themes/jmiv.theme  colours
#   conf.d/done.fish   notify when a long command finishes (vendored, MIT)
#   local.fish         machine-local overrides (gitignored)
#
# Settings use global scope (-g); universal variables would be per-machine state.

## Environment ---------------------------------------------------------------
# Interactive and login shells only. `fish -c` children (nvim's :!, ranger,
# scripts) inherit all of this from their parent, so they skip the work.
if status is-interactive; or status is-login
    # Same defaults as ~/.zprofile, only set when missing
    for pair in EDITOR=nvim TERMINAL=alacritty BROWSER=firefox READER=evince \
            LANG=en_US.UTF-8 QT_QPA_PLATFORMTHEME=qt5ct
        set -l kv (string split -m1 = $pair)
        set -q $kv[1]; or set -gx $kv[1] $kv[2]
    end

    # Work secrets (sh syntax): let sh evaluate them, then import every
    # variable the file adds or changes (inherited ones already match)
    if test -f ~/.vutility_secure
        sh -c '. ~/.vutility_secure >/dev/null 2>&1; env -0' | while read -lz entry
            set -l kv (string split -m1 = -- $entry)
            string match -qr '^[A-Za-z][A-Za-z0-9_]*$' -- $kv[1]; or continue
            contains -- $kv[1] PWD OLDPWD SHLVL; and continue
            test "$(string join : -- $$kv[1])" = "$kv[2]"; and continue
            set -gx $kv[1] $kv[2]
        end
    end

    # PATH, ~/bin first (missing dirs are skipped)
    fish_add_path -g ~/bin ~/.local/bin ~/.cargo/bin

    # SSH agent: gcr-ssh-agent (socket-activated by systemd). Not over SSH,
    # where SSH_AUTH_SOCK may be a forwarded agent.
    if not set -q SSH_CONNECTION; and test -S $XDG_RUNTIME_DIR/gcr/ssh
        set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/gcr/ssh
    end
end

## Interactive ---------------------------------------------------------------
if status is-interactive
    # fish built-ins covering .zshrc's oh-my-zsh plugins: Alt+S (sudo),
    # Alt+Left/Right (dirhistory), pkgfile lookup (command-not-found), git completions

    # Colours (sets them as globals for this session)
    fish_config theme choose jmiv

    function fish_greeting
        type -q fastfetch; and fastfetch
    end

    # Man pages through bat
    if type -q bat
        set -gx MANROFFOPT -c
        set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    end

    # done.fish: only for commands >= 10s, low urgency
    set -g __done_min_cmd_duration 10000
    set -g __done_notification_urgency_level low

    # Finished prompts collapse to `❯`
    set -g fish_transient_prompt 1
    # Ctrl+L: fish's own clear-screen, minus the prompt's leading blank line
    bind ctrl-l 'set -g __jmiv_prompt_spaced 0' \
        'status test-terminal-feature scroll-content-up && commandline -f scrollback-push' \
        clear-screen
    set -gx VIRTUAL_ENV_DISABLE_PROMPT 1 # the prompt shows the venv itself
    # The pure prompt package, if installed, adds blank lines of its own
    functions -q _pure_prompt_new_line; and functions -e _pure_prompt_new_line

    ## Aliases (same as .zshrc / oh-my-zsh)
    alias vim nvim
    alias vi nvim
    alias cl clear
    alias md 'mkdir -p'
    alias grep 'grep --color=auto'
    function ll --wraps ls --description 'ls -lav without ..'
        command ls -lav --ignore=.. --color=auto $argv
    end
    function l --wraps ls --description 'ls -lav without dotfiles'
        command ls -lav '--ignore=.?*' --color=auto $argv
    end
    function la --wraps ls --description 'ls -lAh (oh-my-zsh)'
        command ls -lAh --color=auto $argv
    end

    # eza extras, under names zsh doesn't already use
    if type -q eza
        alias lt 'eza -aT --color=always --group-directories-first --icons=always'
        alias l. 'eza -a | grep -e "^\."'
    end

    ## Abbreviations (expand in place)
    abbr -a ... 'cd ../..'
    abbr -a .... 'cd ../../..'
    abbr -a ..... 'cd ../../../..'
    abbr -a fixpacman 'sudo rm /var/lib/pacman/db.lck'
    abbr -a cleanup 'sudo pacman -Rns (pacman -Qtdq)'
    abbr -a jctl 'journalctl -p 3 -xb'
    abbr -a psmem 'ps auxf | sort -nr -k 4 | head -20'
    abbr -a tarnow 'tar -acf'
    abbr -a untar 'tar -xvf'
    if type -q expac
        abbr -a big "expac -H M '%m\t%n' | sort -h | nl"
        abbr -a rip "expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
    end
    type -q cachyos-rate-mirrors; and abbr -a mirror 'sudo cachyos-rate-mirrors'

    # !! and !$ as in bash/zsh
    function __jmiv_last_command
        echo $history[1]
    end
    function __jmiv_last_argument
        echo $history[1] | read --local --list --tokenize args
        set -q args[1]; and string escape -- $args[-1]
    end
    abbr -a !! --position anywhere --function __jmiv_last_command
    abbr -a '!$' --position anywhere --function __jmiv_last_argument

    # Plain `history` shows timestamps (wraps fish's own function, keeping its pager)
    if functions -q history; and not functions -q __jmiv_stock_history
        functions -c history __jmiv_stock_history
        function history --wraps __jmiv_stock_history
            if set -q argv[1]
                __jmiv_stock_history $argv
            else
                __jmiv_stock_history --show-time='%F %T '
            end
        end
    end
end

## Machine-local overrides (not in git) ---------------------------------------
test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish

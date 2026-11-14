# Two-line prompt:
#
#   ▌ ~/dotfiles │  main !8?2 ▶·············◀ ✘ 1 │ 4s  │  │ 12:34:56  ▐
#   ❯
#
# Left: os icon, directory, git. Right: exit status, duration (>= 3s), jobs,
# venv, user@host (ssh/root only), clock. Colours come from the theme's
# fish_color_* variables, each with a named-colour fallback.

# fish_git_prompt: branch plus state markers (colours are set below, once)
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_showstashstate 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_char_stateseparator ' '
set -g __fish_git_prompt_char_cleanstate ''
set -g __fish_git_prompt_char_stagedstate '+'
set -g __fish_git_prompt_char_dirtystate '!'
set -g __fish_git_prompt_char_untrackedfiles '?'
set -g __fish_git_prompt_char_stashstate '≡'
set -g __fish_git_prompt_char_conflictedstate '~'
set -g __fish_git_prompt_char_upstream_ahead '⇡'
set -g __fish_git_prompt_char_upstream_behind '⇣'

# Prints the theme variable's value, or the fallback if the theme lacks it
function _jmiv_color --argument-names var fallback
    if set -q $var[1]; and test -n "$$var[1]"
        string join \n -- $$var
    else
        echo $fallback
    end
end

# Git colours, set once when this file loads (after config.fish chose the
# theme). Setting them fires fish_git_prompt's handlers, which drop its cache.
set -g __fish_git_prompt_color_branch (_jmiv_color fish_color_prompt_git_branch green)
set -g __fish_git_prompt_color_upstream $__fish_git_prompt_color_branch
set -g __fish_git_prompt_color_stashstate $__fish_git_prompt_color_branch
set -g __fish_git_prompt_color_stagedstate (_jmiv_color fish_color_prompt_git_changes yellow)
set -g __fish_git_prompt_color_dirtystate $__fish_git_prompt_color_stagedstate
set -g __fish_git_prompt_color_untrackedfiles (_jmiv_color fish_color_prompt_git_untracked blue)
set -g __fish_git_prompt_color_invalidstate (_jmiv_color fish_color_status red)

# Blank line above each new prompt except the first. Decided on the fish_prompt
# event, which fires once per new prompt; repaints (resize, Ctrl+L) only re-run
# fish_prompt, so they redraw the same prompt instead of adding a line.
function _jmiv_prompt_new --on-event fish_prompt
    if set -q __jmiv_prompt_drawn
        set -g __jmiv_prompt_spaced 1
    else
        set -g __jmiv_prompt_spaced 0
    end
end

# After `clear`, the next prompt starts at the top with no blank line
function _jmiv_prompt_cleared --on-event fish_postexec
    string match -qr '^\s*(clear|cl)\s*$' -- $argv[1]; and set -e __jmiv_prompt_drawn
end

function fish_prompt --description 'Two-line segmented prompt'
    # Capture before any command overwrites them
    set -l last_status $status
    set -l last_duration $CMD_DURATION

    # Transient rendering (what stays in scrollback)
    if contains -- --final-rendering $argv
        test "$__jmiv_prompt_spaced" = 1; and echo
        _jmiv_prompt_char $last_status
        return
    end

    # Spacing is decided by _jmiv_prompt_new (unset before its first event)
    test "$__jmiv_prompt_spaced" = 1; and echo
    set -g __jmiv_prompt_drawn

    set -l c_bar (_jmiv_color fish_color_prompt_bar 242424)
    set -l c_icon (_jmiv_color fish_color_prompt_icon cyan)
    set -l c_mute (_jmiv_color fish_color_prompt_mute brblack)
    set -l c_info (_jmiv_color fish_color_prompt_info cyan)
    set -l c_dur (_jmiv_color fish_color_prompt_duration yellow)
    set -l c_err (_jmiv_color fish_color_status red)
    set -l c_branch $__fish_git_prompt_color_branch

    set -l normal (set_color normal)
    set -l sep (set_color $c_mute)' │ '

    ## Left: os icon │ directory │ git
    set -l left (set_color $c_icon) (_jmiv_prompt_dir)
    set -l git (fish_git_prompt (set_color $c_branch)' %s')
    set -q git[1]; and set -a left (string trim -- $git)

    ## Right: status │ duration │ jobs │ venv │ user@host │ time
    set -l right
    test $last_status -ne 0; and set -a right (set_color $c_err)"✘ $last_status"
    test $last_duration -ge 3000; and set -a right (set_color $c_dur)(_jmiv_format_duration $last_duration)' '
    jobs -q; and set -a right (set_color $c_info)
    set -q VIRTUAL_ENV; and set -a right (set_color $c_mute)(path basename -- $VIRTUAL_ENV)' '
    if set -q SSH_TTY; or fish_is_root_user
        set -a right (set_color (_jmiv_color fish_color_user brblack))$USER@(prompt_hostname)
    end
    set -a right (set_color $c_mute)(date +%H:%M:%S)' '

    # `set_color normal` inside a segment also clears the background; re-apply it
    set -l on_bar (set_color -b $c_bar)
    set -l left_in (string join -- $sep $left | string replace -a -- $normal $normal$on_bar)
    set -l right_in (string join -- $sep $right | string replace -a -- $normal $normal$on_bar)

    set -l left_str $on_bar' '$left_in' '$normal(set_color $c_bar)$normal
    set -l right_str (set_color $c_bar)$on_bar' '$right_in' '$normal

    # Dotted gap to right-align; drop the right side if it doesn't fit
    set -l gap (math $COLUMNS - (string length --visible -- $left_str) - (string length --visible -- $right_str) - 1)
    if test $gap -ge 1
        echo -s $left_str ' ' (set_color $c_mute)(string repeat -n (math $gap - 1) ·) $right_str
    else
        echo -s $left_str
    end

    _jmiv_prompt_char $last_status
end

# ❯ after success / failure
function _jmiv_prompt_char --argument-names last_status
    if test "$last_status" = 0
        set_color (_jmiv_color fish_color_prompt_char magenta)
    else
        set_color (_jmiv_color fish_color_status red)
    end
    echo -n '❯ '
    set_color normal
end

# Directory, last component bold; long paths shorten parents to one letter
function _jmiv_prompt_dir
    set -l c (_jmiv_color fish_color_cwd blue)
    set -l dir (prompt_pwd --dir-length 0)
    if test (string length -- $dir) -gt (math "floor($COLUMNS / 2)")
        set dir (prompt_pwd --dir-length 1 --full-length-dirs 2)
    end
    set -l parts (string split -r -m1 / -- $dir)
    if test (count $parts) -eq 2; and test -n "$parts[2]"
        echo -n -s (set_color $c) $parts[1] / (set_color --bold $c) $parts[2] (set_color normal)
    else
        echo -n -s (set_color --bold $c) $dir (set_color normal)
    end
end

# 4s, 1m 5s, 2h 3m 4s, 1d 2h 3m 4s
function _jmiv_format_duration --argument-names ms
    set -l s (math "floor($ms / 1000)")
    set -l out
    for unit in d:86400 h:3600 m:60
        set -l u (string split : -- $unit)
        if test $s -ge $u[2]
            set -a out (math "floor($s / $u[2])")$u[1]
            set s (math "$s % $u[2]")
        end
    end
    set -a out {$s}s
    string join ' ' -- $out
end

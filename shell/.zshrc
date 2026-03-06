# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path
export PATH=$HOME/bin:/usr/local/bin:$HOME/.cargo/bin:$PATH

# oh-my-zsh
ZSH=/usr/share/oh-my-zsh/

# Powerlevel10k theme location varies depending on how it was installed:
#   - User oh-my-zsh install (curl installer): ~/.oh-my-zsh/custom/themes/powerlevel10k/
#   - System oh-my-zsh (e.g. oh-my-zsh-git AUR) with theme cloned manually: /usr/share/oh-my-zsh/custom/themes/powerlevel10k/
#   - Arch package zsh-theme-powerlevel10k: /usr/share/zsh-theme-powerlevel10k/
# We bypass oh-my-zsh's theme loading and source it directly to handle all cases.
ZSH_THEME=""
_p10k_theme=""
for _p10k_candidate in \
  "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" \
  "/usr/share/oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" \
  "/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme"; do
  if [[ -f "$_p10k_candidate" ]]; then
    _p10k_theme="$_p10k_candidate"
    break
  fi
done
unset _p10k_candidate

plugins=(archlinux
    gitfast
    colored-man-pages
    colorize
    command-not-found
    cp
    dirhistory
    sudo
)

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lav --ignore=.. --color=auto'
alias l='ls -lav --ignore=.?* --color=auto'
alias vim="nvim"
alias vi="nvim"
alias rm="echo 'This is not the command you are looking for'; false"
alias cl="clear"

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $HOME/.zprofile
[[ -f /usr/share/oh-my-zsh/oh-my-zsh.sh ]] && source /usr/share/oh-my-zsh/oh-my-zsh.sh
[[ -n "$_p10k_theme" ]] && source "$_p10k_theme"
unset _p10k_theme

# Cargo
[[ -f ~/.cargo/env ]] && source ~/.cargo/env

# SSH agent detection
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  sock=$(find /tmp -maxdepth 2 -path '/tmp/ssh-*' -type s -user "$USER" -name 'agent.*' 2>/dev/null | xargs ls -t 2>/dev/null | head -n1)
  if [[ -n "$sock" ]]; then
    export SSH_AUTH_SOCK="$sock"
  else
    eval "$(ssh-agent -s)" > /dev/null
  fi
fi

# Local overrides
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

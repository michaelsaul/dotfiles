# Source Powerlevel10k
#source $HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme

# Ruby path
export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/lib/ruby/gems/3.3.0/bin:$PATH"
export PATH="$HOME/.gem/ruby/3.3.0/bin:$PATH"

# Path to your dotfiles.
export DOTFILES=$HOME/.dotfiles

# Source aliases
source $HOME/.aliases.zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Load tabcomplete
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  
  autoload -U +X bashcompinit && bashcompinit
  autoload -Uz compinit && compinit
fi

# Terraform autocomplete
complete -o nospace -C $(brew --prefix)/bin/terraform terraform
# Az cli autocomplete
source $(brew --prefix)/etc/bash_completion.d/az

# Docker Architecture
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Functions

# Open man pages in new window
function xmanpage() { open x-man-page://$@ ; }

# Highlight less
export LESSOPEN="| ${HOMEBREW_PREFIX}/bin/src-hilite-lesspipe.sh %s"
export LESS=' -R '

alias k='kubectl'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Disable conda prompt modification
conda config --set changeps1 false

# Initialize starship (must be at the end of the file)
eval "$(starship init zsh)"
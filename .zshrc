# Path to your dotfiles.
export DOTFILES=$HOME/.dotfiles

# Source aliases
source $HOME/.aliases.zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#PATH=$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin
#Added to /etc/paths instead

#Source Powerlevel10k
source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

#Load tabcomplete
autoload -Uz compinit && compinit

# load bashcompinit for some old bash completions
autoload bashcompinit && bashcompinit

#Load homebrew autocompletions
for f in '/usr/local/etc/bash_completion.d/'*; do
  source "$f"
done;

#dotnet autocomplete
_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  reply=( "${(ps:\n:)completions}" )
}

compctl -K _dotnet_zsh_complete dotnet

#Functions

#Open man pages in new window
function xmanpage() { open x-man-page://$@ ; }

startjumpbox () {
  az account set --subscription 658dc4bc-feee-4c24-b7d2-130ba139a4ed
  vmname=jumpbox
  rg=MTest

  vmstate=`az vm show --name ${vmname} --resource-group ${rg} -d --query powerState -o tsv`

  case $vmstate in
  "VM deallocated")
    #Start the VM
    echo "Staring the VM"
    az vm start --name ${vmname} --resource-group ${rg}
    ;;
  "VM stopped")
    #Start the VM
    echo "Staring the VM"
    az vm start --name ${vmname} --resource-group ${rg}
    ;;
  "VM running")
    #Do nothing
    echo "The VM is already running"
    ;;
  "VM starting")
    #Wait for the VM to start
    echo "Waiting for hte VM to start..."
    ;;
  *)
    #Something else"
    echo "The VM is in ${vmstate} state, please try again."
  esac
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


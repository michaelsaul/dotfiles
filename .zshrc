# Path to your dotfiles.
export DOTFILES=$HOME/.dotfiles

# Source aliases
source .aliases.zsh

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

#Functions

#Open man pages in new window
function xmanpage() { open x-man-page://$@ ; }

#Print Time Machine Remaining Percent and Hours
tmtime () {
  if [[ `tmutil status | awk -F'= ' '/Running/ {print substr($2,1,length($2)-1)}'` -eq 1 ]]
  then
    minutes=`tmutil status | awk -F'=' '/TimeRemaining/ {print substr($2, 1, length($2)-1)/60}'`
    percent=`tmutil status | awk -F'"' '/_raw_Percent/ {print $4*100}'`
    
    if [[ minutes -lt 60 ]]
    then
      echo Time Machine Status: $percent"% complete. "$minutes" minutes remaining."
    else
      hours=$(( $minutes / 60 ))
      echo Time Machine Status: $percent"% complete. "$hours" hours remaining."
    fi
  else
    echo "Time Machine isn't running"
  fi
}

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

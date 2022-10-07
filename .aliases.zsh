#Automate kerberos login for work
alias klogin='kdestroy --all;kinit --keychain misaul@NORTHAMERICA.CORP.MICROSOFT.COM'

#Check for brew updates and list outdated
alias buo='brew update && brew outdated'

#Start Local Time Machine Backup
tmlb() {
    destination=`tmutil destinationinfo | egrep 'Local' -A 2 | tail -n 1 | awk -F: '{ gsub(/ /,"");print $2}'`
    #echo $destination
    if [ -z "$destination" ]
    then
      echo No destination found, quitting.
    else
      tmutil startbackup -d $destination
    fi
}

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
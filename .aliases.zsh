#Check for brew updates and list outdated
alias buo='brew update && brew outdated'
alias ki='kubectl -n instabase'
alias kl='kubectl -n installm'
alias release-system="docker pull gcr.io/instabase-build/release-system:latest && docker run --rm gcr.io/instabase-build/release-system:latest"

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

# Clean up extracted zip files
cleanzip () {
  readonly zipfile=${1:?"Zip file must be spedified."}
  unzip -l ${zipfile} | awk 'NR>3 {print $4}' | xargs rm -rf
}


# Login to OC
oclogin() {
  export rg=ms-aro-3
  export os=ms-aro-3

  apiServer=$(az aro show -g $rg -n $os --query "apiserverProfile.url" -o tsv)
  password=$(az aro list-credentials -g $rg -n $os --query "kubeadminPassword" -o tsv)

  oc login -u kubeadmin -p $password -s $apiServer
}

# Copy 

getrelease() {
  local gdrivePath="/Users/michaelsaul/Google Drive/Shared drives/Customer Deployment Packages"
  local localPath="/Users/michaelsaul/Projects/Customer-Deployment-Packages"
  local pattern='[0-9]{2}\.[0-9]{2}\.[0-9]{1,2}(-aihub)?'
  local message="Usage: getrelease release_version. Where release_version = YY.MM.PP. Example: 23.10.8"

  if (( # == 0)); then
      print >&2 $message
      return 1
  fi
  
  if [[ $1 =~ $pattern ]]; then
      local folder=Release-$1
      echo "Copying files from Google Drive"
      mkdir $localPath/$folder
      cp -R $gdrivePath/$folder/* $localPath/$folder
      chmod -R 755 $localPath/$folder
      unzip -q $localPath/$folder/installation.zip -d $localPath/$folder
      unzip -q $localPath/$folder/base_configs.zip -d $localPath/$folder/base_configs
  else
      print >&2 $message
      return 1
  fi 
}

set-regcred() {
  local registry="https://gcr.io"
  local regcredPath="/Users/michaelsaul/Google Drive/My Drive/Documents/Regcred"
  local regcred="regcred.michaelsaul.json"
  local regcredPassword=$(cat $regcredPath/$regcred)

  if [ ! -z $IB_NS ]; then
    echo "Configuring Docker Registsry Secret..."
    kubectl create secret docker-registry regcred \
      -n $IB_NS \
      --docker-server=$registry \
      --docker-username=_json_key \
      --docker-password=$regcredPassword
  else
    echo 'No namespace variable set. Set $IB_NS.'
    return 1
  fi
}


start-openwebui() {
  docker pull ghcr.io/open-webui/open-webui:main > /dev/null 2>&1
  docker run -d -p 3000:8080 \
  --name open-webui \
  -v open-webui:/app/backend/data \
  --add-host=host.docker.internal:host-gateway \
  --restart always \
  ghcr.io/open-webui/open-webui:main
}

# Update the OpenWebUI container
update-openwebui() {
  local verbose=false
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -v|--verbose)
        verbose=true
        shift
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
  done

  echo "Checking for updates to the OpenWebUI image..."
  
  # Get current and latest image IDs
  local current_image_id
  local latest_image_id
  current_image_id=$(docker images -q ghcr.io/open-webui/open-webui:main)
  
  # Pull the latest image without overwriting the existing one
  if [ "$verbose" = true ]; then
    docker pull ghcr.io/open-webui/open-webui:main
  else
    docker pull ghcr.io/open-webui/open-webui:main > /dev/null 2>&1
  fi
  
  if [ $? -ne 0 ]; then
    echo "Failed to pull the latest image. Please check your network connection or image name."
    return 1
  fi
  
  latest_image_id=$(docker images -q ghcr.io/open-webui/open-webui:main)

  if [ "$current_image_id" = "$latest_image_id" ]; then
    echo "OpenWebUI is already up to date."
    return 0
  fi

  echo "A new version of OpenWebUI is available. Updating the container..."
  
  # Try to stop the container if it exists and is running
  if docker ps -q -f name=open-webui > /dev/null 2>&1; then
    echo "Stopping running container..."
    docker kill open-webui > /dev/null 2>&1
  fi

  # Try to remove the container if it exists
  if docker ps -a -q -f name=open-webui > /dev/null 2>&1; then
    echo "Removing existing container..."
    docker rm open-webui > /dev/null 2>&1
  fi

  # Remove the old image before starting the new container
  if [ -n "$current_image_id" ]; then
    echo "Cleaning up old OpenWebUI image..."
    if [ "$verbose" = true ]; then
      docker rmi "$current_image_id" || { echo "Failed to remove the old image."; return 1; }
    else
      docker rmi "$current_image_id" > /dev/null 2>&1 || { echo "Failed to remove the old image."; return 1; }
    fi
  fi

  # Start the new container
  start-openwebui || { echo "Failed to start the updated container."; return 1; }

  echo "OpenWebUI has been updated successfully."
}
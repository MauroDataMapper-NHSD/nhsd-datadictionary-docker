#!/usr/bin/env bash

# The purpose of this script is to prepare a server with the necessary packages
# and configuration so that Mauro can be run within a docker container,  It is
# assumed the machine has been setup so that it is visible on the internet with
# the hostname and certificates in place.
#
# The runner of this script must either be an admin or must be in the sudoers
# list prepared to enter their password.
#
# The following is carried out:
#
# 1.  First checks that the required users are present on the system (see the
#     users list below.  If any are not found this script will exit.
#
# 2.  The system is updated but not rebooted, if the update requires an
#     immediate reboot the script should be stopped, rebooted and the script
#     re-run later.
#
# 3.  Install the Docker apt repository—this should only be done once.
#
# 4.  The required (and useful) packages are installed.  This includes Docker
#     which should be running immediately after installation.
#
# 5.  The users are added to the docker group so they are able to control it.
#
# 6.  Users are also added to the `id` group, if the `id` group does not exist
#     it is created first.
#
# 7.  Creates a `/home/build` directory where the docker containers are to
#     built and all users have access to.
#

set -euo pipefail
IFS=$'\n\t'

# This is the list is users required to be on this system
users=("mhewlett" "obutler" "pmonks")

pause() {
  echo -en "\n$1 (y/N)? "
  while true; do
    read -s -n1 key

    case $key in
      y|Y)
        echo "y"
        return 0
        ;;
      n|N)
        echo "n"
        return 1
        ;;
      '')
        echo "n"
        return 1
        ;;
      *)
        ;;
    esac
  done
}

##################################################
if pause "1. Checking the expected users are here"; then
  missing_user=""

  for user in ${users[@]}; do
    if [[ ! $(getent passwd $user) ]]; then
      missing_user+=" $user,"
    fi
  done

  if [[ -n $missing_user ]]; then
    >&2 echo "Please ensure these users are present:${missing_user%,}"
    exit 1
  fi
fi

##################################################
if pause "2. Update the system"; then 
  sudo apt update && sudo apt update
fi

##################################################
if pause "3. Install the apt repository for Docker"; then 

  # From the Docker manuals (https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
  sudo apt install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

fi

##################################################
if pause "4. Install the required packages"; then

  sudo apt install -y build-essential inetutils-traceroute apt-transport-https \
    curl docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
    docker-compose-plugin ripgrep net-tools nginx

  if [[ $(systemctl is-active docker) == "active" ]]; then
    echo "Docker is running"
  else
    >&2 echo "Docker does not appear to be running - please investigate"
    exit 3
  fi
fi

##################################################
if pause "5. Add users to the docker group"; then

  # Add the users to the docker group
  for user in ${users[@]}; do
    sudo usermod -a -G docker "$user"
  done
fi

##################################################
if pause "6. Add users to the id group"; then

  if [ $(getent group id) ]; then
    echo "id group exists."
  else
    echo "create id group."
    sudo groupadd -r id
  fi

  for user in ${users[@]}; do
    sudo usermod -a -G id "$user"
  done
fi

##################################################
if pause "7. Create build directory"; then
  cd /home
  sudo mkdir build
  sudo chgrp -R id build
  sudo chmod g+rwx build
  sudo chmod g+s build
fi


#!/bin/bash
profilePath="/var/lib/boot2docker/profile"

dockerUnsetProxy(){
  if [ -z "$DOCKER_MACHINE_NAME" ]; then
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak \"/http_proxy/d\" $profilePath"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak \"/https_proxy/d\" $profilePath"
  fi
}

dockerGetProxy(){
  if [ -n "$DOCKER_MACHINE_NAME" ]; then
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo cat $profilePath | grep http_proxy"
  fi
}

dockerSetProxy(){
  host=$1
  port=$2
  if [ -n "$DOCKER_MACHINE_NAME" ]; then
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak \"/http_proxy/d\" $profilePath"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak \"/https_proxy/d\" $profilePath"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak -e \"\\\$a\\\export http_proxy=\\\"http://${host}:${port}\\\"\" ${profilePath}"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak -e \"\\\$a\\\export https_proxy=\\\"https://${host}:${port}\\\"\" ${profilePath}"
  fi
}

dockerUnsetNoProxy(){
  if [ -n "$DOCKER_MACHINE_NAME" ]; then
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak \"/no_proxy/d\" $profilePath"
  fi
}

dockerSetNoProxy(){
  no_proxy=$1
  if [ -n "$DOCKER_MACHINE_NAME" ]; then
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak \"/no_proxy/d\" $profilePath"
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak -e \"\\\$a\\\export no_proxy=\\\"${no_proxy}\\\"\" ${profilePath}"
  fi
}

dockerUseMachine(){
  name=$1
  if [ "$name" != "$DOCKER_MACHINE_NAME" ]; then
    docker-machine stop "$DOCKER_MACHINE_NAME"
    docker-machine start "$name"
  fi
  eval "$(docker-machine env $name)"
  dockerenv=$'#!/bin/sh\neval "$(docker-machine env '$name')"'
  echo "$dockerenv" > "${DOTFILES}/bash/external/docker.sh"
}

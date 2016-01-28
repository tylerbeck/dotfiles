#!/bin/bash
profilePath="/var/lib/boot2docker/profile"

_mydocker-require-machine(){
  if [ -z "$DOCKER_MACHINE_NAME" ]; then
    echo "DOCKER_MACHINE_NAME not set"
  fi
}

mydocker() {
  if [ $# -eq 0 ]; then
    docker-machine active
  elif [ $# -eq 1 ]; then
      eval "mydocker-$1"
  elif [ $# -eq 2 ]; then
      eval "mydocker-$1 $2"
  elif [ $# -eq 3 ]; then
      eval "mydocker-$1 $2 $3"
  elif [ $# -eq 4 ]; then
      eval "mydocker-$1 $2 $3 $4"
  fi
}

mydocker-route-local() {
  sudo route delete -net 192.168.99
  sudo route add -net 192.168.99 -interface vboxnet0
}

mydocker-use() {
  name=${1:-"default"}

  is_running=$(docker-machine status $name | grep -c Running)
  if [ $is_running -eq 0 ]; then
    docker-machine start "$name"
  fi

  eval "$(docker-machine env "$name")"
  # DOCKER_MACHINES_HOME=${DOCKER_HOME}/machines
  # DOCKER_CERTS_HOME=${DOCKER_HOME}/certs
  # HOST_DOCKER_DAEMON_PORT=2376
  #
  # export DOCKER_TLS_VERIFY="1"
  # export DOCKER_HOST="tcp://localhost:${HOST_DOCKER_DAEMON_PORT}"
  # export DOCKER_CERT_PATH="${DOCKER_MACHINES_HOME}/${name}"
  # export DOCKER_MACHINE_NAME="${name}"

  #
  #
  # export DOCKER_TLS_VERIFY="1"
  # export DOCKER_HOST="tcp://192.168.99.100:2376"
  # export DOCKER_CERT_PATH="/opt/boxen/data/docker/machines/default"
  # export DOCKER_MACHINE_NAME="default"


  dockerenv=$'#!/bin/sh\nmydocker use '$name
  echo "$dockerenv" > "${DOTFILE_SCRIPTS}/state/docker.sh"
}

mydocker-port-forward() {
  _mydocker-require-machine

  is_running=$(docker-machine status $DOCKER_MACHINE_NAME | grep -c Running)
  was_running=$is_running
  if [ $is_running -gt 0 ]; then
    docker-machine stop "$name"
  fi

  if [ $# -eq 3 ]; then
    if [ "$1" = "remove" ]; then
      echo "removing rule: $2-port_$3"
      VBoxManage modifyvm $DOCKER_MACHINE_NAME --natpf1 delete "$2-port_$3"
    else
      echo "adding rule: $2-port_$3"
      VBoxManage modifyvm $DOCKER_MACHINE_NAME --natpf1 "$2-port_$3,$2,,$3,,$3"
    fi
  else
    echo "missing parameters"
  fi

  #if [ $was_running -gt 0 ]; then
    #docker-machine start "$DOCKER_MACHINE_NAME"
  #fi
}

mydocker-generate-certs() {
  _mydocker-require-machine
  name=${1:-$DOCKER_MACHINE_NAME}

  DOCKER_MACHINES_HOME=${DOCKER_HOME}/machines
  DOCKER_CERTS_HOME=${DOCKER_HOME}/certs
  SERVER_PEM_LOCATION=/var/lib/boot2docker/server.pem
  SERVER_PEM=`docker-machine ssh ${name} "openssl x509 -noout -text -in ${SERVER_PEM_LOCATION}"`

  #docker-machine ssh default "openssl x509 -noout -text -in /var/lib/boot2docker/server.pem"

  if [[ ${SERVER_PEM} != *"CN=localhost"* && ${SERVER_PEM} != *"IP:127.0.0.1"* ]]; then
    #(Re)create the cert if it's missing localhost or 127.0.0.1
    echo "=====[${name}] Creating a new Docker daemon certificate====="
    #Let's be good citizens.  Preserve the original cert and re-use the private key.
    mv ${DOCKER_MACHINES_HOME}/${name}/server.pem ${DOCKER_MACHINES_HOME}/${name}/server.pem.bak

    #Create a new cert for the Docker daemon and sign it
    openssl req -subj "/CN=localhost" -sha256 -new -key ${DOCKER_MACHINES_HOME}/${name}/server-key.pem -out ${DOCKER_MACHINES_HOME}/${name}/server.csr
    echo "subjectAltName = DNS:localhost,IP:$(docker-machine ip ${name}),IP:127.0.0.1" > ${DOCKER_MACHINES_HOME}/${name}/extfile.cnf
    openssl x509 -req -days 365 -sha256 -in ${DOCKER_MACHINES_HOME}/${name}/server.csr -CA ${DOCKER_CERTS_HOME}/ca.pem -CAkey ${DOCKER_CERTS_HOME}/ca-key.pem -set_serial 0x6f6e656a6c69 -out ${DOCKER_MACHINES_HOME}/${name}/server.pem -extfile ${DOCKER_MACHINES_HOME}/${name}/extfile.cnf

    #Deploy the new cert to the Docker host and restart the Docker daemon to pick up the change
    echo "=====[${name}] Deploying Certificate to Docker host====="
    NEW_SERVER_PEM=`cat ${DOCKER_MACHINES_HOME}/${name}/server.pem`
    docker-machine ssh ${name} "echo -e '${NEW_SERVER_PEM}' | sudo tee ${SERVER_PEM_LOCATION}"
    #echo "restarting ${name}..."
    #docker-machine restart ${name}
  fi
}

mydocker-profile() {
  _mydocker-require-machine

  if [ $# -lt 2 ]; then
    echo "missing parameters"
  fi

  if [ "$1" = "remove" ]; then
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak \"/$2/d\" $profilePath"
  elif [ "$1" = "set" ]; then
    if [ -n "$3" ]; then
      docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak \"/$2/d\" $profilePath"
      docker-machine ssh $DOCKER_MACHINE_NAME "sudo sed -i.bak -e \"\\\$a\\\export $2=\\\"$3\\\"\" ${profilePath}"
    else
      echo "missing parameters"
    fi
  elif [ "$1" = "get" ]; then
    docker-machine ssh $DOCKER_MACHINE_NAME "sudo cat $profilePath | grep $2"
  else
    echo "unknown action: $action"
  fi
}

mydocker-proxy() {
  if [ $# -eq 3 ]; then
    action=$1
    host=$2
    port=$3
  elif [ $# -eq 0 ]; then
    action="get"
  else
    echo "missing parameters"
  fi

  if [ "$action" = "set" ]; then
    mydocker-profile set http_proxy "http://${host}:${port}"
    mydocker-profile set https_proxy "https://${host}:${port}"
  elif [ "$action" = "remove" ]; then
    mydocker-profile remove http_proxy
    mydocker-profile remove https_proxy
  elif [ "$action" = "get" ]; then
    echo "http_proxy: $(mydocker-profile get http_proxy)"
    echo "https_proxy: $(mydocker-profile get https_proxy)"
  else
    echo "unknown action: $action"
  fi
}

mydocker-noproxy() {
  if [ $# -eq 2 ]; then
    action=$1
    hosts=$2
  elif [ $# -lt 1 ]; then
    action="get"
  else
    echo "missing parameters"
  fi

  if [ "$action" = "set" ]; then
    mydocker-profile set no_proxy "${hosts}"
  elif [ "$action" = "remove" ]; then
    mydocker-profile remove no_proxy
  elif [ "$action" = "get" ]; then
    echo "no_proxy: $(mydocker-profile get no_proxy)"
  else
    echo "unknown action: $action"
  fi
}

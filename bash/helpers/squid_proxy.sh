#!/bin/bash

proxy(){
  if [ -z $1 ]; then
    proxy_status
  else
    eval "proxy_$1"
  fi
}

_proxy_assign(){
   HTTP_PROXY_ENV="http_proxy ftp_proxy all_proxy HTTP_PROXY FTP_PROXY ALL_PROXY"
   HTTPS_PROXY_ENV="https_proxy HTTPS_PROXY"
   for envar in $HTTP_PROXY_ENV
   do
     export $envar=$1
   done
   for envar in $HTTPS_PROXY_ENV
   do
     export $envar=$2
   done
   for envar in "no_proxy NO_PROXY"
   do
      export $envar=$3
   done
}

proxy_stop(){
   _proxy_assign ""
   npm config set strict-ssl true
   apm config set strict-ssl true

   git config --global --unset http.proxy
   git config --global --unset https.proxy

   npm config rm proxy
   npm config rm https-proxy

   apm config rm proxy
   apm config rm https-proxy

   proxycmd=$'#!/bin/sh\nproxy stop\n'
   echo "$proxycmd" > "${DOTFILE_SCRIPTS}/state/proxy.sh"

   osascript -e 'quit app "SquidMan"'
   pkill squid
   pkill squid-1
}

_proxy_init(){
   http_proxy_value="http://$1:$2"
   https_proxy_value="https://$1:$2"
   no_proxy_value="localhost,127.0.0.1,docker.kroger.com,$(docker-machine ip default)"

   git config --global http.proxy $http_proxy_value
   git config --global https.proxy $https_proxy_value

   npm config set proxy $http_proxy_value
   npm config set https-proxy $http_proxy_value

   apm config set proxy $http_proxy_value
   apm config set https-proxy $http_proxy_value

   _proxy_assign $http_proxy_value $https_proxy_value $no_proxy_value
 }

proxy_start(){
   domain=localhost
   port=3128

   npm config set strict-ssl false
   apm config set strict-ssl false

   _proxy_init $domain $port

   proxycmd=$'#!/bin/sh\nproxy start\n'
   echo "$proxycmd" > "${DOTFILE_SCRIPTS}/state/proxy.sh"

   if [ -z $(pgrep SquidMan) ]; then
     open ~/Applications/SquidMan.app
   fi
 }

 proxy_status(){
   status="inactive"
   currentProxyCmd="$(cat "${DOTFILE_SCRIPTS}/state/proxy.sh" | grep proxy)"
   if [ "$HTTP_PROXY" = "http://localhost:3128" ] ||
       [ "$currentProxyCmd" = "proxy start" ]; then
     if [ "$HTTP_PROXY" = "" ] ||
         [ "$currentProxyCmd" = "proxy stop" ]; then
          status="dirty"
     else
       status="active"
     fi
   fi
   echo "$status"
 }

#!/bin/bash
#REQUIRES: ${DOTFILE_SCRIPTS}/helpers/docker.sh

proxyAssign(){
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

proxyStop(){
   proxyAssign ""
   npm config set strict-ssl true
   apm config set strict-ssl true

   git config --global --unset http.proxy
   git config --global --unset https.proxy

   npm config rm proxy
   npm config rm https-proxy

   apm config rm proxy
   apm config rm https-proxy

   dockerUnsetProxy

   proxycmd=$'#!/bin/sh\nproxyStop\n'
   echo "$proxycmd" > "${DOTFILE_SCRIPTS}/state/proxy.sh"
}

proxyInit(){
   http_proxy_value="http://$1:$2"
   https_proxy_value="https://$1:$2"
   no_proxy_value="localhost,127.0.0.1,docker.kroger.com,$(docker-machine ip default)"

   git config --global http.proxy $http_proxy_value
   git config --global https.proxy $https_proxy_value

   npm config set proxy $http_proxy_value
   npm config set https-proxy $http_proxy_value

   apm config set proxy $http_proxy_value
   apm config set https-proxy $http_proxy_value

   dockerSetNoProxy $no_proxy_value
   proxyAssign $http_proxy_value $https_proxy_value $no_proxy_value
 }

proxyStart(){
   domain=localhost
   port=3128

   npm config set strict-ssl false
   apm config set strict-ssl false

   proxyInit $domain $port

   dockerSetProxy $(ipconfig getifaddr en0) $port

   proxycmd=$'#!/bin/sh\nproxyStart\n'
   echo "$proxycmd" > "${DOTFILE_SCRIPTS}/state/proxy.sh"
 }

 proxyStatus(){
   status="inactive"
   currentProxyCmd="$(cat "${DOTFILE_SCRIPTS}/state/proxy.sh" | grep proxy)"
   if [ "$HTTP_PROXY" = "http://localhost:3128" ] ||
       [ "$currentProxyCmd" = "proxyStart" ]; then
     if [ "$HTTP_PROXY" = "" ] ||
         [ "$currentProxyCmd" = "proxyStop" ]; then
          status="dirty"
     else
       status="active"
     fi
   fi
   echo "$status"
 }

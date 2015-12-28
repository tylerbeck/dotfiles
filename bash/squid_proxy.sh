#!/bin/bash

 assignProxy(){
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

 stopProxy(){
   assignProxy ""
   npm config set strict-ssl true
   apm config set strict-ssl true

   git config --global --unset http.proxy
   git config --global --unset https.proxy

   npm config rm proxy
   npm config rm https-proxy

   apm config rm proxy
   apm config rm https-proxy
}

 initProxy(){
   http_proxy_value="http://$1:$2"
   https_proxy_value="https://$1:$2"
   no_proxy_value="localhost,127.0.0.1"

   git config --global http.proxy $http_proxy_value
   git config --global https.proxy $https_proxy_value

   npm config set proxy $http_proxy_value
   npm config set https-proxy $https_proxy_value

   apm config set proxy $http_proxy_value
   apm config set https-proxy $https_proxy_value

   assignProxy $http_proxy_value $https_proxy_value $no_proxy_value
 }

startProxy(){
   domain=localhost
   port=3128

   npm config set strict-ssl false
   apm config set strict-ssl false

   initProxy $domain $port
 }

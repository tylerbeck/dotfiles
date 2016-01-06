__proxy_ps1 ()
{
  proxy_prompt=""
  proxy_str="<"
  currentProxyCmd="$(cat .bash/proxy.sh | grep Proxy)"
  if [ "$HTTP_PROXY" = "http://localhost:3128" ] ||
   	 [ "$currentProxyCmd" = "startProxy" ]; then
    if [ "$HTTP_PROXY" = "" ] ||
     	 [ "$currentProxyCmd" = "stopProxy" ]; then
         proxy_prompt="$PC_RED${proxy_str}"
    else
      proxy_prompt="$PC_YELLOW${proxy_str}"
    fi
  fi
  printf "$proxy_prompt"
}

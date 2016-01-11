__proxy_ps1 ()
{
  proxy_status="$(proxyStatus)"
  proxy_prompt=""
  proxy_str="<"
  currentProxyCmd="$(cat "${DOTFILES}/bash/proxy.sh" | grep Proxy)"
  if [ "$proxy_status" = "active" ]; then
    proxy_prompt="$PC_YELLOW${proxy_str}"
  fi
  if [ "$proxy_status" = "dirty" ]; then
    proxy_prompt="$PC_RED${proxy_str}"
  fi
  printf "$proxy_prompt"
}

__proxy_ps1 ()
{
  proxystatus="$(proxy status)"
  proxy_prompt=""
  proxy_str="<"
  if [ "$proxystatus" = "active" ]; then
    proxy_prompt="$PC_YELLOW${proxy_str}"
  fi
  if [ "$proxystatus" = "dirty" ]; then
    proxy_prompt="$PC_RED${proxy_str}"
  fi
  printf "$proxy_prompt"
}

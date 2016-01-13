#!/bin/sh
proxycmd=$'#!/bin/sh\nproxy start\n'
echo "$proxycmd" > "/Users/kon4220/Projects/dotfiles/bash/state/proxy.sh"
if [ -z $(pgrep SquidMan) ]; then
  open ~/Applications/SquidMan.app
fi

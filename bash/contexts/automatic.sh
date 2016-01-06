#!/bin/sh
proxycmd=$'#!/bin/sh\nstopProxy\n'
echo "$proxycmd" > "${DOTFILES}/bash/proxy.sh"

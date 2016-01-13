#!/bin/sh
proxycmd=$'#!/bin/sh\nproxy stop\n'
echo "$proxycmd" > "/Users/kon4220/Projects/dotfiles/bash/state/proxy.sh"
osascript -e 'quit app "SquidMan"'
pkill squid
pkill squid-1

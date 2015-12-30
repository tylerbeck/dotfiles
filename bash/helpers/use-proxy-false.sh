#!/bin/sh
rm ~/.bash/proxy.sh
proxycmd=$'#!/bin/sh\nstopProxy\n'
echo "$proxycmd" > ~/.bash/proxy.sh

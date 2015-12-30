#!/bin/sh
rm ~/.bash/proxy.sh
proxycmd=$'#!/bin/sh\nstartProxy\n'
echo "$proxycmd" > ~/.bash/proxy.sh

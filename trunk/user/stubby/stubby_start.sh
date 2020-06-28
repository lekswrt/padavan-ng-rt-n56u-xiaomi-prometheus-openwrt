#!/bin/sh
# Workarround start stubby witch wrong system time.
# Use /usr/sbin/stubby_start.sh <params1> [<params2> ..[<paramsN>]]

while [ `date +%s` -lt 1593374000 ] ; do
    sleep 10
done

/usr/sbin/stubby -g $1 $2 $3 $4 $5 $6 $7 $8 $9


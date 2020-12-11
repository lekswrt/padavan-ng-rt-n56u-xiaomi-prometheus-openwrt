#!/bin/sh

# # stopping entware services
# if [ -f /opt/etc/init.d/rc.unslung ]; then
#     /opt/etc/init.d/rc.unslung stop
# else
#     echo "entware already stopped"
# fi

# stop all services S* in /opt/etc/init.d
if [ -d /opt/etc/init.d ] ; then
	for i in `ls -r /opt/etc/init.d/S??* 2>/dev/null` ; do
		[ ! -x "${i}" ] && continue
		${i} stop
	done
fi

# take off effect of equal mount-bind commands
RC=0
while [ $RC -eq 0 ]
do
    umount -l /opt 2> /dev/null
    RC=$?
done

# clean up temp dir
# echo "removing temp dirs..."
# rm -rf "/tmp/opt"
#!/bin/sh

# Usage: entware_start.sh [unsafe]
# unsafe - mount /opt/etc to permanent memory (/etc/storage)

# check running entware and stop if needed
entware_stop.sh
# entware ro dir
INSTALL_DIR=/usr/opt

make_dir_rw()
{
    src_dir=$1
    nocopy=$2
    tmp_dir=/tmp
    full_tmp_dir=$tmp_dir$src_dir
    if [ ! -d "$full_tmp_dir" ] || [ ! "$(ls -A $full_tmp_dir)" ]; then
        mkdir -p -m 755 $full_tmp_dir
        echo "copying $src_dir to $full_tmp_dir..."
        cp -dprf $src_dir/. $full_tmp_dir
    fi

    mount --bind $full_tmp_dir $src_dir
}

make_dir_rw_nocopy()
{
    src_dir=$1
    tmp_dir=/tmp
    full_tmp_dir=$tmp_dir$src_dir

    rm -rf $full_tmp_dir
    mkdir -p -m 755 $full_tmp_dir

    mount --bind $full_tmp_dir $src_dir
}

make_dir_rw_permanent()
{
    src_dir=$1
    storage_dir=/etc/storage
    full_storage_dir=$storage_dir$src_dir
    if [ ! -d "$full_storage_dir" ]; then
        mkdir -p -m 755 $full_storage_dir
        echo "copying $src_dir to $full_storage_dir..."
        cp -dprf $src_dir/. $full_storage_dir
    fi

    mount --bind $full_storage_dir $src_dir
}

# entware not installed
if [ ! -d $INSTALL_DIR ]; then
    echo "entware not installed to $INSTALL_DIR"
    exit 0
fi

# bind root dir; do it before commands below
mount --bind $INSTALL_DIR /opt

# trying to save configs in flash memory (/etc/storage)
if [ "$1" == "unsafe" ]; then
    make_dir_rw_permanent /opt/etc
else
    # clean up from previous runs
    rm -rf "/etc/storage/opt"
    make_dir_rw /opt/etc
fi

# make_dir_rw /opt/etc
make_dir_rw /opt/share/www
make_dir_rw /opt/home
make_dir_rw /opt/var
make_dir_rw_nocopy /opt/tmp

# fix rtorrent hangup
rm -rf /opt/var/rpc.socket

export OLDPWD=/opt/home/admin
export TEMP=/opt/tmp
export TMP=/opt/tmp

# may fail with error: /opt/etc/init.d/rc.unslung: line 33: /opt/bin/find: not found
# /opt/etc/init.d/rc.unslung start

# extend path to /opt
export PATH=/opt/sbin:/opt/bin:/usr/sbin:/usr/bin:/sbin:/bin

# start all services S* in /opt/etc/init.d
for i in `ls /opt/etc/init.d/S??* 2>/dev/null` ; do
    [ ! -x "${i}" ] && continue
    ${i} start
done

############### inetd.conf file create ###################
# if app not exist
if [ ! -f /usr/sbin/inetd ]; then
    exit 0
fi
if [ -n "`pidof inetd`" ] ; then
    # stop daemon
    killall -q inetd
fi
LOGIN=`nvram get http_username`
touch /etc/inetd.conf
echo "sane-port stream tcp nowait $LOGIN /opt/sbin/saned saned" > /etc/inetd.conf
/usr/sbin/inetd -R 30 -q 64 /etc/inetd.conf
##########################################################
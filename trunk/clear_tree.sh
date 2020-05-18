#!/bin/sh

ROOTDIR=`pwd`
export ROOTDIR=$ROOTDIR

# Set toolchain default dir (may be redifined in ${ROOTDIR}/.config)
export CONFIG_TOOLCHAIN_DIR="${ROOTDIR}/../toolchain/out"

if [ ! -f "$ROOTDIR/.config" ] ; then
	echo "Project config file .config not found! Terminate."
	exit 1
fi

# load project root config
. $ROOTDIR/.config

kernel_id="3.4.x"
kernel_cd="$ROOTDIR/configs/boards/$CONFIG_VENDOR/$CONFIG_FIRMWARE_PRODUCT_ID"
kernel_tf="$ROOTDIR/linux-$kernel_id/.config"
kernel_cf="${kernel_cd}/kernel-${kernel_id}.config"

if [ ! -f "$kernel_cf" ] ; then
        echo "Target kernel config ($kernel_cf) not found! Terminate."
        exit 1
fi
# copy kernel config
cp -fL "$kernel_cf" "$kernel_tf"

echo "-------------CLEAN-ALL---------------"
rm -rf $ROOTDIR/stage
make clean

rm -rfv $ROOTDIR/romfs
rm -rfv $ROOTDIR/images
rm -rfv $ROOTDIR/stage

#!/bin/bash

# Цвета:
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
MOD_NAME=ENTWARE.mod
. ./configs/script.config.sh
. ./modules/$MOD_NAME/common.sh
. ./configs/routers/$ROUTERS.sh
# including localization routines
. ./scripts/localization.sh
################################################################
clear

message entware_module_header

MOD_CONFIG="\n### Include Entware\nCONFIG_FIRMWARE_INCLUDE_ENTWARE=y"

function backup-files {
    :
}

function restore-files {
    :
}

function after-add-mod {
    # router access params: login=$ROOTWRT pass=$PWDR addr=$IPWRT

    # prepare to copy opt dirs
    cp -af "$DIRP/modules/$MOD_NAME/entware" "$DIRP/$ICP/trunk/user/"

    entware_archive="$DIRP/entware.tar.gz"
    if [ -f "$entware_archive" ]; then
        message entware_archive_aready_exists_copying_to_firmware
        get_entware_from_path "$entware_archive"
    else
        get_entware_from_connected_router
    fi

    add-config-mod "$MOD_CONFIG"
}

function after-remove-mod {
    # cleanup dirs
    rm -rf "$DIRP/$ICP/trunk/user/entware/"

    remove-config-mod "$MOD_CONFIG"
}

function test_mod_installed {
    egrep "entware" -o $DIRP/$ICP/trunk/user/Makefile
}

function get_entware_from_connected_router {
    TARGET_PATHS="bin etc home lib sbin share var usr tmp include"

    message router_access_params_is_abc

    # test router's connection
    message testing_router_connection
    sshpass -p "$PWDR" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ROOTWRT"@"$IPWRT" "cd /tmp"
    [ $? -ne 0 ] && rise_error "`message_n cant_get_access_to_the_router`"

    # compress entware (preserve links) on the router
    message compressing_router_entware
    sshpass -p "$PWDR" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ROOTWRT"@"$IPWRT" "cd /opt; tar -zcvf /tmp/entware.tar.gz $TARGET_PATHS"

    # move to vm
    message copying_entware_from_router_to_firmware
    sshpass -p "$PWDR" scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ROOTWRT"@"$IPWRT":"/tmp/entware.tar.gz" "$DIRP/$ICP/trunk/user/entware/"

    # cleanup router
    message cleaning_router_temp_directory
    sshpass -p "$PWDR" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ROOTWRT"@"$IPWRT" rm -f /tmp/entware.tar.gz
}

function get_entware_from_path {
    entware_archive=$1
    cp -f "$entware_archive" "$DIRP/$ICP/trunk/user/entware/"
}

##################### COMMON ROUTINES FOR ALL MODULES ################

MARKER_PATH=$DIRP/modules/$MOD_NAME/first-run-marker5

MOD_DEL=". ./modules/$MOD_NAME/common.sh && remove-patch"
MOD_ADD=". ./modules/$MOD_NAME/common.sh && apply-patch"

INSTALL=1
UNINSTALL=0

function rise_error {
    error_text=$1
    [ -z "$error_text" ] && error_text="Unknown error"
    message error_occured_so_removing_module
    sleep 3
    remove-mod
    exit 0
}

function remove-mod {
    # patch already applied?
    if ! remove-patch; then
        message please_before_module_deletion_update_sources
        add-mod
        remove-mod-hooks "$MOD_DEL" "$MOD_ADD"
        add-mod-hooks "$MOD_DEL" "$MOD_ADD"
        # return 1
    fi

    message module_has_been_deactivated

    if [ ! -f $MARKER_PATH ]; then
        touch $MARKER_PATH
        init-mod-hooks
        return 1
    fi

    remove-mod-hooks "$MOD_DEL" "$MOD_ADD"

    after-remove-mod
}

function add-mod {
    message preparing_module_patch
    if [ ! -f $DIRP/$ICP/trunk/.config ]; then
        cp $DIRP/$DIRC/routers/$ROUTERS.sh $DIRP/$ICP/trunk/.config
    fi

    # patch already applied?
    remove-patch
    apply-patch

    if [ ! -f $MARKER_PATH ] || [ ! -f $DIRP/modules/a-update-s.sh ] || [ ! -f $DIRP/modules/a-update-a.sh ]; then
        touch $MARKER_PATH
        init-mod-hooks
    fi

    add-mod-hooks "$MOD_DEL" "$MOD_ADD"

    after-add-mod
}

while true; do
    if [ -z $(test_mod_installed) ] || [ ! -f $MARKER_PATH ]; then
        ACTION=$INSTALL
        MESSAGE=`message_n do_you_want_to_install_module`
    else
        ACTION=$UNINSTALL
        MESSAGE=`message_n module_already_installed_do_you_want_to_remove`
    fi

    echo -en $MESSAGE

    read yn
    case $yn in
        [Yy]* )
            backup-files

            [ $ACTION -eq $INSTALL ] && add-mod
            [ $ACTION -eq $UNINSTALL ] && remove-mod

            restore-files

            break;;
        [Nn]* )
            message module_operation_canceled

            break;;
        * )
            message enter_yes_no;;
    esac
done

sleep 3

################################################################

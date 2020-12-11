. ./configs/script.config.sh
# including localization routines
. ./scripts/localization.sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIRP="$( pwd )"
MOD_NAME=ENTWARE.mod

function apply-patch {
    pushd $DIRP/$ICP/trunk/

    message applying_entware_patch

    cp -f "$DIRP/modules/$MOD_NAME/entware/entware.patch" .

    patch -N -p0 < entware.patch

    popd
}

function remove-patch {
    pushd $DIRP/$ICP/trunk/
    # cleanup old files
    find . -name *.rej -o -name *.orig | xargs -r rm

    message removing_entware_patch

    cp -f "$DIRP/modules/$MOD_NAME/entware/entware.patch" .

    patch -N -R -p0 < entware.patch
    rm -f entware.patch

    popd
}


################# COMMON ROUTINES FOR ALL MODULES ############################################

function pushd () {
    command pushd "$@" > /dev/null
}

function popd () {
    command popd "$@" > /dev/null
}

function substract-files {
    # smaller file
    FIRST_FILE=$1
    # bigger file
    SECOND_FILE=$2
    SECOND_FILE_TMP=${SECOND_FILE}.tmp

    if [ ! -f $SECOND_FILE ]; then
        echo "substract-files: second param $2 is not file"
        sleep 3
        return 1
    fi

    if [ -f "$FIRST_FILE" ]; then
        FIRST_FILE=`cat $FIRST_FILE`
    fi

    # remove empty line from smaller file
    echo -e "$FIRST_FILE" | grep -ve '^$' | grep -vf - $SECOND_FILE > $SECOND_FILE_TMP

    cmp --silent $SECOND_FILE $SECOND_FILE_TMP && rm -f $SECOND_FILE_TMP && return 1

    # test file is not empty
    [ -s $SECOND_FILE_TMP ] && mv $SECOND_FILE_TMP $SECOND_FILE && chmod +x $SECOND_FILE

    # remove multiple blank lines
    cat -s $SECOND_FILE > $SECOND_FILE_TMP
    [ -s $SECOND_FILE_TMP ] && mv $SECOND_FILE_TMP $SECOND_FILE && chmod +x $SECOND_FILE

    rm -f $SECOND_FILE_TMP
}

# add-mod-hooks $DIRP/modules/TOR.mod/mod-del.sh $DIRP/modules/TOR.mod/mod-add.sh
function add-mod-hooks {
    MOD_DEL=$1
    MOD_ADD=$2

    if [ -f "$MOD_DEL" ]; then
        MOD_DEL=`cat $MOD_DEL`
    fi
    if [ -f "$MOD_ADD" ]; then
        MOD_ADD=`cat $MOD_ADD`
    fi

    remove-mod-hooks "$MOD_DEL" "$MOD_ADD"

    echo -e "$MOD_DEL" >> $DIRP/modules/a-update-s.sh
    echo -e "$MOD_ADD" >> $DIRP/modules/a-update-a.sh
}

# remove-mod-hooks $DIRP/modules/TOR.mod/mod-del.sh $DIRP/modules/TOR.mod/mod-add.sh
function remove-mod-hooks {
    MOD_DEL=$1
    MOD_ADD=$2

    if [ -f "$MOD_DEL" ]; then
        MOD_DEL=`cat $MOD_DEL`
    fi
    if [ -f "$MOD_ADD" ]; then
        MOD_ADD=`cat $MOD_ADD`
    fi

    MOD_BEFORE=$DIRP/modules/a-update-s.sh
    MOD_AFTER=$DIRP/modules/a-update-a.sh

    substract-files "$MOD_DEL" $MOD_BEFORE
    substract-files "$MOD_ADD" $MOD_AFTER
}

# remove-config-mod "$TOR_CONFIG"
function remove-config-mod {
    message removing_module_from_config_ok

    MOD_CONFIG="$1"
    CONFIG=$DIRP/$DIRC/routers/$ROUTERS.sh

    substract-files "$MOD_CONFIG" $CONFIG
}

# add-config-mod "$TOR_CONFIG"
function add-config-mod {
    message adding_module_to_config_ok
    MOD_CONFIG="$1"

    remove-config-mod "$MOD_CONFIG"
    echo -e "$MOD_CONFIG" >> $DIRP/$DIRC/routers/$ROUTERS.sh
}

function init-mod-hooks {
    message resetting_module_settings
    cp -f $DIRP/modules/a-update-s.sh.exemple $DIRP/modules/a-update-s.sh
    cp -f $DIRP/modules/a-update-a.sh.exemple $DIRP/modules/a-update-a.sh
    chmod +x $DIRP/modules/a-update-s.sh $DIRP/modules/a-update-a.sh
}

# test
# remove-mod-hooks ". ./modules/$MOD_NAME/common.sh && remove-patch" ". ./modules/$MOD_NAME/common.sh && apply-patch"

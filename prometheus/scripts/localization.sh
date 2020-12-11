#!/bin/bash

# Script author: Firsthash
# Script created: 01.04.2016

# Цвета:
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIRP="$( pwd )"
MESSAGES_DIR="$DIRP/scripts/messages"
. ./configs/script.config.sh 2> /dev/null
################################################################

function message() {
    msg_id=$1
    localized_msg=`localize $msg_id`

    echo -e "$localized_msg"
}

function message_n() {
    msg_id=$1
    localized_msg=`localize $msg_id`

    echo -en "$localized_msg"
}

function message_red() {
    msg_id=$1
    localized_msg=`localize $msg_id`

    echo -e "$RED $localized_msg $NONE"
}

function message_green() {
    msg_id=$1
    localized_msg=`localize $msg_id`

    echo -e "$GREEN $localized_msg $NONE"
}

function message_blue() {
    msg_id=$1
    localized_msg=`localize $msg_id`

    echo -e "$BLUE $localized_msg $NONE"
}

function message_yellow() {
    msg_id=$1
    localized_msg=`localize $msg_id`

    echo -e "$YELLOW $localized_msg $NONE"
}

function get_current_language() {
    if [ -z "$PROMETHEUS_LANG" ]; then
        result="$LANG" 
    else
        result="$PROMETHEUS_LANG"
    fi
    echo -n "${result::2}" # first two letters of lang code
}

function localize() {
    msg_id=$1

    user_lang=`get_current_language`
    user_lang_lower=${user_lang,,} # lang to lowercase

    declare -A dictionary
    lang_suffix=en
    messages_path_base="$MESSAGES_DIR/messages_"
    if [ -f "$messages_path_base$user_lang_lower" ]; then
        lang_suffix=$user_lang_lower
    fi
    . "$messages_path_base$lang_suffix"

    result="${dictionary["$msg_id"]}"
    [ -z "$result" ] && result="$msg_id"
    echo -n "$result"
}

function move_item_to_top() {
    list=$1
    router_prefix=$2
    first_part=`echo -e "$list" | grep -i "^$router_prefix"`
    test -z $first_part || first_part="$first_part\n" 
    second_part=`echo -e "$list" | grep -vi "^$router_prefix"`
    result="$first_part$second_part"
    echo -e "$result"
}

function select_language_dialog() {
    clear
    pushd "$MESSAGES_DIR" > /dev/null
    user_lang=`get_current_language`
    user_lang_upper=${user_lang^^}
    # list of lang file prefixes
    configs_prom=`ls -1r | grep -oP "(?<=^messages_)..$" | sed 's/.*/\U&/'`

    if [[ ! -z $configs_prom ]]
    then
        while true; do
            clear
            message list_of_available_languages
            I=1
            while read -r line
            do 
                selected=""
                [ "$user_lang_upper" == "$line" ] && selected=" *"
                echo -e "$BLUE $I) $GREEN `echo $line | sed 's/\.config$//'`$selected $NONE"
                CONFIGN["$I"]=$line
                I=$(($I + 1))
            done <<<"$configs_prom"
            read -p "`message_n please_enter_number_of_desired_language`" yn
            if [[ -z ${CONFIGN[$yn]} ]]
            then
               message please_select_existed_language
               sleep 1
            else
               message selected_language_is_abc
               PROMETHEUS_LANG=`echo "${CONFIGN[$yn]}"`
               cd $DIRP
               if [[ -z $(egrep "^PROMETHEUS_LANG=*" -o ./$DIRC/script.config.sh) ]]
               then
                  echo -e "\n# Language\nPROMETHEUS_LANG=" >> ./$DIRC/script.config.sh
               fi
               sed -i s/PROMETHEUS_LANG=.*/PROMETHEUS_LANG=\"$(echo $PROMETHEUS_LANG | sed 's/\"/\\\\"/g')\"/ ./$DIRC/script.config.sh
               break
            fi
        done
        clear
        echo -e "$PROMETHEUS"
        echo -e "$ST1"
        echo -e "$ST2"
        message dependencies_ok
        echo -e "$ST3"
        echo -e "$ST4"
        echo -e "$BLUE Config:   $NONE$YELLOW    $PROMETHEUS_LANG $NONE"

        cd $DIRP
        exec ./start.sh && exit
    else
        cd $DIRP
        message languages_have_been_lost
        sleep 2
        exec ./start.sh && exit
    fi

    popd
}

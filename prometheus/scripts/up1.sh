#!/bin/bash
#---------------------------------------------------------------
#-Скрипт разработан специально для 4PDA от Foreman (Freize.org)-
#-Распространение без ведома автора запрещено!                 -
#---------------------------------------------------------------
# Цвета:
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
NONE='\033[0m'
# Подключаем локализацию
. ./scripts/localization.sh
#---------------------------------------------------------------
# Конец технического раздела
#---------------------------------------------------------------
message downloading_update
function p_up_tar {
rm -f ./files/loki.tar &>/dev/null
wget -O files/loki.tar http://pm.freize.net/scripts/loki.tar &>/dev/null
message decompressing_update
tar -xvf update.tar
tar -C $ICP -xvf ./$DIRF/loki.tar md5 trunk uboot
tar -xvf ./$DIRF/loki.tar configs/git.sh -C $DIRC
tar -xvf ./$DIRF/loki.tar configs/uboot.sh -C $DIRC
message cleaning_update
rm update.tar &>/dev/null
if [ -f $DIRP/$DIRS/up3.sh ]; then
   rm -f $DIRP/$DIRS/up3.sh  >/dev/null 2>&1
fi
}
function p_up_patch {
rm -f ./files/loki.tar &>/dev/null
wget -O files/loki.tar http://pm.freize.net/scripts/loki.tar &>/dev/null
# tar -C $ICP -xvf ./$DIRF/loki.tar md5 trunk uboot
tar -xvf ./$DIRF/loki.tar configs/git.sh -C $DIRC
tar -xvf ./$DIRF/loki.tar configs/uboot.sh -C $DIRC
}
function p_up_relise {
wget -O update.tar http://pm.freize.net/scripts/update.tar &>/dev/null
}
function p_up_test {
wget -O update.tar http://pm.freize.net/scripts/update-t.tar &>/dev/null
}
if [ $# = 0 ]
then
   p_up_relise
else
   while getopts "rtp" opt ;
   do
       case $opt in
           r) p_up_relise ; p_up_tar ;;
           t) p_up_test ; p_up_tar;;
           p) p_up_patch ;;
           esac
   done
fi

#---------------------------------------------------------------
# Конец скрипта
#---------------------------------------------------------------

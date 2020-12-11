#!/bin/bash
#---------------------------------------------------------------
#-Скрипт разработан специально для 4PDA от Foreman (Freize.org)-
#-Распространение без ведома автора запрещено!                 -
#---------------------------------------------------------------
#Цвета:
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
# Подключаем локализацию
. ./scripts/localization.sh
#---------------------------------------------------------------
# Конец технического раздела
#---------------------------------------------------------------
set_round=1
while true; do
   #проверяем зависимости и выходим если все установлено
   if [ "$set_round" -ge "3" ]
   then
     message software_installation_error
     message press_to_proceed
     read -n1 -s ; read -s -t 0.1
     exit
   fi
   dpkg -s ca-certificates build-essential gawk texinfo pkg-config gettext autoconf automake libtool libtool-bin bison flex zlib1g-dev libgmp3-dev libmpfr-dev libmpc-dev git zip sshpass mc curl python expect bc telnet openssh-client tftpd-hpa libid3tag0-dev gperf libltdl-dev autopoint libarchive-zip-perl python-docutils help2man libncurses5-dev >/dev/null 2>&1 && message dependencies_ok && sleep 0.3 && break
   set_round=$(($set_round + 1))
   message installing_software
   message your_account
   sudo apt-get update
   sudo apt-get -y --force-yes install ca-certificates build-essential gawk texinfo pkg-config gettext autoconf automake libtool libtool-bin bison flex zlib1g-dev libgmp3-dev libmpfr-dev libmpc-dev git zip sshpass mc curl python expect bc telnet openssh-client tftpd-hpa libid3tag0-dev gperf libltdl-dev  autopoint libarchive-zip-perl python-docutils help2man libncurses5-dev
done

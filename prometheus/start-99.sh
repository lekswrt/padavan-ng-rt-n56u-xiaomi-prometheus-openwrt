#!/bin/bash
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
RED0='\033[0;31m'
GREEN0='\033[0;32m'
PROMETHEUS="$BLUE--------------------------------------------------------------------$NONE$GREEN
    0000  0000  00000 0    0 00000 00000 0   0 00000 0   0 00000
    0   0 0   0 0   0 00  00 0       0   0   0 0     0   0 0     
    0000  0000  0   0 0 00 0 00000   0   00000 00000 0   0 00000 
    0     0  0  0   0 0    0 0       0   0   0 0     0   0     0 
    0     0   0 00000 0    0 00000   0   0   0 00000 00000 00000$NONE
$BLUE-------------------------------------------------------------------- $NONE"
PROMETHEUS2="update script"  
clear
echo -e "$PROMETHEUS"
sleep 0.2
echo
DIRP=`pwd`
export DIRP
# Проверяем наличие директорий
rm -R $DIRP/scripts &>/dev/null
mkdir $DIRP/scripts
rm -R $DIRP/configs &>/dev/null
mkdir $DIRP/configs
rm -R $DIRP/files &>/dev/null
mkdir $DIRP/files
rm -R $DIRP/logs &>/dev/null
mkdir $DIRP/logs

   echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
       internet_connection=ok
   else
       internet_connection=error
   fi
   if [ "$internet_connection" == "error" ]
   then
      echo -e "$RED Возможно нет соединения с интернетом! $NONE"
      while true; do
         read -p " Все равно продолжить? " yn
         case $yn in
            [Yy]* ) echo -e "$NONE"; break;;
            [Nn]* ) echo -e "$NONE"; exit;;
                * ) echo -e " Пожалуйста введите yes или no.";;
         esac
      done
   fi

   echo -e "GET http://pm.freize.net HTTP/1.0\n\n" | nc pm.freize.net 80 > /dev/null 2>&1

   if [ $? -eq 0 ]; then
       internet_connection2=ok
   else
       internet_connection2=error
   fi

   if [ "$internet_connection2" == "error" ]
   then
      echo "$RED Удаленный сервер не отвечает! $NONE"
      while true; do
         read -p " Все равно продолжить? " yn
         case $yn in
            [Yy]* ) echo -e "$NONE"; break;;
            [Nn]* ) echo -e "$NONE"; exit;;
                * ) echo -e " Пожалуйста введите yes или no.";;
         esac
      done
   fi
   while true; do
      #проверяем зависимости и выходим если все установлено
      dpkg -s ca-certificates build-essential gawk texinfo pkg-config gettext automake libtool bison flex zlib1g-dev libgmp3-dev libmpfr-dev libmpc-dev git zip sshpass mc curl python expect bc telnet openssh-client tftpd-hpa libid3tag0-dev gperf libltdl-dev autopoint >/dev/null 2>&1 && break 
      echo -e "$YELLOW Устанавливаем ПО, требуется ввести пароль от $NONE"
      echo -e "$YELLOW вашей учетной записи в Linux. $NONE"
      sudo apt-get update
      sudo apt-get -y --force-yes install ca-certificates build-essential gawk texinfo pkg-config gettext automake libtool bison flex zlib1g-dev libgmp3-dev libmpfr-dev libmpc-dev git zip sshpass mc curl python expect bc telnet openssh-client tftpd-hpa libid3tag0-dev gperf libltdl-dev  autopoint
   done
   wget -O update.tar http://pm.freize.net/scripts/update.tar &>/dev/null
   wget -O files/loki.tar http://pm.freize.net/scripts/loki.tar &>/dev/null
   tar -xvf $DIRP/files/loki.tar configs/git.sh -C configs >/dev/null 2>&1
   tar -xvf $DIRP/files/loki.tar configs/uboot.sh -C configs >/dev/null 2>&1
   tar -xvf update.tar
   rm -f update.tar
   ./scripts/up2.sh
   echo -e "$BLUE Скрипты:$NONE$GREEN      OK $NONE"
   sleep 0.1
   exec ./start.sh

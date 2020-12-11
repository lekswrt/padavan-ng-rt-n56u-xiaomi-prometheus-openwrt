#!/bin/bash
################################################################
# Пожалуйста прочитайте следующее:
# Скрипт разработан специально для 4PDA от Foreman (http://freize.org)
# Распространение без ведома автора запрещено!
### ЗАДАЮТСЯ В СКРИПТЕ ###
# $PROMETHEUS - Шапка;
# $PROMETHEUS2 - Версия скрипта;
# $PROMETHEUS3 - Версия патча;
# $stable - Стабильный или тестовый;
# $ST1  - наличие скриптов;
# $ST2  - наличие конфига (не реалезована, бутофория);
# $ST3  - наличие каталогов;
# $ST4  - наличие исходников;
# $ST5  - наличие toolchai (текст);
# $ST52 - toolchai для шапки;
# $FIRM - версия прошивки;
# $SKIN - наличие скина;
# $TCP  - наличие toolchai (1 или 0, служит для пропуска сборки при его присутствии);
# $DIRP - папка с скриптом Прометей;
# $DIRS - папка скриптов (относительный);
# $DIRC - папка с конфигами (относительный);
# $DIRF - папка с файлами (относительный);
# $EFTB - прошивка есть или нет;
# $EE - была ли прошивка EEPROM в эту сессию.
### ПОДГРУЖЕНЫ ИЗ CONFIG ###
# $SNAPSHOT  - формат даты (относительный);
# $IPWRT     - IP адрес устройства;
# $ROOTWRT   - логин от роутера;
# $PWDR      - пароль от роутера.
################################################################
# Цвета:
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
RED0='\033[0;31m'
GREEN0='\033[0;32m'
PROMETHEUS="$BLUE-------------------------------------------------------------------------------$NONE$GREEN
         0000  0000  00000 0    0 00000 00000 0   0 00000 0   0 00000
         0   0 0   0 0   0 00  00 0       0   0   0 0     0   0 0
         0000  0000  0   0 0 00 0 00000   0   00000 00000 0   0 00000
         0     0  0  0   0 0    0 0       0   0   0 0     0   0     0
         0     0   0 00000 0    0 00000   0   0   0 00000 00000 00000$NONE
$BLUE-------------------------------------------------------------------------------$NONE"
export PROMETHEUS
# Нужно задать переменную поумолчанию
SSH=0
TELNET=0
NP="_" # Добавляем прочерки
################################################################
function set_cleoff() {
CLEOFF=1 # Выключить очистку лога
echo -e "$RED Starting with a С option. $NONE"
}
function forced_recording() {
FORCED=1 # Отключить проверку записи для MI-3
echo -e "$RED Starting with a F option. $NONE"
}
function log_off() {
LOGOFF=1 # Отключить запись лога компиляции
echo -e "$RED Starting with a L option. $NONE"
}
if [ $# = 0 ]
then
   echo -e "$GREEN Starting without parameters. $NONE"
   CLEOFF=0
   FORCED=0
   LOGOFF=0
else
   while getopts "cfl" opt ;
   do
       case $opt in
           c) set_cleoff ;;
           f) forced_recording ;;
           l) log_off ;;
           *) echo -e "$RED -c -f -l - skipping cleaning, forced recording MI-3, disables recording compilation log. $NONE" ; sleep 3 ;;
           esac
   done
fi
function CLEOFF() { if [ "$CLEOFF" != 1 ]; then
   clear
fi }
export -f CLEOFF
clear
echo -e "$PROMETHEUS"
sleep 0.2
echo
# Отключаем скринсейвер
setterm -powersave off >/dev/null 2>&1
# Задаём директорию скрипта
DIRP=`pwd`
export DIRP
# Сбрасываем метку EEPROM
EE=1
# Проверяем наличие директорий
if [ ! -d $DIRP/scripts ]; then
   mkdir $DIRP/scripts
fi
if [ ! -d $DIRP/configs ]; then
   mkdir $DIRP/configs
fi
if [ ! -d $DIRP/configs/routers ]; then
   mkdir $DIRP/configs/routers
fi
if [ ! -d $DIRP/files ]; then
   mkdir $DIRP/files
fi
if [ ! -d $DIRP/logs ]; then
   mkdir $DIRP/logs
fi

# Проверяем установлены ли скрипты
function check_files() {
   file_list=("./configs/config.sh"
              "./configs/vi.sh"
              "./configs/uboot.sh"
              "./scripts/restore.sh"
              "./scripts/autoeditor.sh"
              "./scripts/localization.sh"
              "./scripts/messages/messages_en"
              "./scripts/messages/messages_ru"
              "./scripts/messages/messages_example"
              "./scripts/up1.sh"
              "./scripts/up2.sh"
              "./files/full-theme-pack.zip"
              "./files/loki.tar"
              "./start.sh")
   for i in "${file_list[@]}"
   do
       if [ ! -f "$i" ] || [ ! -s "$i" ] ; then
           return 1
       fi
   done
   return 0
}

# connect localization routines
# at this point scripts might be absent
function message() { echo $1; }
function message_n() { echo -n $1; }
. ./scripts/localization.sh 2> /dev/null

function read_n1() {
message press_to_proceed
read -n1 -s ; read -s -t 0.1
}

cd $DIRP
if check_files -eq 0
then
   # Скрипты есть
   message scripts_ok
   ST1=`message_n scripts_ok`
   sleep 0.1
   cd $DIRP
else
   # Скрипты отсутствуют
   #echo -e "GET http://freize.org HTTP/1.0\n\n" | nc freize.org 80 > /dev/null 2>&1
   #if [ $? -eq 0 ]; then
       internet_connection=ok
   #else
   #    internet_connection=error
   #fi
   if [ "$internet_connection" == "error" ]
   then
      message no_internet_connection
      cd $DIRP
      exit
   else
      echo -e "GET http://pm.freize.net HTTP/1.0\n\n" | nc pm.freize.net 80 > /dev/null 2>&1
      if [ $? -eq 0 ]; then
          internet_connection2=ok
      else
          internet_connection2=error
      fi
      if [ "$internet_connection2" == "error" ]
      then
         message remote_server_doesnt_respond
         cd $DIRP
         exit
      else
         echo -e "$BLUE Scripts:$NONE$YELLOW       NOT FOUND $NONE"
         sleep 0.1
         cd $DIRP
         wget -O update.tar http://pm.freize.net/scripts/update.tar &>/dev/null
         wget -O files/loki.tar http://pm.freize.net/scripts/loki.tar &>/dev/null
         tar -xvf update.tar
         tar -xvf ./files/loki.tar configs/git.sh -C configs
         tar -xvf ./files/loki.tar configs/uboot.sh -C configs
         rm -f update.tar
         ./scripts/up2.sh
         message scripts_ok
         sleep 0.1
         exec ./start.sh
      fi
   fi
fi

# Подключаем конфиг
cd $DIRP
if [ ! -f ./configs/script.config.sh ]
then
   cp -f ./configs/config.sh ./configs/script.config.sh
   CLEOFF
   echo -e "$PROMETHEUS"
   echo -e "$ST1"
   sleep 0.1
fi
. ./configs/git.sh
if [[ -z $(egrep "^gitrepo=" -o ./configs/script.config.sh) ]]
then
   echo -e "\ngitrepo=\nICP=\nexport ICP" >> ./configs/script.config.sh
   # mkdir rt-n56u >/dev/null 2>&1
   mkdir padavan-ng >/dev/null 2>&1
fi
. ./configs/script.config.sh
. ./configs/vi.sh
. ./configs/uboot.sh

# Проверяем задан ли репозиторий
# if [[ "$gitrepo" != *"padavan-ng"* ]] && [[ "$gitrepo" != *"rt-n56u"* ]]; then
#    select_repository
# fi
if [[ "$gitrepo" != *"padavan-ng"* ]]; then
   # Меню
   while :
   do
   CLEOFF
   echo -e "$PROMETHEUS"
   message select_the_version_of_the_repository
   echo -e "$NONE 1) Padavan-ng (Linaro) \n 2) Alxdm \n -------------------------------------------------------------------------------"
       read -n1 -s
       case "$REPLY" in
       "1")  gitrepo="https://gitlab.com/padavan-ng/padavan-ng.git"
             ICP=padavan-ng
             export ICP
             sed -i s^gitrepo=.*^gitrepo=\"$(echo $gitrepo)\"^ $DIRP/$DIRC/script.config.sh
             sed -i s^ICP=.*^ICP=$(echo $ICP)^ $DIRP/$DIRC/script.config.sh
             # CLEOFF
             # echo -e "$PROMETHEUS"
             # message padavan_ng_repository_warning
             # read_n1
             if [ -d $DIRP/padavan-fw ]
             then
                rm -rf $DIRP/padavan-fw
             fi
             break ;;
       "2")  gitrepo="https://gitlab.com/dm38/padavan-ng.git"
             ICP=padavan-ng
             export ICP
             sed -i s^gitrepo=.*^gitrepo=\"$(echo $gitrepo)\"^ $DIRP/$DIRC/script.config.sh
             sed -i s^ICP=.*^ICP=$(echo $ICP)^ $DIRP/$DIRC/script.config.sh
             if [ -d $DIRP/padavan-fw ]
             then
                rm -rf $DIRP/padavan-fw
             fi
             break ;;
       # "3")  gitrepo="https://github.com/miracle091/padavan-ng.git"
       #       ICP=padavan-ng
       #       export ICP
       #       sed -i s^gitrepo=.*^gitrepo=\"$(echo $gitrepo)\"^ $DIRP/$DIRC/script.config.sh
       #       sed -i s^ICP=.*^ICP=$(echo $ICP)^ $DIRP/$DIRC/script.config.sh
       #       if [ -d $DIRP/padavan-fw ]
       #       then
       #          rm -rf $DIRP/padavan-fw
       #       fi
       #       break ;;
        * )  message command_not_found ;;
   esac
   sleep 0.3
   done
fi

# Оповещаем о наличии конфига
message config_ok
ST2=`message_n config_ok`
sleep 0.1

# Проверяем зависимости
./$DIRS/up2.sh

# Проверяем наличие директории
if [ -d $DIRP/$ICP ]
then
   # Есть директория
   message directories_ok
   ST3=`message_n directories_ok`
   sleep 0.1
else
   # Нет директории
   message directories_not_found
   ST3=`message_n directories_not_found`
   message creating_directories
   mkdir $ICP >/dev/null 2>&1
   CLEOFF
   echo -e "$PROMETHEUS"
   echo -e "$ST1"
   echo -e "$ST2"
   message dependencies_ok
   message directories_ok
   ST3=`message_n directories_ok`
   sleep 0.1
fi

# Задаём функцию загрузки исходного кода
function git_commit() {
DIRPG=`pwd`
cd $DIRP/$ICP
GITCOMMIT=$(git rev-parse --short HEAD)
GITCOMMITF=$(git rev-parse HEAD)
cd $DIRPG
if [[ "$GITCOMMITF" = "$revisiongit" ]]
then
   GITOK="="
elif [[ "$GITCOMMITF" < "$revisiongit" ]]
then
   GITOK=">"
elif [[ "$GITCOMMITF" > "$revisiongit" ]]
then
   GITOK="<"
fi
}

function ubuntu17() {
if [[ "$ICP" != *"padavan-ng"* ]]; then
   SISTEM=$(cat /etc/*release* | grep "DISTRIB_RELEASE" | grep 17. -c)
      if [[ $SISTEM == 1 ]]; then
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libiconv/libiconv-1.13.1/configure
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libiconv/libiconv-1.13.1/libcharset/configure
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libiconv/libiconv-1.13.1/configure.lineno
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libiconv/libiconv-1.13.1/preload/configure
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libvorbis/libvorbis-1.3.2/configure
      patch -p0 -i $DIRP/patch/busybox.patch >/dev/null 2>&1
   fi
fi
}

function git_clone_p() {
if [[ "$stable" == "STABLE" && "$ICP" != *"padavan-ng"* ]]
then
   git clone $gitrepo # --depth=100 
   git checkout -f $revisiongit
else
   git clone $gitrepo
fi
}

# Проверяем наличие файла
if [[ -f $DIRP/$ICP/readme.rus.txt ]] || [[ -f $DIRP/$ICP/readme.eng.txt ]]
then
   git_commit
   message source_code_ok
   ST4=`message_n source_code_ok`
   sleep 0.1
else
   # Файл не обнаружен
   #echo -e "GET http://pm.freize.net HTTP/1.0\n\n" | nc pm.freize.net 80 > /dev/null 2>&1
   #if [ $? -eq 0 ]; then
       internet_connection=ok
   #else
   #    internet_connection=error
   #fi
   if [ "$internet_connection" == "error" ]
   then
      # Нет соединения
      message no_internet_connection
      exit
   else
      # Есть соединение
      message source_code_not_found
      ST4=`message_n source_code_not_found`
      sleep 0.1
      find $DIRP/$ICP/ -mindepth 1 -delete
      message loading_sources
      select_repository
      CLEOFF
      echo -e "$PROMETHEUS"
      echo -e "$ST1"
      echo -e "$ST2"
      git_clone_p
      message checking_loaded_files
      sleep 0.1
      # Наличие файла
      if [[ -f $DIRP/$ICP/readme.rus.txt ]] || [[ -f $DIRP/$ICP/readme.eng.txt ]]
      then
         # Ничего не делаем
         sleep 0.1
         CLEOFF
         echo -e "$PROMETHEUS"
         echo -e "$ST1"
         echo -e "$ST2"
         git_commit
         message dependencies_ok
         echo -e "$ST3"
         message source_code_ok
         ST4=`message_n source_code_ok`
         sleep 0.1
      else
         # Запускаем скрипт клонирования
         ST4=`message_n sources_error`
         set_round=1
         function download() {
         if [ "$set_round" -ge "3" ]
         then
            message source_code_download_error
            read_n1
            exit
         fi
         message loading_sources
         git_clone_p
         # Проверяем загрузку
         if [[ -f $DIRP/$ICP/readme.rus.txt ]] || [[ -f $DIRP/$ICP/readme.eng.txt ]]
         then
            # Ничего не делаем
            git_commit
            message source_code_ok
         else
            # Запускаем скрипт клонирования
            message sources_error2
            set_round=$(($set_round + 1))
            download
         fi
         }
         download
         sleep 0.2
         CLEOFF
         echo -e "$PROMETHEUS"
         echo -e "$ST1"
         echo -e "$ST2"
         message dependencies_ok
         echo -e "$ST3"
         message source_code_ok
         ST4=`message_n source_code_ok`
         sleep 0.1
      fi
   fi
ubuntu17
cd $DIRP/$ICP
git config core.abbrev 7
cd ..
fi

# Патчим исходники
if [ ! -d $DIRP/$ICP/md5 ]
then
   rm $DIRP/$ICP/trunk/.config >/dev/null 2>&1
   if [[ "$ICP" != *"padavan-ng"* ]]
   then
      tar -C $ICP -xvf ./$DIRF/loki.tar md5 trunk uboot >/dev/null 2>&1
   else
      tar -C $ICP -xvf ./$DIRF/loki.tar md5 uboot >/dev/null 2>&1
   fi
fi
message xrmwrt_patch_ok
sleep 0.1

function move_item_to_top() {
   list=$1
   router_prefix=$2
   first_part=`echo -e "$list" | grep -i "^$router_prefix"`
   test -z $first_part || first_part="$first_part\n"
   second_part=`echo -e "$list" | grep -vi "^$router_prefix"`
   result="$first_part$second_part"
   echo -e "$result"
}

# Выбираем конфиг роутера
if [[ "$ROUTERY" != *"config"* ]]
then
   cd $DIRP/$ICP/trunk/configs/templates
   # Проверяем наличие директорий
   configs_dirs=$(ls)
   # place mi-mini config before mi-nano in the config list
   configs_dirs=`move_item_to_top "$configs_dirs" "xiaomi"`
   configs_dirs=`move_item_to_top "$configs_dirs" "asus"`
   if [[ ! -z $configs_dirs ]]
   then
      while true; do
         CLEOFF
         message configs_to_choose
         echo -e "$NONE-------------------------------------------------------------------------------"
         I=1
         while read -r line
         do
            CONFIGD["$I"]=$line
            I=$(($I + 1))
         done <<<"$configs_dirs"
         for ((i=1; i < $I; i+=3))
         do
            label_i=`printf "%2s" $i`
            label_i1=`printf "%2s" $(($i+1))`
            label_i2=`printf "%2s" $(($i+2))`
            if [[ $(($i+1)) -gt $(($I-1)) ]]
            then
               echo -e "$BLUE $label_i) $GREEN `printf \"%-17s\"  ${CONFIGD[$i]}` $NONE"
            elif [[ $(($i+2)) -gt $(($I-1)) ]]
            then
               echo -e "$BLUE $label_i) $GREEN `printf \"%-17s\" ${CONFIGD[$i]}`	$BLUE $label_i1) $GREEN `printf \"%-17s\" ${CONFIGD[$(($i+1))]}`$NONE"
            else
               echo -e "$BLUE $label_i) $GREEN `printf \"%-17s\" ${CONFIGD[$i]}`	$BLUE $label_i1) $GREEN `printf \"%-17s\" ${CONFIGD[$(($i+1))]}`$NONE	$BLUE $label_i2) $GREEN `printf \"%-17s\" ${CONFIGD[$(($i+2))]}`$NONE"
            fi
         done
         echo -e "$NONE-------------------------------------------------------------------------------$RED"
         read -p "`message_n select_config`" yn
         if [[ -z ${CONFIGD[$yn]} ]]
         then
            message select_existed_config
            sleep 1
         else
            ROUTERY1=`echo "${CONFIGD[$yn]}"`
            cd $ROUTERY1
            # Проверяем наличие конфигов
            configs_prom=$(find . -type f -iname "*.config" -exec ls -1r {} +  | sed 's/.\///')
            # place mi-mini config before mi-nano in the config list
            configs_prom=`move_item_to_top "$configs_prom" "MI-R3G"`
            configs_prom=`move_item_to_top "$configs_prom" "MI-3"`
            configs_prom=`move_item_to_top "$configs_prom" "MI-NANO"`
            configs_prom=`move_item_to_top "$configs_prom" "MI-MINI"`
            if [[ ! -z $configs_prom ]]
            then
               while true; do
                  CLEOFF
                  message configs_to_choose
                  echo -e "$NONE-------------------------------------------------------------------------------"
                  I=1
                  while read -r line
                  do
                     CONFIGN["$I"]=$line
                     I=$(($I + 1))
                  done <<<"$configs_prom"
                  for ((i=1; i < $I; i+=3))
                  do
                     label_i=`printf "%2s" $i`
                     label_i1=`printf "%2s" $(($i+1))`
                     label_i2=`printf "%2s" $(($i+2))`
                     if [[ $(($i+1)) -gt $(($I-1)) ]]
                     then
                        echo -e "$BLUE $label_i) $GREEN `printf \"%-17s\"  ${CONFIGN[$i]} | sed 's/\.config//'` $NONE"
                     elif [[ $(($i+2)) -gt $(($I-1)) ]]
                     then
                        echo -e "$BLUE $label_i) $GREEN `printf \"%-17s\" ${CONFIGN[$i]} | sed 's/\.config//'`	$BLUE $label_i1) $GREEN `printf \"%-17s\" ${CONFIGN[$(($i+1))]} | sed 's/\.config//'`$NONE"
                     else
                        echo -e "$BLUE $label_i) $GREEN `printf \"%-17s\"  ${CONFIGN[$i]} | sed 's/\.config//'`	$BLUE $label_i1) $GREEN `printf \"%-17s\" ${CONFIGN[$(($i+1))]} | sed 's/\.config//'`$NONE	$BLUE $label_i2) $GREEN `printf \"%-17s\" ${CONFIGN[$(($i+2))]} | sed 's/\.config//'`$NONE"
                     fi
                  done
                  echo -e "$NONE-------------------------------------------------------------------------------$RED"
                  read -p "`message_n select_config`" yn
                  if [[ $yn == "Q" ]]
                  then
                     message canceling
                     cd ..
                     break
                  elif [[ -z ${CONFIGN[$yn]} ]]
                  then
                     message select_existed_config
                     sleep 1
                  else
                     message selected_config
                     ROUTERY2=`echo "${CONFIGN[$yn]}"`
                     ROUTERY="$ROUTERY1/$ROUTERY2"
                     cd $DIRP
                     if [[ -z $(egrep "^ROUTERY=*" -o ./$DIRC/script.config.sh) ]]
                     then
                        echo -e "\n# Роутер\nROUTERY=" >> ./$DIRC/script.config.sh
                     fi
                     sed -i s^ROUTERY=.*^ROUTERY=\"$(echo $ROUTERY | sed 's/\"/\\\\"/g')\"^ ./$DIRC/script.config.sh
                     CLEOFF
                     echo -e "$PROMETHEUS"
                     echo -e "$ST1"
                     echo -e "$ST2"
                     message dependencies_ok
                     echo -e "$ST3"
                     echo -e "$ST4"
                     echo -e "$BLUE Config:   $NONE$YELLOW    $ROUTERY $NONE"
                     break
                  fi
               done
            else
               cd $DIRP
               message configs_have_been_lost
               sleep 2
               exec ./start.sh
            fi   
         fi
         if [[ ! -z $ROUTERY ]]
         then
            break
         fi
      done
      CLEOFF
      echo -e "$PROMETHEUS"
      echo -e "$ST1"
      echo -e "$ST2"
      message dependencies_ok
      echo -e "$ST3"
      echo -e "$ST4"
      echo -e "$BLUE Config:   $NONE$YELLOW    $ROUTERY $NONE"
   else
      cd $DIRP
      message configs_have_been_lost
      sleep 2
      exec ./start.sh
   fi
else
   echo -e "$BLUE Config:   $NONE$YELLOW    `echo $ROUTERY | sed 's/\.config//'` $NONE"
fi
cd $DIRP
sleep 0.1

# Подгружаем конфиг
ROUTERS=$(echo "$ROUTERY" | sed 's|.*/||')
export ROUTERS
if [ ! -f $DIRP/$DIRC/routers/$ROUTERS.sh ]
then
   cp -f $DIRP/$ICP/trunk/configs/templates/$ROUTERY $DIRP/$DIRC/routers/$ROUTERS.sh
   if [[ "$ICP" != *"padavan-ng"* ]]
   then
      sed -i "s|CONFIG_TOOLCHAIN_DIR=.*|CONFIG_TOOLCHAIN_DIR=$DIRP/$ICP/toolchain-mipsel|" $DIRP/$DIRC/routers/$ROUTERS.sh
   fi
   # Добавляем места для переменных подключения SSH
fi
# Контролируем наличие настроек SSH
if [[ -z $(egrep "### Connection settings SSH PROMETHEUS" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "\n\n############################################################\n### Connection settings SSH PROMETHEUS\n############################################################\n### IP\nIPWRT=192.168.1.1\n### Login\nROOTWRT=admin\n### Password\nPWDR=\"admin\"\n### SSH Port\nssh_port=\"22\"\n############################################################" >> ./$DIRC/routers/$ROUTERS.sh
fi
. ./$DIRC/routers/$ROUTERS.sh

# Target firmware extension
FEXT=trx
if [[ "$ICP" == *"padavan-ng"* ]] && [[ ! -z $(egrep "^TPLINK_HWID=" -o $DIRP/$ICP/trunk/configs/boards/$CONFIG_VENDOR/$CONFIG_FIRMWARE_PRODUCT_ID/board.mk) ]]
then
   FEXT=bin
fi

function deparagon() {
  {
    cd $DIRP
    if [ ! -z `egrep -o "^CONFIG_FIRMWARE_ENABLE_UFSD=y$" ./$DIRC/routers/$ROUTERS.sh` ]
    then
       return
    fi
    rm -R ./$ICP/trunk/linux-3.4.x/fs/ufsd
    rm -R ./$ICP/trunk/linux-3.0.x/fs/ufsd
    if [ ! -f ./$DIRC/routers/$ROUTERS.sh ]
    then
       rm ./$ICP/trunk/.config
       tar -xvf ./$DIRF/loki.tar -C $ICP >/dev/null 2>&1
       cp -f ./$ICP/trunk/configs/templates/$ROUTERY ./$DIRC/routers/$ROUTERS.sh
    fi

    sed -i "s/.*CONFIG_FIRMWARE_ENABLE_UFSD.*//" ./$DIRC/routers/$ROUTERS.sh
    sed -i "s/.*\"ufsd\" driver.*//" ./$DIRC/routers/$ROUTERS.sh
    sed -i "s/source \"fs\/ufsd\/Kconfig\"//" ./$ICP/trunk/linux-3.4.x/fs/Kconfig
    sed -i "s/.*CONFIG_UFSD_FS.*//" ./$ICP/trunk/linux-3.4.x/fs/Makefile
    sed -i "s/source \"fs\/ufsd\/Kconfig\"//" ./$ICP/trunk/linux-3.0.x/fs/Kconfig
    sed -i "s/.*CONFIG_UFSD_FS.*//" ./$ICP/trunk/linux-3.0.x/fs/Makefile
  } >/dev/null 2>&1
}

# Удаляем запрещённое
deparagon
# Проверяем наличие toolchain
if grep "All IS DONE!" -q $DIRP/logs/build_toolchain_$ICP.log >/dev/null 2>&1
then
   echo -e "$BLUE Toolchain:$NONE$GREEN    OK $NONE"
   ST5="$BLUE Toolchain:$NONE$GREEN    OK $NONE"
   ST52="$BLUE Toolchain:$NONE$GREEN OK$NONE"
   TCP=1
   sleep 0.1
else
   echo -e "$BLUE Toolchain:$NONE$YELLOW    NONE $NONE"
   ST5="$BLUE Toolchain:$NONE$YELLOW    NONE $NONE"
   ST52="$BLUE Toolchain:$NONE$YELLOW NONE$NONE"
   sleep 0.1
   TCP=0
fi
# Проверяем наличие прошивки
function find-firmware() {
if [ -d $DIRP/$ICP/trunk/images* ]
then
   # Каталог обнаружен
   cd $DIRP/$ICP/trunk/images
   # Ищем прошивку
   FF=`find . -type f -iname "$CONFIG_FIRMWARE_PRODUCT_ID$NP*.$FEXT"`
   if [[ $FF == *$CONFIG_FIRMWARE_PRODUCT_ID$NP*.$FEXT ]]
   then
      FFM=`echo "$FF" | sed 's/^\.\///'`
      FFFM=$DIRP/$ICP/trunk/images/$FFM
      echo -e "$BLUE Firmware:$NONE $YELLOW    $FFM $NONE"
      FIRM="$BLUE Firmware:$NONE$YELLOW $FFM$NONE"
      sleep 0.1
   else
      echo -e "$BLUE Firmware:$NONE $YELLOW    NONE $NONE"
      FIRM="$BLUE Firmware:$NONE$YELLOW NONE$NONE"
      sleep 0.1
   fi
else
   echo -e "$BLUE Firmware:$NONE $YELLOW    NONE $NONE"
   FIRM="$BLUE Firmware:$NONE$YELLOW NONE$NONE"
   sleep 0.1
fi
cd $DIRP
}
find-firmware

# Проверяем наличие скина
function finde-skins() {
if [ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/common-theme ]
then
   if [[ "$ROUTERY" == *"wt3020"* ]] || [[ "$ROUTERY" == *"n11p"* ]]
   then
      SKIN=`message_n skin_lite_tp`
      SKIN2=`message_n skin_lite_tp2`
   else
      SKIN=`message_n skin_full_tp`
      SKIN2=`message_n skin_full_tp2`
   fi
else
   SKIN=`message_n skin_original`
   SKIN2=`message_n skin_original2`
fi
sleep 0.1
}
export -f finde-skins
finde-skins
echo -e "$SKIN2"

# Проверяем серийник
SSHT=$(sshpass -p "$PWDR" ssh -T -o StrictHostKeyChecking=no -p $ssh_port -o ConnectTimeout=3 $ROOTWRT@$IPWRT 'cat /dev/mtd2 | grep -oE "SN=[0-9/]+" || cat /dev/mtd1 | grep -oE "SN=[0-9/]+"' 2>/dev/null | sed '$!d' )
if [[ "$SSHT" == "SN="* ]]
then
   SSHTOK=$(echo "$SSHT" | sed 's/SN\=*//')
else
   SSHTOK="--"
fi
sleep 1


#---------------------------------------------------------------
# Начало функций
#---------------------------------------------------------------

function router_id() {
# Проверяем имя роутера на другом конце
rt_hostname=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'echo $HOSTNAME')
if [[ $CONFIG_FIRMWARE_PRODUCT_ID != $rt_hostname ]] || [[ ! -n $rt_hostname ]]
   then
   message ids_comparison
   while true; do
      read -p "`message_n i_understand_and_agree`" yn
      case $yn in
         [Yy]* ) force_flashing=1 ; break;;
         [Nn]* ) force_flashing=0 ; break;;
         * ) message please_enter_yes_or_no;;
      esac
   done
   echo -e " $NONE"
fi
}

function mtd_backup() {

if [ $SSH -eq 0 ] && [ $TELNET -eq 0 ]
then
   return
fi

#err=$(sshpass -p "$PWDR" ssh -T -o StrictHostKeyChecking=no -p $ssh_port -o ConnectTimeout=5 $ROOTWRT@$IPWRT 'uname -a' 2>&1)
#if [[ "$err" == *"Linux $CONFIG_FIRMWARE_PRODUCT_ID"* ]]
#then
echo -e "$RED"
   while true; do
      read -p "`message_n do_you_want_create_backup_of_all_partitions`" yn
      case $yn in
         [Yy]* ) echo -e "$NONE"; break;;
         [Nn]* ) echo -e "$NONE"; return;;
             * ) message enter_yes_no;;
      esac
   done
#fi

message preparing_partitions_backup
if [ ! -d $DIRP/MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID ]; then
   mkdir $DIRP/MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID
fi

if [ -d $DIRP/MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT ]
then
   # Каталог обнаружен
   SNAPSHOT=$(date +%Y-%m-%d_%H:%M:%S)
   #echo -e "$BLUE Бэккап уже есть от $SNAPSHOT $NONE"
fi
#else
   backup_error=0
   if [ ! -d $DIRP/MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT ]; then
      mkdir $DIRP/MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT
   fi

   if [ $SSH -eq 0 ] && [ $TELNET -eq 1 ]
   then
                 HOSTIP=$(ip route show | grep -oE "src ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+){1}" | awk '{print $NF; exit}')
                 message starting_tftp_server_enter_password
                 message from_your_linux_account
                 sudo sed -i "s|TFTP_DIRECTORY=.*|TFTP_DIRECTORY=\"$DIRP/MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT\"|" /etc/default/tftpd-hpa
                 sudo sed -i "s|TFTP_OPTIONS=.*|TFTP_OPTIONS=\"--secure -c\"|" /etc/default/tftpd-hpa
                 sudo chmod -R 777 "$DIRP/MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT"
                 sudo /etc/init.d/tftpd-hpa restart
{
/usr/bin/expect - << EndMark
set timeout 10
spawn telnet $IPWRT
expect "login:"
send "$ROOTWRT\r"
expect "assword:"
send "$PWDR\r"
expect "#"
sleep 2
send "cat /proc/mtd\r"
expect "#"
send "logout\r"
EndMark
} 2>&1 | tee /tmp/telnet_mtd.txt
      all_mtds=$(egrep -o "^mtd([0-9])+" /tmp/telnet_mtd.txt)
      rm /tmp/telnet_mtd.txt
   else
      all_mtds=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd' | egrep "^mtd([0-9])+" -o)
   fi

   while read -r mtd;
   do
      mtdblock=`echo $mtd | sed 's/mtd/mtdblock/'`
      message dumping_partition_to_path_abc
      if [ $SSH -eq 0 ] && [ $TELNET -eq 1 ]
      then
         sudo /etc/init.d/tftpd-hpa restart
{
/usr/bin/expect - << EndMark_download
set timeout 10
spawn telnet $IPWRT
expect "login:"
send "$ROOTWRT\r"
expect "assword:"
send "$PWDR\r"
expect "#"
sleep 2
send "cd /tmp\r"
expect "#"
set timeout 60
send "cat /dev/$mtdblock > $mtd.bin\r"
expect "#"
set timeout 120
send "tftp -p -l $mtd.bin $HOSTIP 69\r"
expect "#"
sleep 1
send "logout\r"
EndMark_download
} 2>&1 | tee /tmp/telnet_firmware.txt
      else
          sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "dd if=/dev/$mtd 2>/dev/null" < /dev/null | dd of=MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/$mtd.bin 2>/dev/null
          #backup_error=0
          if [ -s MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/$mtd.bin ]
          then
             remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "dd if=/dev/$mtd 2>/dev/null | md5sum" < /dev/null | sed 's/ .*//')
             local_md5=$(md5sum MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/$mtd.bin | sed 's/ .*//')
             if [ "$remote_md5" != "$local_md5" ]
             then
                echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                rm MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/$mtd.bin
                backup_error=1
             else
                echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
             fi
          else
             message file_doesnt_exist_or_empty
             rm MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/$mtd.bin
             backup_error=1
          fi
      fi
   done <<< "$all_mtds"
   if [ $backup_error == 1 ]
   then
      message something_goes_wrong_unable_to_create_backup
      read_n1
      exec ./start.sh
   else
      message backup_has_been_saved_to_selected_directory
      all_mtds=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd' | egrep "^mtd([0-9])+" -o | tr '\n' ',' | sed 's/,$//')
      if [[ "$all_mtds" == "mtd0,mtd1,mtd2,mtd3,mtd4,mtd5,mtd6" ]]
      then
         while true; do
            read -p "`message_n do_you_want_to_create_current_state_checkpoint`" yn
            case $yn in
               [Yy]* ) CHKPNT=1 ; break;;
               [Nn]* ) CHKPNT=0 ; break;;
                   * ) message enter_yes_no;;
            esac
            done
         if [[ $CHKPNT == "1" ]]
         then
            cat MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/mtd0.bin MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/mtd1.bin MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/mtd2.bin MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/mtd6.bin  MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/mtd5.bin > MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/xrmwrt_checkpoint.bin
            message checkpoint_has_been_created
         fi
      fi
   fi
#fi
}

function unlock() {
CLEOFF
random_id="`echo $RANDOM % 10000 + 1 | bc`_`date +%s`"
message_n enter_router_ip
read IP
if [ -z $IP ]
then
    IP="192.168.31.1"
fi
message_n webui_pass
read new_password

if [ -z $new_password ] || [[ "$new_password" == "admin" ]] || [[ "$new_password" == "test" ]] || [[ "$new_password" == "root" ]]
then
    message_n bad_pass
    read_n1
    return
fi

message connecting_to_router
web_start=`curl -i -s "http://$IP/cgi-bin/luci/web" 2>/dev/null`
init_router=0

location=`echo "$web_start" | sed -n -r "s|^Location: (.*)+[\r\n]+$|\1|p"`
#echo "$location"
if [[ ! -z "$location" ]]
then
   init_router=1
   web_start=`curl -i -s "http://$IP$location" 2>/dev/null`
   old_password="admin"
else
   old_password="$new_password"
fi

key=`echo $web_start | sed -n -r "s/.*key: '([0-9abcdef]+)',.*/\1/p"`
iv=`echo $web_start | sed -n -r "s/.*iv: '([0-9abcdef]+)',.*/\1/p"`
deviceId=`echo $web_start | sed -n -r "s/.*var deviceId = '([0-9abcdef:]+)';.*/\1/p"`
if [ -z $key ] || [ -z $deviceId ]
then
   message no_connection_with_router
   echo $web_start > /tmp/web_start.html
   read_n1
   return
fi

message logging_to_webui
nonce="0_`echo $deviceId`_`date +%s`_`echo $RANDOM % 10000 + 1 | bc`"
sha1_pwd_key=`echo -n $old_password$key | sha1sum | awk '{print $1}'`
old_pwd=`echo -n $nonce$sha1_pwd_key | sha1sum | awk '{print $1}'`
aes_key=`echo "$sha1_pwd_key" | cut -c1-32`
sha1_newpwd_key=`echo -n $new_password$key | sha1sum | awk '{print $1}'`
new_pwd=`echo -n "$sha1_newpwd_key" | openssl enc -a -aes-128-cbc -K "$aes_key" -iv "$iv"`
#echo $new_pwd
if [ $init_router -gt 0 ]
then
   login=`curl --request POST "http://$IP/cgi-bin/luci/api/xqsystem/login" --data "username=admin" --data "password=$old_pwd" --data "logtype=2" --data "nonce=$nonce" --data "init=1" 2>/dev/null`
else
   login=`curl --request POST "http://$IP/cgi-bin/luci/api/xqsystem/login" --data "username=admin" --data "password=$old_pwd" --data "logtype=2" --data "nonce=$nonce" 2>/dev/null`
fi
#echo $login
token=`echo $login | sed -n -r 's/.*"token":"([[:alnum:]]+)".*/\1/p'`
#echo "token=$token"
if [ -z $token ]
then
   message wrong_pass_or_ipaddr
   read_n1
   return
fi

if [ $init_router -gt 0 ]
then
   nonce="0_`echo $deviceId`_`date +%s`_`echo $RANDOM % 10000 + 1 | bc`"
   old_pwd=`echo -n $nonce$sha1_pwd_key | sha1sum | awk '{print $1}'`
   set_privacy=`curl --request POST "http://$IP/cgi-bin/luci/;stok=$token/api/xqsystem/set_privacy" --data "privacy=1" 2>/dev/null`
   #echo "$set_privacy"
   message init_router
   set_router=`curl --request POST "http://$IP/cgi-bin/luci/;stok=$token/api/misystem/set_router_normal" --data "name=Xiaomi_4589" --data "locale=%E5%AE%B6" --data "ssid=Xiaomi_4589" --data "password=$new_password" --data "encryption=mixed-psk" --data "nonce=$nonce" --data "oldPwd=$old_pwd" --data "newPwd=$new_pwd" --data "txpwr=1" 2>/dev/null`
   echo "$set_router"
fi
message getting_router_info
status=`curl "http://$IP/cgi-bin/luci/;stok=$token/api/misystem/status" 2>/dev/null`
serial=`echo $status | sed -n -r 's/.*"sn":"([0-9\/]+)".*/\1/p'`
platform=`echo $status | sed -n -r 's/.*"platform":"([[:alnum:]]+)".*/\1/p'`
version=`echo $status | sed -n -r 's/.*"version":"([[:alnum:]\.]+)".*/\1/p'`
memory=`echo $status | sed -n -r 's/.*"total":"([0-9 M]+)".*/\1/p'`
revision=`echo $status | sed -n -r 's/.*"channel":"([[:alnum:]]+)".*/\1/p'`
password=`echo -n $serial | echo -n "$(cat -)6d2df50a-250f-4a30-a5e6-d44fb0960aa0" | md5sum | awk '{print $1}' | cut -c1-8`
if [[ -z $platform ]] || [[ -z $version ]] || [[ -z $memory ]] || [[ -z $revision ]]
then
   message unrecognized_router
   while true; do
      read -p "`message_n you_want_to_continue`" yn
      case $yn in
         [Yy]* ) break;;
         [Nn]* ) return ; break;;
             * ) message enter_yes_no;;
      esac
   done
fi

message founded_router_version_is_abc
message your_ssh_telnet_password_is_abc

result=`curl "http://$IP/cgi-bin/luci/;stok=$token/api/xqnetwork/set_wifi_ap?ssid=tianbao&encryption=NONE&enctype=NONE&channel=1%3bnvram+set+ssh_en%3d1%3bnvram+commit%3bsed+-i+%27s%2freturn+0%2fecho+-n%2f%27+%2fetc%2finit.d%2fdropbear%3bsed+-i+%27s%2freturn+0%2fecho+-n%2f%27+%2fetc%2finit.d%2ftelnet%3bkillall+dropbear%3bkillall+telnet%3b%2fetc%2finit.d%2fdropbear+start%3b%2fetc%2finit.d%2ftelnet+start"`
echo $result
#exit
#message launching_telnet_on_router
#result=`curl "http://$IP/cgi-bin/luci/;stok=$token/api/xqsystem/upgrade_rom?url=|/usr/sbin/telnetd" 2>/dev/null`
#if [ $result != '{"code":0}' ]
#then
#   message launch_error_is_abc
#   read_n1
#   return
#else
#   sleep 30
#   message telnet_has_been_launched
#fi
#message launching_ssh
#rm /tmp/ssh_process.html >/dev/null 2>&1
#{
#/usr/bin/expect - << EndMark
#set timeout 10
#spawn telnet $IP
#expect "login:"
#send "root\r"
#expect "assword:"
#send "$password\r"
#expect "#"
#sleep 2
#send "sed -i 's/return 0/echo -n/' /etc/init.d/dropbear\r"
#expect "#"
#send "sed -i 's/return 0/echo -n/' /etc/init.d/telnet\r"
#expect "#"
#send "killall dropbear\r"
#expect "#"
#send "/etc/init.d/dropbear start\r"
#expect "#"
#sleep 2
#send "ps -w | grep -v grep | grep dropbear\r"
#expect "#"
#send "logout\r"
#EndMark
#} 2>&1 | tee /tmp/ssh_process.html

# Задаём параметры замены
IPWRT=$IP
sed -i s/IPWRT=.*/IPWRT=$IPWRT/ ./$DIRC/routers/$ROUTERS.sh
ROOTWRT="root"
sed -i s/ROOTWRT=.*/ROOTWRT=$ROOTWRT/ ./$DIRC/routers/$ROUTERS.sh
PWDR=$password
sed -i s/PWDR=.*/PWDR=\"$(echo $PWDR | sed 's/\"/\\\\"/g')\"/ ./$DIRC/routers/$ROUTERS.sh

#if [[ ! -z $(grep 'Login incorrect' /tmp/ssh_process.html) ]]
#then
#rm /tmp/ssh_process.html >/dev/null 2>&1
#{
#/usr/bin/expect - << EndMark
#set timeout 10
#spawn telnet $IP
#expect "login:"
#send "root\r"
#expect "assword:"
#send "$old_password\r"
#expect "#"
#sleep 2
#send "sed -i 's/return 0/echo -n/' /etc/init.d/dropbear\r"
#expect "#"
#send "sed -i 's/return 0/echo -n/' /etc/init.d/telnet\r"
#expect "#"
#send "killall dropbear\r"
#expect "#"
#send "/etc/init.d/dropbear start\r"
#expect "#"
#sleep 2
#send "ps -w | grep -v grep | grep dropbear\r"
#expect "#"
#send "logout\r"
#EndMark
#} 2>&1 | tee /tmp/ssh_process.html
#PWDR=$old_password
#sed -i s/PWDR=.*/PWDR=\"$(echo $PWDR | sed 's/\"/\\\\"/g')\"/ ./$DIRC/routers/$ROUTERS.sh
#fi

echo
message checking_ssh_access
sleep 30
connect
echo "serial=$serial;model=$platform;version=$version;revision=$revision;memory=$memory;" > /tmp/stats.html
if [ $SSH -eq 1 ]
then
   message congratulations_you_have_obtained_ssh_access
   message access_parameters_for_ssh_are_abc
   sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "nvram set boot_wait=on && nvram set uart_en=1 && nvram commit"
ftp -n -i pm.freize.net &>/dev/null << EOFLOG
      user logs logs1999
      cd /4GB/logs/
      passive
      put /tmp/stats.html success_$random_id.txt
      bye
EOFLOG
else
   message unfortunately_something_goes_wrong
   message please_try_again
   echo "serial=$serial;model=$platform;version=$version;revision=$revision;memory=$memory;" > /tmp/stats.html
ftp -n -i pm.freize.net &>/dev/null << EOFLOG
      user logs logs1999
      cd /4GB/logs/
      passive
 #     put /tmp/ssh_process.html ssh_error_$random_id.txt
      put /tmp/stats.html failure_$random_id.txt
      bye
EOFLOG
fi
rm /tmp/stats.html >/dev/null 2>&1
#rm /tmp/ssh_process.html >/dev/null 2>&1
read_n1
exec ./start.sh
}

function connect() {
# Проверяем подключение
cd $DIRP
TELNET=0
# Очищаем сертификаты
ssh-keygen -R $IPWRT >/dev/null 2>&1
err=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no -o ConnectTimeout=5 $ROOTWRT@$IPWRT 'uname -a' 2>&1)
if  [[ -z $1 ]] && [[ "$err" == *"Linux XiaoQiang"* || "$err" == *"Linux OpenWrt"* || "$err" == *"Linux $CONFIG_FIRMWARE_PRODUCT_ID"* ]]
then
echo -e "$BLUE SSH:    $NONE $GREEN OK $NONE"
SSH=1
sleep 0.3
else
# Меню подключения
while :
do
    CLEOFF
echo -e "$PROMETHEUS"
sleep 0.3
echo -e "$BLUE $NONE"
message connection_settings
echo -e "$BLUE $NONE"
echo -e "$BLUE IP:    $NONE $YELLOW      $IPWRT $NONE"
echo -e "$BLUE Login:    $NONE $YELLOW   $ROOTWRT $NONE"
echo -e "$BLUE Password:  $NONE $YELLOW  $(echo $PWDR | sed 's/\\\"/\"/g') $NONE"
echo -e " "

# Очищаем сертификаты
ssh-keygen -R $IPWRT >/dev/null 2>&1
err=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no -o ConnectTimeout=5 $ROOTWRT@$IPWRT 'uname -a' 2>&1)
if [[ "$err" == *ermission* ]]
then
   message invalid_login_or_password
   SSH=0
elif [[ "$err" == *"ssh: connect"* ]]
then
   SSH=0
   if [[ "$err" == *"onnection refused"* ]]
   then
      message maybe_ssh_connection_forbidden
   elif [[ "$err" == *"o route to host"* || "$err" == *"onnection timed out"* || "$err" == *"ould not resolve"* ]]
   then
      message maybe_ssh_connection_forbidden
   fi
elif [[ "$err" == *"usage: ssh"* ]]
then
   message login_n_pass_couldnt_be_empty
   SSH=0
elif [[ "$err" == *"Linux XiaoQiang"* ]]
then
   message connected_to_mi_mini
   SSHT=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /dev/mtd2 | grep -oE "SN=[0-9/]+" || cat /dev/mtd1 | grep -oE "SN=[0-9/]+"' 2>/dev/null | sed '$!d' )
   SSH=1
elif [[ "$err" == *"Linux $CONFIG_FIRMWARE_PRODUCT_ID"* ]]
then
   message connected_to_config_firmware_product_id
   if [[ "$err" == *"Linux MI-MINI"* ]]
   then
      SSHT=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /dev/mtd2 | grep -oE "SN=[0-9/]+" || cat /dev/mtd1 | grep -oE "SN=[0-9/]+"' 2>/dev/null | sed '$!d' )
   fi
   SSH=1
elif [[ "$err" == *"Linux OpenWrt"* ]]
then
   message connected_to_unknown_device_running_openwrt
   SSH=1
else
   deviceX=$(echo $err | sed 's/[#].*//')
   message connected_to_devicex
   SSH=1
fi

if [ $SSH -eq 0 ]
then
      if [[ "$ROUTERY" == *"wt3020"* ]]
      then
        IPWRT="192.168.8.1"
        ROOTWRT="nexxadmin"
        PWDR="y1n2inc.com0755"
{
/usr/bin/expect - << EndMark_check
set timeout 10
spawn telnet $IPWRT
expect "login"
send "$ROOTWRT\r"
expect "assword:"
send "$PWDR\r"
expect "#"
sleep 2
send "cat /proc/version\r"
expect "#"
send "logout\r"
EndMark_check
} 2>&1 | tee /tmp/telnet_check.txt
        if [[ ! -z "$(grep -i linux /tmp/telnet_check.txt)" ]]
        then
            message obtained_telnet_connection
            TELNET=1
            rm /tmp/telnet_check.txt
            return
        else
            TELNET=0
        fi
        rm /tmp/telnet_check.txt
      fi


   message ssh_access_error
else
   message ssh_access_has_been_granted
fi

    message connection_screen_menu
    read -n1 -s
    case "$REPLY" in
    "1")  CLEOFF
          if [ $SSH -gt 0 ]
          then
             message ssh_access_has_been_granted
          else
             if [ $TELNET -eq 1 ]
             then
                 message telnet_access_has_been_granted
                 break
             fi
             message trying_again
             continue
          fi
          break ;;
    "2")  CLEOFF
          echo -e "$PROMETHEUS"
          message enter_data
          # Параметры роутера
          # IP роутера(192.168.1.1 для xrmwrt или 192.168.31.1 для стока)
          message enter_router_ip2
          message router_ip_examples
          read IPWRT
          #echo -e "$GREEN  ОК $NONE"
          # Логин роутера (admin для xrmwrt или root для стока)
          message enter_router_login
          read ROOTWRT
          #echo -e "$GREEN  ОК $NONE"
          # Пароль роутера (admin для xrmwrt или то, что вы получили на сеайте для стока)
          message enter_router_password
          read PWDR
          #echo -e "$GREEN  ОК $NONE"
          # Задаём параметры замены
          ssh_port_test=$(echo $IPWRT | grep -o ':.*' | grep -o '[^:].*' | grep -o '[0-9]*')
          if [[ -n $ssh_port_test ]]
          then
             ssh_port=$ssh_port_test
             sed -i s/ssh_port=.*/ssh_port=\"$(echo $ssh_port)\"/ $DIRP/$DIRC/routers/$ROUTERS.sh
             IPWRT=$(echo $IPWRT | grep -o '.*:' | grep -o '.*[^:]')
          fi
          sed -i s/IPWRT=.*/IPWRT=\"$(echo $IPWRT)\"/ $DIRP/$DIRC/routers/$ROUTERS.sh
          sed -i "s/ROOTWRT=.*/ROOTWRT=$ROOTWRT/" $DIRP/$DIRC/routers/$ROUTERS.sh
          sed -i s/PWDR=.*/PWDR=\"$(echo $PWDR | sed 's/\"/\\\\"/g')\"/ $DIRP/$DIRC/routers/$ROUTERS.sh
          cd $DIRP ;;
    "F")  CLEOFF
          message enable_ssh_and_enter_data_from_xiaomi_site_or_xrmwrt_webui
          read_n1 ;;
    "f")  message in_capital_letters_please;;
    "Q")  echo -e "$NONE"
          TELNET=0
          SSH=0
          return ;;
    "q")  message in_capital_letters_please;;
     * )  message command_not_found;;
    esac
    sleep 0.3
done
fi
CLEOFF
}
export -f connect

function mi3-recovery() {
  message mi3_recovery_confirm
  while true; do
    read -p "`message_n you_want_to_continue`" yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) return ; break;;
      * ) message enter_yes_no;;
    esac
  done

  connect
  if [ $SSH -eq 0 ]
  then
     return
  fi

  # определяем если мы на стоке
  proc_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd | grep -oEm1 "kernel1"')
  if [[ -z $proc_mtd ]]
  then

    # Получаем раздел где лежит BootEnv
    bootenv_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd' | grep BootEnv | egrep "^mtd([0-9])+" -o)
    sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "cat /dev/$bootenv_mtd" < /dev/null > bootenv.bin
    if [ -s bootenv.bin ]
    then
        remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/$bootenv_mtd" < /dev/null | sed 's/ .*//')
        local_md5=$(md5sum bootenv.bin | sed 's/ .*//')
        if [ "$remote_md5" != "$local_md5" ]
        then
            echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
            rm bootenv.bin
            sleep 5
            return
        else
            echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
        fi
    else
        message file_doesnt_exist_or_empty
        rm bootenv.bin
        sleep 5
        return
    fi
    message preparing_bootenv
    bootenv_crc=$(dd if=bootenv.bin bs=1 count=4 2>/dev/null | od --endian=little -t x4 -An | cut -d' ' -f2)
    dd if=bootenv.bin bs=1 skip=4 count=4092 of=bootenv_data.bin
    check_crc=$(crc32 bootenv_data.bin)
    rm bootenv.bin
    if [ "$bootenv_crc" != "$check_crc" ]
    then
        echo -e "$BLUE BootEnv CRC32 error,$NONE$RED ERROR $NONE"
        while true; do
           read -p "`message_n you_want_to_continue`" yn
           case $yn in
             [Yy]* ) break;;
             [Nn]* ) rm bootenv_data.bin; return ; break;;
                 * ) message enter_yes_no;;
           esac
        done
    else
        echo -e "$BLUE BootEnv CRC32 OK,$NONE$GREEN OK $NONE"
    fi
    dd if=/dev/zero bs=4096 count=1 of=bootenv_zero.bin
    bootenv_position=4
    for w in $(cat bootenv_data.bin | tr "\0" " ") ; do
        if [[ "$w" == "bootdelay="* ]] || [[ "$w" == "boot_wait="* ]] || [[ "$w" == "flag_try_sys1_failed="* ]] || [[ "$w" == "flag_try_sys2_failed="* ]] ||
           [[ "$w" == "telnet_en="* ]] || [[ "$w" == "ssh_en="* ]] || [[ "$w" == "uart_en="* ]]
        then
            continue
        fi

        echo $w | dd bs=1 count=${#w} seek=$bootenv_position of=bootenv_zero.bin conv=notrunc; bootenv_position=$(($bootenv_position+${#w}+1))
    done

    w="bootdelay=5"; echo $w | dd bs=1 count=${#w} seek=$bootenv_position of=bootenv_zero.bin conv=notrunc; bootenv_position=$(($bootenv_position+${#w}+1))
    w="boot_wait=on"; echo $w | dd bs=1 count=${#w} seek=$bootenv_position of=bootenv_zero.bin conv=notrunc; bootenv_position=$(($bootenv_position+${#w}+1))
    w="telnet_en=1";  echo $w | dd bs=1 count=${#w} seek=$bootenv_position of=bootenv_zero.bin conv=notrunc; bootenv_position=$(($bootenv_position+${#w}+1))
    w="ssh_en=1"; echo $w | dd bs=1 count=${#w} seek=$bootenv_position of=bootenv_zero.bin conv=notrunc; bootenv_position=$(($bootenv_position+${#w}+1))
    w="uart_en=1"; echo $w | dd bs=1 count=${#w} seek=$bootenv_position of=bootenv_zero.bin conv=notrunc; bootenv_position=$(($bootenv_position+${#w}+1))
    w="flag_try_sys1_failed=1"; echo $w | dd bs=1 count=${#w} seek=$bootenv_position of=bootenv_zero.bin conv=notrunc; bootenv_position=$(($bootenv_position+${#w}+1))
    w="flag_try_sys2_failed=1"; echo $w | dd bs=1 count=${#w} seek=$bootenv_position of=bootenv_zero.bin conv=notrunc; bootenv_position=$(($bootenv_position+${#w}+1))
    dd if=bootenv_zero.bin bs=1 skip=4 of=bootenv_zero-data.bin
    crc32 bootenv_zero-data.bin | xxd -r -p | od --endian=little -t x4 -An | cut -d' ' -f2 | xxd -r -p | dd bs=1 count=4 conv=notrunc of=bootenv_zero.bin
    rm bootenv_zero-data.bin

    # Загружаем bootenv в роутер
    message uploading_bootenv
    sshpass -p "$PWDR" scp -P $ssh_port -o StrictHostKeyChecking=no bootenv_zero.bin $ROOTWRT@$IPWRT:/tmp/
    # Проверяем md5
    message checking_checksum
    local_md5=$(md5sum bootenv_zero.bin | sed 's/ .*//')
    remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/bootenv_zero.bin" < /dev/null | sed 's/ .*//')
    if [ "$remote_md5" != "$local_md5" ]
    then
        echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
        rm bootenv_zero.bin
        return
    else
        echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
        # Прошиваем
        message flashing_firmware
        sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT  "mtd_write write /tmp/bootenv_zero.bin BootEnv"
        rm bootenv_zero.bin
    fi
  else
    sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "nvram set boot_wait=on && nvram set uart_en=1 && nvram set bootdelay=5 && nvram set flag_try_sys1_failed=1 && nvram set flag_try_sys2_failed=1 && nvram set telnet_en=1 && nvram set ssh_en=1 && nvram commit"
  fi
  sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT /sbin/reboot
  message insert_usb_flash_drive
  exit
}

function p-update() {
         message checking_connection
         echo -e "GET http://pm.freize.net HTTP/1.0\n\n" | nc pm.freize.net 80 > /dev/null 2>&1
         if [ $? -eq 0 ]; then
            internet_connection2=ok
         else
            internet_connection2=error
         fi
         if [ "$internet_connection2" == "error" ]
         then
             message remote_server_doesnt_respond
             exit
         else
#---------------------------------------------------------------
# Подменю начало
#---------------------------------------------------------------
while :
do
CLEOFF
message prometheus_header
sleep 0.1
    message update_prometheus_menu
    read -n1 -s
    case "$REPLY" in
    "1")  CLEOFF
          ./$DIRS/up1.sh -r
          ./$DIRS/up2.sh
          exec ./start.sh ;;
    "2")  CLEOFF
          ./$DIRS/up1.sh -t
          ./$DIRS/up2.sh
          exec ./start.sh ;;
    "3")  CLEOFF
          ./$DIRS/up1.sh -p
          exec ./start.sh ;;
    "F")  message better_use_stable_build
          read_n1 ;;
    "f")  message in_capital_letters_please
          sleep 0.5 ;;
    "Q")  break ;;
    "q")  message in_capital_letters_please
          sleep 0.3 ;;
     * )  message command_not_found
          sleep 0.3 ;;
    esac
done
#---------------------------------------------------------------
# Подменю Конец
#---------------------------------------------------------------
          fi
          cd $DIRP
}

function p-code() {
          cd $DIRP
          # Проверяем наличие скина
          if [ -d "./$ICP/trunk/user/www/n56u_ribbon_fixed/common-theme" ] ; then
             SKIN0=1
             message skins_found
          else
             SKIN0=0
          fi
          if [[ "$CONFIG_FIRMWARE_PRODUCT_ID" == *"wt3020"* ]] || [[ "$CONFIG_FIRMWARE_PRODUCT_ID" == *"n11p"* ]]
          then
             THEME_P="full-theme-pack-lite.zip"
          else
             THEME_P="full-theme-pack.zip"
          fi
          if [ ! -d $DIRP/$DIRF/temp ]; then
             mkdir $DIRP/$DIRF/temp
          fi
          message checking_installed_themes
          dir_list=("./$ICP/trunk/user/www/n56u_ribbon_fixed/grey-theme"
                    "./$ICP/trunk/user/www/n56u_ribbon_fixed/grey2-theme"
                    "./$ICP/trunk/user/www/n56u_ribbon_fixed/blue-theme"
                    "./$ICP/trunk/user/www/n56u_ribbon_fixed/blue2-theme"
                    "./$ICP/trunk/user/www/n56u_ribbon_fixed/yellow-theme"
                    "./$ICP/trunk/user/www/n56u_ribbon_fixed/white-theme")
          for i in "${dir_list[@]}"
          do
              if [ -d "$i" ] ; then
                 line_dir=`basename $i`
                 unzip -oq $DIRP/$DIRF/$THEME_P "$line_dir/*" -d $DIRP/$DIRF/temp
              fi
          done
          if [ $SKIN0 == 1 ]
          then
             message revert_classic_skin
             remove-skins
             sleep 0.1
          fi
          #rm $DIRP/$ICP/trunk/.config >/dev/null 2>&1
          #cd $DIRP/$ICP/trunk/
          #git checkout -- .config
          if [ -f $DIRP/modules/a-update-s.sh ]; then
             cd $DIRP
             ./modules/a-update-s.sh
             cd $DIRP
          fi
          cd $DIRP/$ICP
          message updating_source_code
          #git checkout .
          git pull
          if [[ "$stable" == "STABLE" && "$ICP" != *"padavan-ng"* ]]
          then
             git checkout -f $revisiongit
          fi
          git_commit
          deparagon
          cd $DIRP
          if [ -f $DIRP/modules/a-update-a.sh ]; then
             ./modules/a-update-a.sh
             cd $DIRP
          fi
          if [ "$SKIN0" == 1 ]; then
             I=1
             message updating_skins
             unzip -oq $DIRP/$DIRF/$THEME_P "common-theme/*" -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/
             unzip -cq $DIRP/$DIRF/$THEME_P jquery.js | sed -n -e '/\/\* ATTEPTION TO ADD DYNAMIC THEME SWITCHING \*\//,$p' >> $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/jquery.js
             for i in "${dir_list[@]}"
             do
                line_dir=`basename $i`
                mv $DIRP/$DIRF/temp/$line_dir $i >/dev/null 2>&1
             done
          fi
          finde-skins
          read_n1
          cd $DIRP
}

function toolchain-build() {
    if [[ "$ICP" == *"padavan-ng"* ]]; then
        pushd $DIRP/$ICP/toolchain > /dev/null
        ./build_toolchain.sh 2>&1 | tee -ia $DIRP/logs/build_toolchain_$ICP.log
    else
        pushd $DIRP/$ICP/toolchain-mipsel > /dev/null
        if [[ "$CONFIG_LINUXDIR" != *"3.0"* ]]; then
            ./build_toolchain 2>&1 | tee -ia $DIRP/logs/build_toolchain_$ICP.log
        else
            ./build_toolchain_3.0.x 2>&1 | tee -ia $DIRP/logs/build_toolchain_$ICP.log
        fi
    fi
    popd > /dev/null
}

function toolchain-clean() {
    if [[ "$ICP" == *"padavan-ng"* ]]; then
        pushd $DIRP/$ICP/toolchain > /dev/null
        ./clean_sources.sh
    else
        pushd $DIRP/$ICP/toolchain-mipsel > /dev/null
        ./clean_sources
    fi
    popd > /dev/null
}

function firmware-build() {
    rm $DIRP/logs/build_firmware_$ICP.log >/dev/null 2>&1
    pushd $DIRP/$ICP/trunk > /dev/null
    if [ "$LOGOFF" != 1 ]; then
        if [[ "$ICP" == *"padavan-ng"* ]]; then
            ./build_firmware.sh 2>&1 | tee -ia $DIRP/logs/build_firmware_$ICP.log
        else
            ./build_firmware 2>&1 | tee -ia $DIRP/logs/build_firmware_$ICP.log
        fi
    else
        if [[ "$ICP" == *"padavan-ng"* ]]; then
            ./build_firmware.sh
        else
            ./build_firmware
        fi
    fi
    popd > /dev/null
}

function firmware-clean() {
    # copy config if it does not exists
    if [ ! -f $DIRP/$DIRC/routers/$ROUTERS.sh ]
    then
        cp -f $DIRP/$DIRC/routers/$ROUTERS.sh $DIRP/$ICP/trunk/.config
    fi
    pushd $DIRP/$ICP/trunk > /dev/null
    if [[ "$ICP" == *"padavan-ng"* ]]; then
        ./clear_tree.sh
    else
        ./clear_tree
    fi
    popd > /dev/null
}

function p-toolchain() {
          if [ $TCP -gt 0 ]
          then
             echo -e "$RED"
                while true; do
                   read -p "`message_n rebuild_toolchain`" yn
                   case $yn in
                      [Yy]* ) message toolchain_build_started; break;;
                      [Nn]* ) message toolchain_build_canceled; return;;
                          * ) message enter_yes_no;;
                   esac
                done
          fi
          toolchain-clean
          message building_toolchain
          toolchain-build
          # Проверяем наличие toolchain
          if grep "All IS DONE!" -q $DIRP/logs/build_toolchain_$ICP.log
          then
             # Сборка успешна
             rm $DIRP/logs/build_toolchain_$ICP.log
             echo -e "All IS DONE!" >> $DIRP/logs/build_toolchain_$ICP.log
             echo -e "$BLUE Toolchain:$NONE$GREEN    OK $NONE"
             ST5="$BLUE Toolchain:$NONE$GREEN    OK $NONE"
             ST52="$BLUE Toolchain:$NONE$GREEN OK$NONE"
             TCP=1
             sleep 1
          else
             CLEOFF
             echo -e "$GREEN/------------------------------------------------------------------------------/$NONE";
             grep -iE "(ошибка)|(останов)|(\smissing\s)|(failed$)|(error ([0-9])+$)|(not found$)|(aborted\!)|(stop\.$)" $DIRP/logs/build_toolchain_$ICP.log | awk '!a[$0]++'
             echo -e "$GREEN/------------------------------------------------------------------------------/$NONE";
             echo -e "$BLUE Toolchain:$NONE$RED ERROR$NONE"
             ST52="$BLUE Toolchain:$NONE$RED ERROR$NONE"
             message toolchain_error
             message dont_ask_questions_without_logs
             read_n1
             TCP=0
          fi
          cd $DIRP
}

function r-config() {
cd $DIRP
./$DIRS/autoeditor.sh
}

function p-config() {
#---------------------------------------------------------------
# Подменю начало
#---------------------------------------------------------------
while :
do
cd $DIRP
. ./configs/script.config.sh
CLEOFF
message prometheus_header
sleep 1
if [[ "$ROUTERY" == *"mi-mini"* ]] || [[ "$ROUTERY" == *"mi-nano"* ]] || [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
then
# MI-MINI MENU
    message config_screen_menu_mi_mini
elif [[ "$ROUTERY" == *"wt3020"* ]]
then
# WT3020 MENU
    message config_screen_menu_wt3020
else
    message config_screen_menu_other_routers
fi
    read -n1 -s
    case "$REPLY" in
    "1")  if [ ! -f $DIRP/$DIRC/routers/$ROUTERS.sh ]
          then
             cd $DIRP/$ICP/trunk/configs/templates
             sed -i "s|CONFIG_TOOLCHAIN_DIR=.*|CONFIG_TOOLCHAIN_DIR=$DIRP/$ICP/toolchain-mipsel|" $DIRP/$ICP/trunk/configs/templates/$ROUTERY
             cp -f $DIRP/$ICP/trunk/configs/templates/$ROUTERY $DIRP/$DIRC/routers/$ROUTERS.sh
          fi
          sed -i "s|CONFIG_TOOLCHAIN_DIR=.*|CONFIG_TOOLCHAIN_DIR=$DIRP/$ICP/toolchain-mipsel|" $DIRP/$DIRC/routers/$ROUTERS.sh
          r-config
          cd $DIRP ;;
    "2")  message editor_warning_msg
          read_n1
          if [ ! -f $DIRP/$DIRC/routers/$ROUTERS.sh ]
          then
             cd $DIRP/$ICP/trunk/configs/templates
             sed -i "s|CONFIG_TOOLCHAIN_DIR=.*|CONFIG_TOOLCHAIN_DIR=$DIRP/$ICP/toolchain-mipsel|" $DIRP/$ICP/trunk/configs/templates/$ROUTERY
             cp -f $DIRP/$ICP/trunk/configs/templates/$ROUTERY $DIRP/$DIRC/routers/$ROUTERS.sh
          fi
          sed -i "s|CONFIG_TOOLCHAIN_DIR=.*|CONFIG_TOOLCHAIN_DIR=$DIRP/$ICP/toolchain-mipsel|" $DIRP/$DIRC/routers/$ROUTERS.sh
          mcedit $DIRP/$DIRC/routers/$ROUTERS.sh
          echo -e "$BLUE Config,$NONE$GREEN OK $NONE"
          cd $DIRP ;;
    "3")  #rm $DIRP/$ICP/trunk/configs/boards/$ROUTERY1/board.h
          #rm $DIRP/$ICP/trunk/.config
          rm $DIRP/$DIRC/routers/$ROUTERS.sh
          git checkout $DIRP/$ICP/trunk/configs/boards/
          # tar -xvf ./$DIRF/loki.tar -C $ICP >/dev/null 2>&1
          cp -f $DIRP/$ICP/trunk/configs/templates/$ROUTERY $DIRP/$DIRC/routers/$ROUTERS.sh
          cd $DIRP ;;
    "4")  if [[ "$ROUTERY" == *"mi-mini"* ]] || [[ "$ROUTERY" == *"mi-nano"* ]] || [[ "$ROUTERY" == *"wt3020"* ]] || [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
          then
             message you_dont_have_to_change_opened_file
             read_n1
             if [[ "$ROUTERY" == *"mi-mini"* ]] || [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
             then
                sed -i "s/#define BOARD_GPIO_BTN_RESET	30/#undef  BOARD_GPIO_BTN_RESET/" $DIRP/$ICP/trunk/configs/boards/XIAOMI/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
                sed -i "s/#undef  BOARD_GPIO_BTN_WPS/#define BOARD_GPIO_BTN_WPS	30/" $DIRP/$ICP/trunk/configs/boards/XIAOMI/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
             fi
             if [[ "$ROUTERY" == *"mi-nano"* ]]
             then
                sed -i "s/#define BOARD_GPIO_BTN_RESET	38/#undef  BOARD_GPIO_BTN_RESET/" $DIRP/$ICP/trunk/configs/boards/XIAOMI/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
                sed -i "s/#undef  BOARD_GPIO_BTN_WPS/#define BOARD_GPIO_BTN_WPS	38/" $DIRP/$ICP/trunk/configs/boards/XIAOMI/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
             fi
             if [[ "$ROUTERY" == *"wt3020"* ]]
             then
                sed -i "s/#define BOARD_GPIO_BTN_RESET	1/#undef  BOARD_GPIO_BTN_RESET/" $DIRP/$ICP/trunk/configs/boards/XIAOMI/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
                sed -i "s/#undef  BOARD_GPIO_BTN_WPS/#define BOARD_GPIO_BTN_WPS	1/" $DIRP/$ICP/trunk/configs/boards/XIAOMI/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
             fi
             mcedit $DIRP/$ICP/trunk/configs/boards/XIAOMI/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
             message sources_have_been_patched
          else
             message command_not_found
             sleep 0.3
          fi ;;
    "5")  if [[ "$ROUTERY" == *"mi-mini"* ]] || [[ "$ROUTERY" == *"mi-nano"* ]] || [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
          then
             message you_dont_have_to_change_opened_file
             read_n1
             if [[ "$ROUTERY" == *"mi-mini"* ]] || [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
             then
                sed -i "s/#undef  BOARD_GPIO_LED_LAN/#define BOARD_GPIO_LED_LAN	29/" $DIRP/$ICP/trunk/configs/boards/XIAOMI/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
             fi
             if [[ "$ROUTERY" == *"mi-nano"* ]]
             then
                sed -i "s/#undef  BOARD_GPIO_LED_LAN/#define BOARD_GPIO_LED_LAN	37/" $DIRP/$ICP/trunk/configs/boards/XIAOMI/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
             fi
             mcedit $DIRP/$ICP/trunk/configs/boards/$CONFIG_FIRMWARE_PRODUCT_ID/board.h
             message sources_have_been_patched
          else
             message command_not_found
             sleep 0.3
          fi ;;
    "F")  message in_every_unknown_situation_press_3
          read_n1 ;;
    "f")  message in_capital_letters_please
          sleep 0.5 ;;
    "Q")  break ;;
    "q")  message in_capital_letters_please
          sleep 0.3 ;;
     * )  message command_not_found
          sleep 0.3 ;;
    esac
done
#---------------------------------------------------------------
# Подменю Конец
#---------------------------------------------------------------
}
function remove-skins() {
    rm -rf $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/*-theme
    cd $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed
    git checkout jquery.js
}
function p-skins() {
          # Проверяем наличие скина
          if [[ "$CONFIG_FIRMWARE_PRODUCT_ID" == *"wt3020"* ]] || [[ "$CONFIG_FIRMWARE_PRODUCT_ID" == *"wt3020a"* ]] || [[ "$CONFIG_FIRMWARE_PRODUCT_ID" == *"n11p"* ]]
          then
             THEME_P="full-theme-pack-lite.zip"
          else
             THEME_P="full-theme-pack.zip"
          fi
#---------------------------------------------------------------
# Подменю Начало
#---------------------------------------------------------------
while :
do
CLEOFF
on=ON
off=OFF
function ss-skin() {
if [ ! -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/common-theme ] ; then
   unzip -cq $DIRP/$DIRF/$THEME_P jquery.js | sed -n -e '/\/\* ATTEPTION TO ADD DYNAMIC THEME SWITCHING \*\//,$p' >> $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/jquery.js
   unzip -oq $DIRP/$DIRF/$THEME_P "common-theme/*" -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/
fi
}
echo -e `message_n available_skins` \
        "\n-------------------------------------------------------------------------------"
### Проверка
if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/common-theme ]]
then
   message skins_core_on
else
   message skins_core_off
fi
if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/grey-theme ]]
then
   message grey_theme_on
else
   message grey_theme_off
fi
if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/grey2-theme ]]
then
   message grey_theme_vector_on
else
   message grey_theme_vector_off
fi
if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/blue-theme ]]
then
   message blue_theme_on
else
   message blue_theme_off
fi
if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/blue2-theme ]]
then
   message dark_blue_theme_on
else
   message dark_blue_theme_off
fi
if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/yellow-theme ]]
then
   message yellow_theme_on
else
   message yellow_theme_off
fi
if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/white-theme ]]
then
   message white_theme_on
else
   message white_theme_off
fi
echo -e "$NONE-------------------------------------------------------------------------------"
echo -e "$NONE (F)AQ (Q)uit $NONE\n" \
        "\n" \
        `message_n skins_screen_select_item`
sleep 1
    cat<<EOF7
EOF7
    read -n1 -s
    case "$REPLY" in
    "0")  if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/common-theme ]]
          then
             remove-skins
             cd $DIRP
          else
             ss-skin
          fi ;;
    "1")  if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/grey-theme ]]
          then
             rm -rf $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/grey-theme >/dev/null 2>&1
          else
             ss-skin
             unzip -oq $DIRP/$DIRF/$THEME_P "grey-theme/*" -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/
          fi ;;
    "2")  if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/grey2-theme ]]
          then
             rm -rf $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/grey2-theme >/dev/null 2>&1
          else
             ss-skin
             unzip -oq $DIRP/$DIRF/$THEME_P "grey2-theme/*" -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/
          fi ;;
    "3")  if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/blue-theme ]]
          then
             rm -rf $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/blue-theme >/dev/null 2>&1
          else
             ss-skin
             unzip -oq $DIRP/$DIRF/$THEME_P "blue-theme/*" -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/
          fi ;;
    "4")  if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/blue2-theme ]]
          then
             rm -rf $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/blue2-theme >/dev/null 2>&1
          else
             ss-skin
             unzip -oq $DIRP/$DIRF/$THEME_P "blue2-theme/*" -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/
          fi ;;
    "5")  if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/yellow-theme ]]
          then
             rm -rf $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/yellow-theme >/dev/null 2>&1
          else
             ss-skin
             unzip -oq $DIRP/$DIRF/$THEME_P "yellow-theme/*" -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/
          fi ;;
    "6")  if [[ -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/white-theme ]]
          then
             rm -rf $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/white-theme >/dev/null 2>&1
          else
             ss-skin
             unzip -oq $DIRP/$DIRF/$THEME_P "white-theme/*" -d $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/
          fi ;;
    "F")  message activate_item_with_number_or_return_with_q
          read_n1 ;;
    "f")  message in_capital_letters_please
          sleep 0.5 ;;
    "Q")  break ;;
    "q")  message in_capital_letters_please
          sleep 0.3 ;;
     * )  message command_not_found
          sleep 0.3 ;;
    esac
done
#---------------------------------------------------------------
# Подменю Конец
#---------------------------------------------------------------
          cd $DIRP
          finde-skins
          cd $DIRP
}

function get_max_allowed_size() {
	if [[ "$ICP" == *"padavan-ng"* ]]
	then
		local PARTITIONS_CONFIG=$DIRP/$ICP/trunk/configs/boards/$CONFIG_VENDOR/$CONFIG_FIRMWARE_PRODUCT_ID/partitions.config
		echo `awk '/"Firmware"/{ getline; getline; gsub(/,$/,""); print strtonum($2); }' $PARTITIONS_CONFIG`
	else
		local BOARD_PATH=$DIRP/$ICP/trunk/configs/boards/$CONFIG_FIRMWARE_PRODUCT_ID
		local KC_PATH=$BOARD_PATH/`find $BOARD_PATH -follow -type f -iname "kernel-*.config" | sed q | sed 's/.*kernel/kernel/'`
		if [[ ! -z $(egrep "^CONFIG_RT2880_FLASH_4M=y" -o $KC_PATH) ]]
		then
			echo 3604480
		elif [[ ! -z $(egrep "^CONFIG_RT2880_FLASH_8M=y" -o $KC_PATH) ]]
		then
			echo 7405312
		elif [[ ! -z $(egrep "^CONFIG_RT2880_FLASH_16M=y" -o $KC_PATH) ]]
		then
			echo 15597312
		elif [[ ! -z $(egrep "^CONFIG_RT2880_FLASH_32M=y" -o $KC_PATH) ]]
		then
			echo 32374720
		fi
	fi
}

function p-build() {
          if [ -f $DIRP/modules/a-build.sh ]; then
             ./modules/a-build.sh
          fi
          if [[ "$CONFIG_FIRMWARE_PRODUCT_ID" != *"RT-"* ]] && [[ "$CONFIG_FIRMWARE_PRODUCT_ID" != *"KN-"* ]] && [[ "$ICP" != *"padavan-ng"* ]]
          then
             # Исправляем ошибку с обработкой драйвера из предыдущих версий
             if [ -f $DIRP/$DIRF/ralink_nand.c.backup ]
             then
                cp -f $DIRP/$DIRF/ralink_nand.c.backup $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c  >/dev/null 2>&1
                rm -f $DIRP/$DIRF/ralink_nand.c.backup  >/dev/null 2>&1
             fi
             if [ -f $DIRP/$DIRF/mt6575_sd.c.backup ]; then
                cp -f $DIRP/$DIRF/mt6575_sd.c.backup $DIRP/$ICP/trunk/linux-3.4.x/drivers/mmc/host/mmc-mtk/mt6575_sd.c  >/dev/null 2>&1
                rm -f $DIRP/$DIRF/mt6575_sd.c.backup  >/dev/null 2>&1
             fi
             BMD5OK=0
             local_md5_1=$(md5sum $DIRP/$ICP/trunk/configs/templates/n14u_full.config | sed 's/ .*//')
             patch_md5_1=$(cat $DIRP/$ICP/md5/config.md5 | sed 's/ .*//')
             local_md5_2=$(md5sum $DIRP/$ICP/trunk/configs/boards/RT-N14U/kernel-3.4.x.config | sed 's/ .*//')
             patch_md5_2=$(cat $DIRP/$ICP/md5/kernel.md5 | sed 's/ .*//')
             local_md5_3=$(md5sum $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c | sed 's/ .*//')
             patch_md5_3=$(cat $DIRP/$ICP/md5/ralink_nand.md5 | sed 's/ .*//')
             if [ "$local_md5_1" == "$patch_md5_1" ] && [ "$local_md5_2" == "$patch_md5_2" ]
             then
                if [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]] && [ "$local_md5_3" != "$patch_md5_3" ]
                then
                   BMD5OK=1
                   message source_code_patch_is_bad
                   read_n1
                else
                   message source_code_patch_is_good
                fi
             else
                message source_code_patch_is_bad
                if [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]] && [ "$local_md5_3" != "$patch_md5_3" ]
                then
                   BMD5OK=1
                   read_n1
                else
                   while true; do
                       read -p "`message_n you_want_to_continue_task`" yn
                       case $yn in
                           [Yy]* ) BMD5OK=0 ; break;;
                           [Nn]* ) BMD5OK=1 ; break;;
                           * ) message enter_yes_no;;
                       esac
                   done
                   echo -e " $NONE"
                fi
             fi
          else
             BMD5OK=0
          fi
          if [ $BMD5OK -gt 0 ]
          then
             return
          else
             if [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]; then
                cp -f $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c $DIRP/$DIRF/ralink_nand.c.backup  >/dev/null 2>&1
                if [[ -z $(grep -oE "ranfc_mtd->writebufsize\s*=\s*CFG_PAGESIZE;" $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c) ]]
                then
                   sed -i -E "s/ranfc_mtd->writesize\s*=\s*CFG_PAGESIZE;/ranfc_mtd->writesize\t= CFG_PAGESIZE;\n\tranfc_mtd->writebufsize\t= CFG_PAGESIZE;/" $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c
                fi
                if [[ -z $(grep -oE "^//\s*#define SKIP_BAD_BLOCK" $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c) ]]
                then
                   sed -i -E "s|#define SKIP_BAD_BLOCK|//#define SKIP_BAD_BLOCK|" $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c
                fi
                if [[ -z $(grep -oE "kernel_size\s*\+=\s*ranfc_mtd->erasesize;" $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c) ]]
                then
                   sed -i -E "s/kernel_size\s*=\s*ntohl\(hdr.ih_ksz\);/kernel_size = ntohl\(hdr.ih_ksz\);\n\tcheck = NAND_MTD_KERNEL_PART_OFFSET;\n\twhile \(check < offs \+ kernel_size\) \{\n\t\tif \(nand_block_checkbad\(ra, check\)\)\n\t\t\tkernel_size \+= ranfc_mtd->erasesize;\n\t\tcheck \+= ranfc_mtd->erasesize;\n\t\}/" $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c
                fi
             fi
             if [[ "$ROUTERY" == *"mqmaker-witi"* ]]; then
                cp -f $DIRP/$ICP/trunk/linux-3.4.x/drivers/mmc/host/mmc-mtk/mt6575_sd.c $DIRP/$DIRF/mt6575_sd.c.backup  >/dev/null 2>&1
                if [[ -n $(grep -oE "return ro" $DIRP/$ICP/trunk/linux-3.4.x/drivers/mmc/host/mmc-mtk/mt6575_sd.c) ]]
                then
                   sed -i -E "1825,1827s/return ro/return 0/gi" $DIRP/$ICP/trunk/linux-3.4.x/drivers/mmc/host/mmc-mtk/mt6575_sd.c
                fi
             fi
             if [[ "$ROUTERY" == *"zbt-wg3526"* ]] || [[ "$ROUTERY" == *"zbt-wg1326"* ]] || [[ "$ROUTERY" == *"mi-r3g"* ]]; then
                cp -f $DIRP/$ICP/trunk/linux-3.4.x/arch/mips/rt2880/pci.c $DIRP/$DIRF/pci.c.backup  >/dev/null 2>&1
                patch -p0 -i $DIRP/patch/pci7621.patch >/dev/null 2>&1
             fi
             if [ $TCP -gt 0 ]
             then
                echo -e "$BLUE Toolchain,$NONE$GREEN OK $NONE"
             else
	        p-toolchain
                if [ $TCP -eq 0 ]
                then
                   return
                fi
             fi
             # Firmware exists variable
             EFTB=0
             # Проверяем наличие прошивки
             if [ -d $DIRP/$ICP/trunk/images* ]
             then
                # Каталог обнаружен
                cd $DIRP/$ICP/trunk/images
                # Ищем прошивку
                FF=`find . -type f -iname "$CONFIG_FIRMWARE_PRODUCT_ID*.$FEXT"`
                if [[ $FF == *$CONFIG_FIRMWARE_PRODUCT_ID*.$FEXT ]]
                then
                   # Прошивка найдена
                   EFTB=1
                fi
             fi
             #перезаписываем конфиг
             if [ -f $DIRP/$DIRC/routers/$ROUTERS.sh ]
             then
                cp -f $DIRP/$DIRC/routers/$ROUTERS.sh $DIRP/$ICP/trunk/.config
             fi
             sed -i "s|CONFIG_TOOLCHAIN_DIR=.*|CONFIG_TOOLCHAIN_DIR=$DIRP/$ICP/toolchain-mipsel|" $DIRP/$ICP/trunk/.config
             if [ $EFTB -gt 0 ]
             then
                # Эксперементальная функция
                message you_already_have_build_this_firmware
                message fast_build_available_only_for_same_source_version
                # Тут диалог да/нет или автоматизация
                while true; do
                    read -p "`message_n do_you_want_try_fast_build`" yn
                    case $yn in
                        [Yy]* ) EFTB2=1 ; break;;
                        [Nn]* ) EFTB2=0 ; break;;
                        [Qq]* ) echo -e " $NONE" ; return;;
                        * ) message enter_yes_no;;
                    esac
                done
                echo -e " $NONE"
                if [ $EFTB2 -gt 0 ]
                then
                   FFM=`echo "$FF" | sed 's/^\.\///'`
                   rm -f $DIRP/$ICP/trunk/images/$FFM
                   rm $DIRP/logs/build_firmware_$ICP.log >/dev/null 2>&1
                   cd $DIRP/$ICP/trunk
                   make -C user/httpd clean
                   make -C user/rc clean
                   make -C user/shared clean
                   if [ "$LOGOFF" != 1 ]; then
                      make 2>&1 | tee -ia $DIRP/logs/build_firmware_$ICP.log
                   else
                      make
                   fi
                else
                   # Меняем ответ
                   EFTB=0
                fi
             fi
             if [ $EFTB -gt 0 ]
             then
                echo
             else
                # Собираем полностью
                message cleaning_sources
                firmware-clean
                message building_firmware
                firmware-build
             fi
             if [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]; then
                cp -f $DIRP/$DIRF/ralink_nand.c.backup $DIRP/$ICP/trunk/linux-3.4.x/drivers/mtd/ralink/ralink_nand.c  >/dev/null 2>&1
                rm -f $DIRP/$DIRF/ralink_nand.c.backup  >/dev/null 2>&1
             fi
             if [[ "$ROUTERY" == *"mqmaker-witi"* ]]; then
                cp -f $DIRP/$DIRF/mt6575_sd.c.backup $DIRP/$ICP/trunk/linux-3.4.x/drivers/mmc/host/mmc-mtk/mt6575_sd.c  >/dev/null 2>&1
                rm -f $DIRP/$DIRF/mt6575_sd.c.backup  >/dev/null 2>&1
             fi
             if [[ "$ROUTERY" == *"zbt-wg3526"* ]] || [[ "$ROUTERY" == *"zbt-wg1326"* ]] || [[ "$ROUTERY" == *"mi-r3g"* ]]; then
                cp -f $DIRP/$DIRF/pci.c.backup $DIRP/$ICP/trunk/linux-3.4.x/arch/mips/rt2880/pci.c  >/dev/null 2>&1
                rm -f $DIRP/$DIRF/pci.c.backup  >/dev/null 2>&1
             fi
             # Проверяем готовность прошивки
             if [ -d $DIRP/$ICP/trunk/images* ]
             then
                # Каталог обнаружен
                cd $DIRP/$ICP/trunk/images
                # Ищем прошивку
                FF=`find . -type f -iname "$CONFIG_FIRMWARE_PRODUCT_ID*.$FEXT"`
                if [[ $FF == *$CONFIG_FIRMWARE_PRODUCT_ID*.$FEXT ]]
                then
                   FFM=`echo "$FF" | sed 's/^\.\///'`
                   FFFM=$DIRP/$ICP/trunk/images/$FFM
                   # Проверяем размер прошивки
                   firmware_size=$(stat -c %s $FFFM)
                   max_allowed_size=$(get_max_allowed_size)
                   if [[ ! -z $max_allowed_size ]] && [ $firmware_size -gt $max_allowed_size ]
                   then
                      message your_firmware_exceeds_allowed_size
                      rm $FFFM
                      message your_firmware_destroyed_in_safety_precautions
                      read_n1
                   else
                      echo -e "$BLUE Firmware:$NONE$YELLOW $FFM $NONE"
                      FIRM="$BLUE Firmware:$NONE$YELLOW $FFM$NONE"
                      if [[ ! -z $max_allowed_size ]]
                      then
                         message your_firmware_fits_allowed_size
                      fi
                      #Сохраняем прошивку в архив
                      if [ ! -d $DIRP/trx_archive ]; then
                         mkdir $DIRP/trx_archive
                      fi
                      trx_date_time=$(date +%Y-%m-%d_%H:%M:%S)
                      mkdir $DIRP/trx_archive/$trx_date_time
                      cp $FFFM $DIRP/trx_archive/$trx_date_time
                      cp -f $DIRP/$ICP/trunk/.config $DIRP/trx_archive/$trx_date_time/templates.config
                      if [[ "$ICP" == *"padavan-ng"* ]]
                      then
                         cp -f $DIRP/$ICP/trunk/configs/boards/$CONFIG_VENDOR/$CONFIG_FIRMWARE_PRODUCT_ID/board.h $DIRP/trx_archive/$trx_date_time/board.h
                      else
                         cp -f $DIRP/$ICP/trunk/configs/boards/$CONFIG_FIRMWARE_PRODUCT_ID/board.h $DIRP/trx_archive/$trx_date_time/board.h
                      fi
                      sleep 1
                      cd $DIRP
                      read_n1
                      return
                   fi
                fi
             fi
             CLEOFF
             cd $DIRP
             if [ "$LOGOFF" != 1 ]; then
                echo -e "$GREEN/------------------------------------------------------------------------------/$NONE";
                grep -iE "(ошибка)|(останов)|(\smissing\s)|(failed$)|(error ([0-9])+$)|(not found$)|(aborted\!)|(stop\.$)" $DIRP/logs/build_firmware_$ICP.log | awk '!a[$0]++'
                echo -e "$GREEN/------------------------------------------------------------------------------/$NONE";
             fi
             echo -e "$BLUE Firmware:$NONE$RED ERROR $NONE"
             FIRM="$BLUE Firmware:$NONE$RED ERROR$NONE"
             message looks_like_error_happened_in_middle_of_compilation
             if [ "$LOGOFF" != 1 ]; then
                message dont_ask_questions_without_logs
             fi
             read_n1
                echo -e "$RED"
                while true; do
                   read -p "`message do_you_want_restore_sources`" yn
                   case $yn in
                      [Yy]* ) message resetting_sources_to_initial_state; cd $DIRP/$ICP; git reset --hard; cd $DIRP; exec ./start.sh;;
                      [Nn]* ) echo -e "$NONE"; break;;
                          * ) message enter_yes_no;;
                   esac
                done
          fi
          cd $DIRP
}
function p-firmware-d() {
          if [[ $FFM != *$CONFIG_FIRMWARE_PRODUCT_ID*.$FEXT ]]
          then
             if [ -d $DIRP/trx_archive ]
             then
                # Проверяем наличие прошивок в архиве
                cd $DIRP/trx_archive
                archive_trx=$(find . -type f -iname "$CONFIG_FIRMWARE_PRODUCT_ID$NP*.$FEXT" -exec ls -1tr {} +)
                if [[ ! -z $archive_trx ]]
                then
                   while true; do
                      CLEOFF
                      I=1
                      while read -r line
                      do
                         echo -e "$BLUE $I) $GREEN $line $NONE"
                         ARCHIVE["$I"]=$line
                         I=$(($I + 1))
                      done <<<"$archive_trx"
                      message cancel_archive_backup
                      echo -e "$RED"
                      read -p "`message_n select_build_that_you_want_to_flash`" yn
                      if [[ $yn == "Q" ]]
                         then
                            message canceling
                            return
                      elif [[ -z ${ARCHIVE[$yn]} ]]
                      then
                         message enter_existing_file
                         sleep 2
                      else
                         FFM=`echo "${ARCHIVE[$yn]}" | sed 's/.*\///'`
                         FFMM=`echo "${ARCHIVE[$yn]}" | sed 's/^\.\///'`
                         FFFM=$DIRP/trx_archive/$FFMM
                         break
                      fi
                   done
                fi
             fi
          fi
          if [[ $FFM != *$CONFIG_FIRMWARE_PRODUCT_ID$NP*.$FEXT ]] || [ ! -f $FFFM ] || [[ "$(stat -c %s $FFFM)" == "0" ]]
          then
             message you_dont_have_firmware
             sleep 5
             return
          fi
             connect
             if [ $SSH -eq 0 ] && [ $TELNET -eq 0 ]
             then
                return
             fi

             mtd_backup

             firmware_size=$(stat -c %s $FFFM)
             local_md5=$(md5sum $FFFM | sed 's/ .*//')
             if [ -f MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/mtd6.bin ]
             then
                remote_md5=$(dd if=./MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID/$SNAPSHOT/mtd6.bin bs=1 count=$firmware_size 2>/dev/null | md5sum | sed 's/ .*//')
                if [ "$local_md5" == "$remote_md5" ]
                then
                   message router_flashed_with_exactly_same_build
                   while true; do
                       read -p "`message_n do_you_want_flash_anyway`" yn
                       case $yn in
                           [Yy]* ) force_flashing=1 ; break;;
                           [Nn]* ) force_flashing=0 ; break;;
                           * ) message please_enter_yes_or_no;;
                       esac
                   done
                   echo -e " $NONE"
                else
                   force_flashing=1
                fi
             else
                force_flashing=1
             fi

             router_id

             if [ $force_flashing == 1 ]
             then
                if [ $SSH -eq 0 ] && [ $TELNET -eq 1 ]
                then
                   if [ $firmware_size -gt 7798784 ]
                   then
                      mtd_max_size="7798784"
                      message firmware_size_cant_exceed_n_bytes
                      sleep 3
                      return
                   fi
                   HOSTIP=$(ip route show | grep -oE "src ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+){1}" | awk '{print $NF; exit}')
                   message starting_tftp_server_enter_password
                   message from_your_linux_account
                   FFFMDIR=$(dirname "$FFFM")
                   sudo sed -i "s|TFTP_DIRECTORY=.*|TFTP_DIRECTORY=\"$FFFMDIR\"|" /etc/default/tftpd-hpa
                   sudo sed -i "s|TFTP_OPTIONS=.*|TFTP_OPTIONS=\"--secure -c\"|" /etc/default/tftpd-hpa
                   sudo /etc/init.d/tftpd-hpa restart
{
/usr/bin/expect - << EndMark_download
set timeout 10
spawn telnet $IPWRT
expect "login:"
send "$ROOTWRT\r"
expect "assword:"
send "$PWDR\r"
expect "#"
sleep 2
send "cd /tmp\r"
expect "#"
set timeout 120
send "tftp -g -r $FFM $HOSTIP 69\r"
expect "#"
set timeout 10
send "ls -1l | grep $FFM\r"
expect "#"
send "logout\r"
EndMark_download
} 2>&1 | tee /tmp/telnet_firmware.txt
                   telnet_firmware_size=$(grep -oE "[-dlrwx]+[ ]+[0-9]+[ ]+([0-9]+){1}.*$FFM" /tmp/telnet_firmware.txt | awk '{print $3}')
                   rm /tmp/telnet_firmware.txt
		   #echo "1=$telnet_firmware_size 2=$firmware_size"
                   if [[ "$telnet_firmware_size" == "$firmware_size" ]]
                   then
                      message firmware_uploaded_into_router_do_flashing
                      message router_will_be_available_on_next_address_dont_forget_turn_on_ssh
{
/usr/bin/expect - << EndMark_flash
set timeout 10
spawn telnet $IPWRT
expect "login:"
send "$ROOTWRT\r"
expect "assword:"
send "$PWDR\r"
expect "#"
sleep 2
send "cd /tmp\r"
expect "#"
send "mtd_write unlock mtd3\r"
expect "#"
set timeout 30
set timeout 180
send "mtd_write -e mtd3 write $FFM mtd3\r"
expect "#"
send "logout\r"
EndMark_flash
} 2>&1 | tee /tmp/telnet_flash.txt
                      message flashing_completed
                      while true; do
                      read -p "`message_n do_you_want_reboot_router`" yn
                      case $yn in
                          [Yy]* )
/usr/bin/expect - << EndMark_reboot
set timeout 10
spawn telnet $IPWRT
expect "login:"
send "$ROOTWRT\r"
expect "assword:"
send "$PWDR\r"
expect "#"
sleep 2
send "/sbin/reboot\r"
expect "#"
send "logout\r"
EndMark_reboot

                                  message rebooting_router_wait_20_seconds
                                  sleep 20; break ;;
                          [Nn]* ) break ;;
                          * ) message please_enter_yes_or_no;;
                      esac
                      done
                   else
                      message error_occured_during_firmware_uploading
                   fi
                   sleep 3
                   return
                else
                   # принудительно прошиваем убут для ми3
                   if [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
                   then
                      # Получаем раздел где лежит Bootloader
                      bootloader_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd' | grep Bootloader | egrep "^mtd([0-9])+" -o)
                      sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "cat /dev/$bootloader_mtd" < /dev/null > bootloader.bin
                      if [ -s bootloader.bin ]
                      then
                         remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/$bootloader_mtd" < /dev/null | sed 's/ .*//')
                         local_md5=$(md5sum bootloader.bin | sed 's/ .*//')
                         if [ "$remote_md5" != "$local_md5" ]
                         then
                            echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                            rm bootloader.bin
                            sleep 5
                            return
                         else
                            echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
                         fi
                      else
                         message file_doesnt_exist_or_empty
                         rm bootloader.bin
                         sleep 5
                         return
                      fi
                      message preparing_uboot
                      uboot_old_version=$(cat ./bootloader.bin | tr "\0" "\n" | egrep --text -o "^(U-Boot ([0-9]{1}\.[0-9]{1}\.[0-9]{1}){1} .*|([0-9]{1}\.[0-9]{1}\.[0-9]{1}\.[0-9]{1}){1})$")
                      message current_bootloader_version_is_abc
                      ROUTERU="xiaomi_mi-3"
                      if [ -s $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.bin ] && [ -s $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.md5 ]
                      then
                         uboot_new_version=$(cat $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.bin | tr "\0" "\n" | egrep --text -o "(U-Boot ([0-9]{1}\.[0-9]{1}\.[0-9]{1}){1} .*|([0-9]{1}\.[0-9]{1}\.[0-9]{1}\.[0-9]{1}){1})$")
                         local_md5=$(cat $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.md5 | sed 's/ .*//')
                         bootloader_size=$(stat -c %s $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.bin)
                         remote_md5=$(dd if=./bootloader.bin bs=1 count=$bootloader_size 2>/dev/null | md5sum | sed 's/ .*//')
                         if [ "$uboot_new_version" != "$uboot_old_version" ] || [ "$remote_md5" != "$local_md5" ]
                         then
                            message newer_bootloader_with_version_abc_has_been_found
                            # Загружаем загрузчик в роутер
                            message uploading_uboot
                            sshpass -p "$PWDR" scp -P $ssh_port -o StrictHostKeyChecking=no $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.bin $ROOTWRT@$IPWRT:/tmp/
                            # Проверяем md5
                            message checking_checksum
                            remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/uboot.bin" < /dev/null | sed 's/ .*//')
                            if [ "$remote_md5" != "$local_md5" ]
                            then
                               echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                            else
                               echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
                               # Прошиваем
                               message flashing_firmware
                               proc_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'type mtd')
                               if [[ $proc_mtd == *"not found"* ]]
                               then
                                  mtd_cmd="mtd_write"
                               else
                                  mtd_cmd="mtd"
                                  sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "nvram set boot_wait=on && nvram set uart_en=1 && nvram commit"
                               fi
                               sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT  "$mtd_cmd write /tmp/uboot.bin Bootloader"
                               remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "dd if=/dev/$bootloader_mtd bs=1 count=$bootloader_size 2>/dev/null | md5sum | sed 's/ .*//'" )
                               if [ "$remote_md5" != "$local_md5" ]
                               then
                                  message dont_reboot_your_router_until_bootloader_will_be_flashed_successfully
                                  read_n1
                                  return
                               else
                                  echo -e "$GREEN OK $NONE"
                                  message router_has_been_flashed_successfully
                                  #sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT /sbin/reboot
                                  #message rebooting_router_wait_50_seconds
                                  #sleep 70
                               fi
                            fi
                         else
                            message your_uboot_has_actual_version
                         fi
                      else
                         message uboot_isnt_found
                      fi
                   fi


                   # прошиваем прошивку
                   message detecting_partition
                   proc_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd | grep -oEm1 "(firmware|Firmware_Stub|OS1|kernel1)"')
                   if [[ -z "$proc_mtd" ]]
                   then
                      proc_mtd_s=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "cat /proc/mtd | cat /proc/mtd | sed '1d' | sed 's/.* \"//' | sed 's/\"//'")
                      while true; do
                         CLEOFF
                         message available_mtd
                         echo -e "$NONE-------------------------------------------------------------------------------"
                         I=1
                         while read -r line
                         do
                            echo -e "$BLUE $I) $GREEN `echo $line` $NONE"
                            MTDS["$I"]=$line
                            I=$(($I + 1))
                         done <<<"$proc_mtd_s"
                         message go_backward_key
                         echo -e "$NONE-------------------------------------------------------------------------------$RED"
                         read -p "`message_n select_mtd`" yn
                         if [[ $yn == "Q" ]]
                         then
                            message canceling
                            break
                         elif [[ -z ${MTDS[$yn]} ]]
                         then
                            message select_existed_config
                            sleep 1
                         else
                            message mtd_has_been_selected
                            proc_mtd=`echo "${MTDS[$yn]}"`
                            read_n1
                            CLEOFF
                            break
                         fi
                      done
                   fi
                   if [ "$CLEOFF" == 1 ]; then
                      echo "mtd: $proc_mtd"
                   fi

                   proc_mtd_row=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "cat /proc/mtd | grep -oEm1 '^mtd([0-9]+): ([[:xdigit:]]+) ([[:xdigit:]]+) \"$proc_mtd\"$'")
                   mtd_max_size=$((16#$(echo $proc_mtd_row | cut -d' ' -f2)))
                   block_erase_size=$((16#$(echo $proc_mtd_row | cut -d' ' -f3)))
                   mtd_number=$(echo $proc_mtd_row | cut -d':' -f1)
                   if [ "$CLEOFF" == 1 ]; then
                      echo "mtd_max_size:$mtd_max_size block_erase_size:$block_erase_size firmware_size:$firmware_size"
                   fi
                   remote_md5_script="cat /dev/$mtd_number 2>&-"
                   if [[ $proc_mtd == "Firmware_Stub" ]]
                   then
                      export_script="cd /tmp; mtd_write write $FFM $proc_mtd; rm $FFM;"
                   elif [[ $proc_mtd == "firmware" ]] || [[ $proc_mtd == "OS1" ]]
                   then
                      export_script="cd /tmp; mtd write $FFM $proc_mtd; rm $FMM;"
                   elif [[ $proc_mtd == "kernel1" ]] && [[ "$ROUTERY" != *"mi-3"* && "$ROUTERY" != *"mi-r3g"* ]]
                   then
                      message incorrect_configuration
                      read_n1
                      break
                   elif [[ $proc_mtd == "kernel1" ]] && [[ "$ROUTERY" == *"mi-3"* || "$ROUTERY" == *"mi-r3g"* ]] && [[ "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
                   then
                      bad_sectors=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'dmesg | grep -oE "nand_block_checkbad: offs:[[:xdigit:]]+ tag: BAD" | sed -r "s/nand_block_checkbad: offs:([[:xdigit:]]+) tag: BAD/\1/" | sort -ru')
                      if [[ ! -z $bad_sectors ]]
                      then
                          dmesg_row=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'dmesg | grep -oE "(0x[[:xdigit:]].+-0x[[:xdigit:]].+){1} : \"kernel1\""')
                          if [ "$CLEOFF" == 1 ]; then
                             echo $dmesg_row
                          fi
                          kernel1_start=$((16#$(echo $dmesg_row | cut -d'-' -f1 | cut -d'x' -f2)))
                          kernel1_end=$((16#$(echo $dmesg_row | cut -d'-' -f2 | cut -d' ' -f1 | cut -d'x' -f2)))
                          if [ "$CLEOFF" == 1 ]; then
                             echo "kernel1 start:$kernel1_start end:$kernel1_end"
                          fi
                          dmesg_row=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'dmesg | grep -oE "(0x[[:xdigit:]].+-0x[[:xdigit:]].+){1} : \"rootfs0\""')
                          if [ "$CLEOFF" == 1 ]; then
                             echo $dmesg_row
                          fi
                          rootfs0_start=$((16#$(echo $dmesg_row | cut -d'-' -f1 | cut -d'x' -f2)))
                          rootfs0_end=$((16#$(echo $dmesg_row | cut -d'-' -f2 | cut -d' ' -f1 | cut -d'x' -f2)))
                          if [ "$CLEOFF" == 1 ]; then
                             echo "rootfs0 start:$rootfs0_start end:$rootfs0_end"
                          fi
                          rootfs0_first_bad=$rootfs0_end
                          while read -r bad_sector_row
                          do
                              bad_sector=$((16#$bad_sector_row))
                              if [ "$bad_sector" -ge "$kernel1_start" ] && [ "$bad_sector" -lt "$kernel1_end" ]
                              then
                                  echo "BAD inside kernel1 area $bad_sector_row"
                                  mtd_max_size=$(($mtd_max_size-$block_erase_size))
                              elif [ "$bad_sector" -ge "$rootfs0_start" ] && [ "$bad_sector" -lt "$rootfs0_end" ]
                              then
                                  echo "BAD inside rootfs0 area $bad_sector_row"
                                  if [ "$bad_sector" -lt "$rootfs0_first_bad" ]
                                  then
                                      rootfs0_first_bad=$bad_sector
                                  fi
                              fi
                          done <<<"$bad_sectors"
                      fi
                      if [ $firmware_size -gt $mtd_max_size ]
                      then
                         export_script="cd /tmp; dd if=$FFM bs=$mtd_max_size count=1 2>/dev/null | dd of=$FFM.part0 2>/dev/null; mtd write $FFM.part0 $proc_mtd; rm $FFM.part0; dd if=$FFM bs=$mtd_max_size skip=1 2> /dev/null | dd of=$FFM.part1 2> /dev/null; mtd write $FFM.part1 rootfs0; rm $FFM.part1; nvram set flag_last_success=1 && nvram commit; rm $FFM;"
                         remote_md5_script="cat /dev/mtd9 /dev/mtd10 2>&-"
                      else
                         export_script="cd /tmp; mtd write $FFM $proc_mtd; nvram set flag_last_success=1 && nvram commit;"
                      fi
                   else
                      export_script="cd /tmp; mtd write $FFM $proc_mtd; mtd_write write $FFM $proc_mtd; rm $FMM;"
                   fi

                   if [ $firmware_size -gt $mtd_max_size ] && [[ $proc_mtd != "kernel1" ]]
                   then
                      message firmware_size_cant_exceed_n_bytes
                      sleep 3
                      return
                   elif [[ $proc_mtd == "kernel1" ]] && [[ "$rootfs0_first_bad" != "$rootfs0_end" ]]
                   then
                       if [ $firmware_size -gt $(($mtd_max_size+$(($rootfs0_first_bad-$rootfs0_start)))) ]
                       then
                           mtd_max_size=$(($mtd_max_size+$(($rootfs0_first_bad-$rootfs0_start))))
                           message firmware_size_cant_exceed_n_bytes
                           sleep 3
                           return
                       fi
                   fi
                   message uploading_firmware
                   sshpass -p "$PWDR" scp -P $ssh_port -o StrictHostKeyChecking=no $FFFM $ROOTWRT@$IPWRT:/tmp/

                   # Проверяем md5
                   message checking_checksum
                   local_md5=$(md5sum $FFFM | sed 's/ .*//')
                   remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/$FFM" < /dev/null | sed 's/ .*//')
                   if [ "$remote_md5" != "$local_md5" ]
                   then
                      echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                      message script_is_stopping_because_of_possibility_router_brick
                      exit
                   else
                      echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
                   fi

                   # Прошиваем
                   message flashing_firmware
                   message router_will_be_available_on_next_address_dont_forget_turn_on_ssh
                   if [ "$CLEOFF" == 1 ]; then
                      echo "export_script='$export_script'"
                   fi
                   sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT $export_script
                   sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "$remote_md5_script" > check.bin
                   remote_md5=$(dd if=check.bin bs=$firmware_size count=1 2>&- | md5sum | sed 's/ .*//')
                   rm check.bin
                   if [ "$remote_md5" != "$local_md5" ]
                   then
                      echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                      message script_is_stopping_because_of_possibility_router_brick
                      if [[ $proc_mtd == "kernel1" ]]
                      then
                         if [ "$FORCED" != 1 ]; then
                            message error_firmware_1
                            sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "nvram set flag_last_success=0; nvram set flag_try_sys1_failed=1; nvram set flag_try_sys2_failed=1; nvram commit"
                         else
                            message error_firmware_1
                            echo -e "$GREEN FORCED $NONE"
                         fi
                      fi
                      exit
                   fi
                   echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
                   message router_has_been_flashed_successfully
                   while true; do
                       read -p "`message_n do_you_want_reboot_router`" yn
                       case $yn in
                           [Yy]* ) sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT /sbin/reboot
                                   message rebooting_router_wait_20_seconds
                                   sleep 20; break ;;
                           [Nn]* ) break ;;
                           * ) message please_enter_yes_or_no;;
                       esac
                   done
                   echo -e " $NONE"
                   sleep 3
                fi
             else
                message action_has_been_canceled
                sleep 3
             fi
          cd $DIRP
}
function p-firmware-m() {
#---------------------------------------------------------------
# Подменю начало
#---------------------------------------------------------------
while :
do
CLEOFF
message prometheus_header
sleep 1
if [[ "$ROUTERY" == *"mi-3"* || "$ROUTERY" == *"mi-r3g"* ]] && [[ "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
then
# MI-3 MENU
    message firmware_screen_menu_mi_3
else
    message firmware_screen_menu_other_routers
fi
    read -n1 -s
    case "$REPLY" in
    "1")  p-config ;;
    "2")  CLEOFF
          p-skins ;;
    "3")  CLEOFF
          p-build ;;
    "4")  find-firmware
          p-firmware-d
          cd $DIRP; break;;
    "5")  FFM=NONE
          p-firmware-d
          cd $DIRP ;;
    "6")  rm -rf $DIRP/trx_archive/* >/dev/null 2>&1
          message something_has_been_deleted
          cd $DIRP ;;
    "7")  if [[ "$ROUTERY" == *"mi-3"* || "$ROUTERY" == *"mi-r3g"* ]] && [[ "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
          then
             connect
             if [[ "Entware not mounted" = $(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'mountpoint -q /opt && echo "Entware already mounted" || echo "Entware not mounted"') ]]
             then
                 rwfs_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd' | grep RWFS | egrep "^mtd([0-9])+" -o)
                 #sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "/usr/bin/opt-umount.sh"
                 #sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "umount /opt"
                 #sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "umount /media/entware"
                 #sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "/sbin/ubidetach -p /dev/$rwfs_mtd"
                 sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "/sbin/ubiformat /dev/$rwfs_mtd"
                 sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "/sbin/ubiattach -p /dev/$rwfs_mtd"
                 sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "/sbin/ubimkvol /dev/ubi0 -m -N user"
                 sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "mkdir /media/entware"
                 sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "mount -t ubifs ubi0_0 /media/entware"
                 sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "mkdir /media/entware/opt"
                 sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "opt-mount.sh /dev/ubi0_0 /media/entware"
                 sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "opkg.sh"
                 if [[ -z $(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "cat /etc/storage/started_script.sh | grep -o 'ubiattach -p /dev/$rwfs_mtd'") ]]
                 then
                     sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "echo -e \"\n\n\n### Added by Prometheus ### \n\nubiattach -p /dev/$rwfs_mtd\nmkdir /media/entware\nmount -t ubifs ubi0_0 /media/entware\nopt-mount.sh /dev/ubi0_0 /media/entware\nopkg.sh\" >> /etc/storage/started_script.sh"
                 fi
             else
                 message entware_mounted
             fi
             read_n1
             sleep 0.3
          else
             message command_not_found
             sleep 0.3
          fi ;;
    "F")  message in_every_unknown_situation_press_1
          read_n1 ;;
    "f")  message in_capital_letters_please
          sleep 0.5 ;;
    "Q")  break ;;
    "q")  message in_capital_letters_please
          sleep 0.3 ;;
     * )  message command_not_found
          sleep 0.3 ;;
    esac
done
#---------------------------------------------------------------
# Подменю Конец
#---------------------------------------------------------------
}
function p-eeprom() {
          cd $DIRP
          connect
          mtd_backup
          if [ $SSH -eq 0 ] && [ $TELNET -eq 0 ]
          then
             return
          fi

          if [ $EE -gt 0 ]
          then
             # Получаем раздел где лежит Factory
             message checking_eeprom
             factory_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd' | grep Factory | egrep "^mtd([0-9])+" -o)
             sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "cat /dev/$factory_mtd" < /dev/null > factory.bin
             if [ -s factory.bin ]
             then
                remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/$factory_mtd" < /dev/null | sed 's/ .*//')
                local_md5=$(md5sum factory.bin | sed 's/ .*//')
                if [ "$remote_md5" != "$local_md5" ]
                then
                   echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                   rm factory.bin
                   sleep 5
                   return
                else
                   echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
                fi
             else
                message file_doesnt_exist_or_empty
                rm factory.bin
                sleep 5
                return
             fi

             byte8045=$(xxd -s 0x8045 -l 1 -ps factory.bin)
             byte8049=$(xxd -s 0x8049 -l 1 -ps factory.bin)
             byte804D=$(xxd -s 0x804D -l 1 -ps factory.bin)
             if [ "$byte8045" != "00" ] || [ "$byte8049" != "00" ] || [ "$byte804D" != "00" ]
             then
                message stock_eeprom_has_been_found_its_recommended_apply_patch
                # Тут диалог или автоматизация если тихая установка
                echo -e "`message_n do_you_want_to_do_it_now`"
                while true; do
                    read -p "`message_n do_you_want_to_flash_eeprom`" yn
                    case $yn in
                        [Yy]* ) EE1=1 ; break;;
                        [Nn]* ) EE1=0 ; break;;
                        * ) message enter_yes_no;;
                    esac
                done
                echo -e " $NONE"
                if [ $EE1 -gt 0 ]
                then
                   printf '\x00' | dd conv=notrunc of=factory.bin bs=1 seek=$((0x8045))
                   printf '\x00' | dd conv=notrunc of=factory.bin bs=1 seek=$((0x8049))
                   printf '\x00' | dd conv=notrunc of=factory.bin bs=1 seek=$((0x804D))
                   # Загружаем EEPROM в роутер
                   message uploading_eeprom
                   sshpass -p "$PWDR" scp -P $ssh_port -o StrictHostKeyChecking=no factory.bin $ROOTWRT@$IPWRT:/tmp/
                   # Проверяем md5
                   message checking_checksum
                   remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/factory.bin" < /dev/null | sed 's/ .*//')
                   local_md5=$(md5sum factory.bin | sed 's/ .*//')
                   if [ "$remote_md5" != "$local_md5" ]
                   then
                      echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                      rm factory.bin
                      sleep 5
                      return
                   else
                      echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
                      # Прошиваем
                      message flashing_firmware
                      proc_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'type mtd')
                      if [[ $proc_mtd == *"not found"* ]]
                      then
                         mtd_cmd="mtd_write"
                      else
                         mtd_cmd="mtd"
                      fi
                      sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT  "$mtd_cmd write /tmp/factory.bin Factory"
                      echo -e "$BLUE EEPROM,$NONE$GREEN OK $NONE"
                      EE=0
                      rm factory.bin
                      echo -e " $RED"
                      while true; do
                          read -p "`message_n do_you_want_reboot_router`" yn
                          case $yn in
                              [Yy]* ) sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT /sbin/reboot
                                      message rebooting_router_wait_20_seconds
                                      sleep 20; break ;;
                              [Nn]* ) break ;;
                              * ) message please_enter_yes_or_no;;
                          esac
                      done
                      echo -e " $NONE"
                   fi
                else
                   message keeping_eeprom_in_its_original_state
                fi
             else
                message eeprom_already_has_been_patched_there_is_no_need_to_do_it_again
             fi
          else
             message eeprom_already_has_been_patched_there_is_no_need_to_do_it_again
          fi
          cd $DIRP
          rm factory.bin >/dev/null 2>&1
}
function p-uboot() {
force=$1
#---------------------------------------------------------------
# Подменю начало
#---------------------------------------------------------------
uboot_patch
while :
do
CLEOFF
if [ "$erorubootconfig" == 1 ]; then
   break
fi
message prometheus_header
sleep 0.5
if [[ "$ROUTERY" == *"mi-mini"* ]]
then
    message uboot_screen_menu_mi_mini
elif [[ "$ROUTERY" == *"mi-3"* ]] && [[ "$ROUTERY" != *"mi-3c"* ]] && [[ "$ROUTERY" != *"mi-3_spi"* ]] && [[ "$ROUTERY" != *"mi-3g"* ]]
then
    message uboot_screen_menu_mi_3
else
    message uboot_screen_menu_other_routers
fi
    if [[ $force == "1" ]]
    then
       REPLY="1"
    else
       read -n1 -s
    fi
    case "$REPLY" in
    "1")  CLEOFF
          connect
          if [ $SSH -eq 0 ] && [ $TELNET -eq 0 ]
          then
             return
          fi
          if [ $SSH -eq 0 ] && [ $TELNET -eq 1 ]
          then
             uboot_size=$(stat -c %s "$DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.bin")
             HOSTIP=$(ip route show | grep -oE "src ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+){1}" | awk '{print $NF; exit}')
             message starting_tftp_server_enter_password
             message from_your_linux_account
             sudo sed -i "s|TFTP_DIRECTORY=.*|TFTP_DIRECTORY=\"$DIRP/$ICP/uboot/mips/profiles/$ROUTERU\"|" /etc/default/tftpd-hpa
             sudo sed -i "s|TFTP_OPTIONS=.*|TFTP_OPTIONS=\"--secure -c\"|" /etc/default/tftpd-hpa
             sudo /etc/init.d/tftpd-hpa restart
{
/usr/bin/expect - << EndMark_download
set timeout 10
spawn telnet $IPWRT
expect "login:"
send "$ROOTWRT\r"
expect "assword:"
send "$PWDR\r"
expect "#"
sleep 2
send "cd /tmp\r"
expect "#"
set timeout 120
send "tftp -g -r uboot.bin $HOSTIP 69\r"
expect "#"
set timeout 10
send "ls -1l | grep uboot.bin\r"
expect "#"
send "logout\r"
EndMark_download
} 2>&1 | tee /tmp/telnet_uboot.txt

             telnet_uboot_size=$(grep -oE "[-dlrwx]+[ ]+[0-9]+[ ]+([0-9]+){1}.*uboot.bin" /tmp/telnet_uboot.txt | awk '{print $3}')
             rm /tmp/telnet_uboot.txt
             #echo "1=$telnet_uboot_size 2=$uboot_size"
             if [[ "$telnet_uboot_size" == "$uboot_size" ]]
             then
                 message uboot_has_been_uploaded_to_the_router
                 while true; do
                    read -p "`message_n do_you_want_to_flash_uboot`" yn
                    case $yn in
                        [Yy]* ) break;;
                        [Nn]* ) return;;
                        * ) message enter_yes_no;;
                    esac
                 done

                 message flashing_firmware
{
/usr/bin/expect - << EndMark_flash
set timeout 10
spawn telnet $IPWRT
expect "login:"
send "$ROOTWRT\r"
expect "assword:"
send "$PWDR\r"
expect "#"
sleep 2
send "cd /tmp\r"
expect "#"
send "mtd_write unlock mtd0\r"
expect "#"
set timeout 180
send "mtd_write write uboot.bin mtd0\r"
expect "#"
send "logout\r"
EndMark_flash
} 2>&1 | tee /tmp/telnet_flash.txt
                   message flashing_completed
                   while true; do
                   read -p "`message_n do_you_want_reboot_router`" yn
                   case $yn in
                       [Yy]* )
/usr/bin/expect - << EndMark_reboot
set timeout 10
spawn telnet $IPWRT
expect "login:"
send "$ROOTWRT\r"
expect "assword:"
send "$PWDR\r"
expect "#"
sleep 2
send "/sbin/reboot\r"
expect "#"
send "logout\r"
EndMark_reboot

                               message rebooting_router_wait_20_seconds
                               sleep 20; break ;;
                       [Nn]* ) break ;;
                       * ) message please_enter_yes_or_no;;
                   esac
                   done

             else
                message error_occured_during_firmware_uploading
             fi
             sleep 3
             return

          else
             router_id
             if [[ -n $force_flashing && $force_flashing -eq 0 ]]
             then
                message action_has_been_canceled
                sleep 3
                return
             fi
             mtd_backup
             # Получаем раздел где лежит Bootloader
             bootloader_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd' | grep Bootloader | egrep "^mtd([0-9])+" -o)
             sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "cat /dev/$bootloader_mtd" < /dev/null > bootloader.bin
             if [ -s bootloader.bin ]
             then
                remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/$bootloader_mtd" < /dev/null | sed 's/ .*//')
                local_md5=$(md5sum bootloader.bin | sed 's/ .*//')
                if [ "$remote_md5" != "$local_md5" ]
                then
                   echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                   rm bootloader.bin
                   sleep 5
                   return
                else
                   echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
                fi
             else
                message file_doesnt_exist_or_empty
                rm bootloader.bin
                sleep 5
                return
             fi
             message preparing_uboot
             uboot_old_version=$(cat ./bootloader.bin | tr "\0" "\n" | egrep --text -o "(U-Boot ([0-9]{1}\.[0-9]{1}\.[0-9]{1}){1} .*|([0-9]{1}\.[0-9]{1}\.[0-9]{1}\.[0-9]{1}){1})$")
             message current_bootloader_version_is_abc
             if [ -s $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.bin ] && [ -s $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.md5 ]
             then
                uboot_new_version=$(cat $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.bin | tr "\0" "\n" | egrep --text -o "(U-Boot ([0-9]{1}\.[0-9]{1}\.[0-9]{1}){1} .*|([0-9]{1}\.[0-9]{1}\.[0-9]{1}\.[0-9]{1}){1})$")
                local_md5=$(cat $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.md5 | sed 's/ .*//')
                bootloader_size=$(stat -c %s $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.bin)
                remote_md5=$(dd if=./bootloader.bin bs=1 count=$bootloader_size 2>/dev/null | md5sum | sed 's/ .*//')
                if [ "$uboot_new_version" != "$uboot_old_version" ] || [ "$remote_md5" != "$local_md5" ]
                then
                   message newer_bootloader_with_version_abc_has_been_found
                   # Тут диалог да/нет или автоматизация
                   while true; do
                       read -p "`message_n do_you_want_to_flash_uboot`" yn
                       case $yn in
                           [Yy]* ) UBT=1 ; break;;
                           [Nn]* ) UBT=0 ; break;;
                           * ) message enter_yes_no;;
                       esac
                   done
                   echo -e " $NONE"
                   if [ $UBT -gt 0 ]
                   then
                      # Загружаем загрузчик в роутер
                      message uploading_uboot
                      sshpass -p "$PWDR" scp -P $ssh_port -o StrictHostKeyChecking=no $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/uboot.bin $ROOTWRT@$IPWRT:/tmp/
                      # Проверяем md5
                      message checking_checksum
                      remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/uboot.bin" < /dev/null | sed 's/ .*//')
                      if [ "$remote_md5" != "$local_md5" ]
                      then
                         echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                      else
                         echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
                         # Прошиваем
                         message flashing_firmware
                         proc_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'type mtd')
                         if [[ $proc_mtd == *"not found"* ]]
                         then
                            mtd_cmd="mtd_write"
                          else
                            mtd_cmd="mtd"
                         fi
                         sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT  "$mtd_cmd write /tmp/uboot.bin Bootloader"
                         remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "dd if=/dev/$bootloader_mtd bs=1 count=$bootloader_size 2>/dev/null | md5sum | sed 's/ .*//'" )
                         if [ "$remote_md5" != "$local_md5" ]
                         then
                            message dont_reboot_your_router_until_bootloader_will_be_flashed_successfully
                            read_n1
                         else
                            echo -e "$GREEN OK $NONE"
                            message router_has_been_flashed_successfully
                            message dont_reboot_your_router_if_you_have_stock_firmware
                            while true; do
                                read -p "`message_n do_you_want_reboot_router`" yn
                                case $yn in
                                    [Yy]* ) sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT /sbin/reboot
                                            message rebooting_router_wait_20_seconds
                                            sleep 20; break ;;
                                    [Nn]* ) break ;;
                                    * ) message please_enter_yes_or_no;;
                                esac
                            done
                            echo -e " $NONE"
                         fi
                      fi
                   else
                      message update_canceled
                   fi
                else
                   message your_uboot_has_actual_version
                fi
             else
                message uboot_isnt_found
             fi
          fi
          cd $DIRP
          sleep 2 ;;
    "2")  CLEOFF
          if [[ "$ROUTERY" != *"mi-3"* ]]
	  then
              build-ubut
          elif [[ "$ROUTERY" = *"mi-3c"* ]]
	  then
              build-ubut
          fi
          sleep 2 ;;
    "3")  CLEOFF
          if [[ "$ROUTERY" == *"mi-mini"* ]]
          then
             connect
             if [ $SSH -eq 0 ] && [ $TELNET -eq 0 ]
             then
                return
             fi

             # Получаем раздел где лежит Bootloader
             bootloader_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd' | grep Bootloader | egrep "^mtd([0-9])+" -o)
             if [ -s $DIRP/$DIRF/stock_uboot.bin ] && [ -s $DIRP/$DIRF/stock_uboot.md5 ]
             then
                local_md5=$(md5sum $DIRP/$DIRF/stock_uboot.bin | sed 's/ .*//')
                remote_md5=$(cat $DIRP/$DIRF/stock_uboot.md5 | sed 's/ .*//')
                if [ "$local_md5" == "$remote_md5" ]
                then
                   while true; do
                       read -p "`message_n do_you_want_to_flash_stock_uboot`" yn
                       case $yn in
                           [Yy]* ) UBT=1 ; break;;
                           [Nn]* ) UBT=0 ; break;;
                           * ) message enter_yes_no;;
                       esac
                   done
                   echo -e " $NONE"
                   if [ $UBT -gt 0 ]
                   then
                      # Загружаем загрузчик в роутер
                      message uploading_uboot
                      sshpass -p "$PWDR" scp -P $ssh_port -o StrictHostKeyChecking=no $DIRP/$DIRF/stock_uboot.bin $ROOTWRT@$IPWRT:/tmp/
                      # Проверяем md5
                      message checking_checksum
                      remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/stock_uboot.bin" < /dev/null | sed 's/ .*//')
                   if [ "$remote_md5" != "$local_md5" ]
                   then
                      echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
                      message action_has_been_canceled_because_of_copy_error
                   else
                      echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
                      # Прошиваем
                      message flashing_firmware
                      proc_mtd=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT 'type mtd')
                      if [[ $proc_mtd == *"not found"* ]]
                      then
                         mtd_cmd="mtd_write"
                      else
                         mtd_cmd="mtd"
                      fi
                      sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT  "$mtd_cmd write /tmp/stock_uboot.bin Bootloader"
                      remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/$bootloader_mtd" < /dev/null | sed 's/ .*//')
                         if [ "$remote_md5" != "$local_md5" ]
                         then
                            message dont_reboot_your_router_until_bootloader_will_be_flashed_successfully
                         else
                            echo -e "$GREEN OK $NONE"
                            message router_has_been_flashed_successfully
                            message changes_will_be_applied_after_reboot
                         fi
                      fi
                   fi
                else
                   message archive_file_is_corrupted_please_update_script
                fi
             else
                message archive_file_is_absent_please_update_script
             fi
             read_n1
          else
             message command_not_found
             sleep 0.5
          fi ;;
    "F")  message you_can_build_uboot_only_on_x86_machine
          read_n1 ;;
    "f")  message in_capital_letters_please
          sleep 0.5 ;;
    "Q")  break ;;
    "q")  message in_capital_letters_please
          sleep 0.5 ;;
     * )  message command_not_found
          sleep 0.5 ;;
    esac

    if [[ $force == "1" ]]
    then
        return
    fi
done
#---------------------------------------------------------------
# Подменю Конец
#---------------------------------------------------------------
}
function settings() {
   #---------------------------------------------------------------
   # Подменю начало
   #---------------------------------------------------------------
   while :
   do
   CLEOFF
   message prometheus_header
   sleep 1
   message settings_screen_menu
       read -n1 -s
       case "$REPLY" in
   "1")  # Смена конфига
         sed -i s/ROUTERY=.*/ROUTERY=\"\"/ $DIRP/$DIRC/script.config.sh
         message script_will_be_restarted
         sleep 2
         exec ./start.sh ;;
   "2")  CLEOFF
         # Сброс конфига
         while true; do
            read -p "`message_n you_want_to_delete_config`" yn
            case $yn in
               [Yy]* ) rm -f $DIRP/$DIRC/routers/$ROUTERS.sh >/dev/null 2>&1 ; message script_will_be_restarted ; sleep 2 ; exec ./start.sh ;;
               [Nn]* ) break;;
                   * ) message enter_yes_no;;
            esac
         done
         ;;
   "3")  CLEOFF
         # Проверяем модули
         if [ ! -d $DIRP/modules ]; then
            mkdir $DIRP/modules
         fi
         cd $DIRP/modules/
         modules_prom=$(find . -type d -name "*.mod" | sed 's/\.\///')
         cd $DIRP
         if [[ ! -z $modules_prom ]]
         then
         while true; do
            CLEOFF
            message available_modules
            echo -e "$NONE-------------------------------------------------------------------------------"
            I=1
            while read -r line
            do
               echo -e "$BLUE $I) $GREEN `echo $line | sed 's/\.mod$//'` v`sed -n '/version-mod=/{p;q;}' $DIRP/modules/$line/versions.inc | sed 's/version-mod=//'` $NONE"
               MODS["$I"]=$line
               I=$(($I + 1))
            done <<<"$modules_prom"
            message update_modules_key
            message go_backward_key
            echo -e "$NONE-------------------------------------------------------------------------------$RED"
            read -p "`message_n select_module`" yn
            if [[ $yn == "Q" ]]
            then
               message canceling
               break
            elif [[ $yn == "U" ]]
            then
            echo -e "$NONE"
            while read -r line
            do
               URLMOD=$(sed -n '/url-mod=/{p;q;}' $DIRP/modules/$line/versions.inc | sed 's/url-mod=//')
               if [[ "$URLMOD" == *"http"* ]] || [[ "$URLMOD" == *"ftp"* ]]
               then
                  message getting_update_for_selected_module
                  wget -O up.tar.gz $URLMOD
                  tar -xvf up.tar.gz
                  rm -f up.tar.gz
                  echo -e "$BLUE $line$GREEN OK $NONE"
                  sleep 1
               else
                  message selected_module_doesnt_support_updates
                  sleep 1
               fi
            done <<<"$modules_prom"
            elif [[ -z ${MODS[$yn]} ]]
            then
               message select_existed_config
               sleep 1
            else
               message module_has_been_selected
               modules=`echo "${MODS[$yn]}"`
               sleep 0.5
               ./modules/$modules/script.sh
               cd $DIRP
               sleep 1
               read_n1
               #break
            fi
         done
         else
            message modules_are_absent
            sleep 0.3
         fi ;;
   "4")  select_language_dialog ;;
   "5")  connect "no" ;;
   "6")  sed -i s^gitrepo=.*^gitrepo=^ $DIRP/$DIRC/script.config.sh
         message script_will_be_restarted
         sleep 2
         exec ./start.sh ;;
   "Q")  break ;;
   "q")  message in_capital_letters_please ;;
    * )  message command_not_found ;;
   esac
done
#---------------------------------------------------------------
# Подменю Конец
#---------------------------------------------------------------
}

function p-faq() {
          message faq_screen_menu

          if [[ "$ROUTERY" == *"mi-mini"* ]] || [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
          then
             message faq_screen_menu2
          fi
             message faq_screen_menu3
          sleep 5
}
function p-quit() {
          if [ -f $DIRP/modules/a-quit.sh ]; then
             ./modules/a-quit.sh
          fi
          message rebooting_router
          if [ $SSH -gt 0 ]
          then
             message ssh_access_established
             sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT /sbin/reboot
             echo -e "$YELLOW DONE! $NONE"
             exit
          else
             message ssh_access_not_established
             exit
          fi
}

function build-ubut() {
   digit=$(uname -m)
   if [[ "$digit" == *"x86_64"* ]] && [[ `dpkg -s ia32-libs &>/dev/null && echo 1 || echo 0` -eq 0 ]] && [[ `dpkg -s lib32z1 lib32ncurses5 &>/dev/null && echo 1 || echo 0` -eq 0 ]]
   then
      message installing_software
      message from_your_linux_account
      #sudo apt-get update
      sudo apt-get -y --force-yes install lib32z1 lib32ncurses5 || sudo apt-get -y --force-yes install ia32-libs
   fi
   declare TAR_EXT
   if [[ "$ICP" == *"padavan-ng"* ]]
   then
      TAR_EXT=tar.xz
   else
      TAR_EXT=tar.bz2
   fi
   if [ ! -d /opt/buildroot-gcc342 ] && [[ "$UBOOTMIPS" == "1" ]]; then
      sudo tar -xvf $DIRP/$ICP/uboot/mips/tools/buildroot-gcc342.$TAR_EXT -C /opt
      sudo apt-get install libncurses5 libncurses5-dev
   fi
   if [ ! -d /opt/mips-2012.03 ] && [[ "$UBOOTMIPS" == "2" ]]; then
      sudo tar -xvf $DIRP/$ICP/uboot/mips/tools/mips-2012.03.$TAR_EXT -C /opt
      sudo apt-get install libncurses5 libncurses5-dev
   fi
   cp $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/.config $DIRP/$ICP/uboot/mips/uboot-5.x.x.x/
   cd $DIRP/$ICP/uboot/mips/uboot-5.x.x.x
   make menuconfig
   make 2>&1 | tee -ia $DIRP/logs/build_uboot.log
   # Проверяем готовность прошивки
   if [ -f $DIRP/$ICP/uboot/mips/uboot-5.x.x.x/uboot.bin ]
   then
      cp $DIRP/$ICP/uboot/mips/uboot-5.x.x.x/uboot.bin $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/
      cd $DIRP/$ICP/uboot/mips/profiles/$ROUTERU/
      md5sum uboot.bin > uboot.md5
      message uboot_assembled
   else
      if [ "$LOGOFF" != 1 ]; then
         CLEOFF
         echo -e "$GREEN/------------------------------------------------------------------------------/$NONE";
         grep -iE "(ошибка)|(останов)|(\smissing\s)|(failed$)|(error ([0-9])+$)|(not found$)|(aborted\!)|(stop\.$)" $DIRP/logs/build_uboot.log | awk '!a[$0]++'
         echo -e "$GREEN/------------------------------------------------------------------------------/$NONE";
      fi
      echo -e "$BLUE U-BOOT:$NONE$RED ERROR $NONE"
      message looks_like_error_happened_in_middle_of_compilation
      if [ "$LOGOFF" != 1 ]; then
         message dont_ask_questions_without_logs
      fi
      read_n1
   fi
   cd $DIRP
}
#---------------------------------------------------------------
# Конец функций
#---------------------------------------------------------------

if [ -f $DIRP/modules/a-start.sh ]; then
   ./modules/a-start.sh
fi
#---------------------------------------------------------------
# Шапка Начало
#---------------------------------------------------------------
while :
          do
    CLEOFF
message prometheus_header
if [[ "$ROUTERY" == *"mi-mini"* ]]
then
   if [[ "$SSHT" == "SN="* ]]
   then
       message main_screen_menu_mi_mini
   else
       message main_screen_menu_ssh_mi_mini
   fi
elif [[ "$ROUTERY" == *"mi-nano"* ]]
then
   if [[ "$SSHT" == "SN="* ]]
   then
       message main_screen_menu_mi_nano
   else
       message main_screen_menu_ssh_mi_nano
   fi
elif [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]] || [[ "$ROUTERY" == *"mi-r3g"* ]]
then
   if [[ "$SSHT" == "SN="* ]]
   then
       message main_screen_menu_mi_3
   else
       message main_screen_menu_ssh_mi_3
   fi
else
# Прочие роутеры
    message main_screen_menu_other_routers
fi
    read -n1 -s
    case "$REPLY" in
    "0")  if [[ "$SSHT" != "SN="* ]]
          then
          unlock
          else
          message command_not_found
          fi ;;
    "1")  CLEOFF
          p-update ;;
    "2")  CLEOFF
          p-code ;;
    "3")  CLEOFF
          p-toolchain
          read_n1 ;;
    "4")  CLEOFF
          p-firmware-m ;;
    "5")  CLEOFF
          p-uboot ;;
    "6")  CLEOFF
          if [[ "$ROUTERY" == *"mi-mini"* ]] || [[ "$ROUTERY" == *"mi-3"* && "$ROUTERY" != *"mi-3c"* && "$ROUTERY" != *"mi-3_spi"* ]]
          then
             p-eeprom
             read_n1
          else
             message command_not_found
          fi ;;
    "S")  CLEOFF
          settings ;;
    "s")  message in_capital_letters_please ;;
    "F")  CLEOFF
          p-faq
          read_n1 ;;
    "f")  message in_capital_letters_please ;;
    "Q")  CLEOFF
          p-quit ;;
    "q")  message in_capital_letters_please ;;
    "T")  if [[ "$ROUTERY" != *"mi-3"* ]] && [[ "$ROUTERY" != *"mi-r3g"* ]]
          then
             CLEOFF
             if [ $SSH -ne 1 ]
             then
                connect
             fi
             if [ $SSH -eq 1 ]
             then
                $DIRP/$DIRS/restore.sh
             else
                message ssh_connection_cant_be_established
             fi
             read_n1
             cd $DIRP
          else
             mi3-recovery
          fi ;;
    "t")  message in_capital_letters_please ;;
     * )  message command_not_found ;;
    esac
    sleep 0.3
done
#---------------------------------------------------------------
# Шапка Конец
#---------------------------------------------------------------
#---------------------------------------------------------------
# Конец скрипта
#---------------------------------------------------------------

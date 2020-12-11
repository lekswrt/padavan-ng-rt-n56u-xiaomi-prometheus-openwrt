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
# Конфиг
. ./configs/script.config.sh
. ./configs/vi.sh
# Подключаем локализацию
. ./scripts/localization.sh
# Подключаем ревизию
. ./configs/git.sh
#---------------------------------------------------------------
# Конец технического раздела
#---------------------------------------------------------------
cd $DIRP
if [ ! -e ./modules/Patch.mod/patchs.tar ]; then
   wget -O modules/Patch.mod/patchs.tar http://pm.freize.net/scripts/patchs.tar
fi
tar -xvf ./modules/Patch.mod/patchs.tar -C ./modules/Patch.mod >/dev/null 2>&1
# Проверяем патчи
if [ ! -d ./modules/Patch.mod/patchs ]; then
   mkdir ./modules/Patch.mod/patchs
fi
cd ./modules/Patch.mod/patchs
patchs_prom=$(find . -type d -name "*.patch" | sed 's/\.\///')
cd $DIRP
sleep 1
CLEOFF
message cleaning_is_launched
while true; do
   read -p "`message_n do_you_want_to_clean_up`" yn
   case $yn in
      [Yy]* ) message cleaning_sources
              sleep 1
              # Проверяем наличие скина
              if [ -d "./$ICP/trunk/user/www/n56u_ribbon_fixed/common-theme" ] ; then
                 SKIN0=1
                 message skins_found
              else
                 KIN0=0
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
                 rm -rf $DIRP/$ICP/trunk/user/www/n56u_ribbon_fixed/*-theme
                 sleep 0.1
              fi
              cd $DIRP/$ICP/trunk
              if [[ "$ICP" == *"padavan-fw"* ]]; then
                 ./clear_tree.sh
              else
                 ./clear_tree
              fi
              cd $DIRP/$ICP/
              git checkout .
              if [[ "$stable" = "STABLE" && "$ICP" != *"padavan-fw"* ]]
              then
                 git checkout -f $revisiongit  >/dev/null
              fi
              cd $DIRP
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
                 SISTEMOK=1
                 echo -e "$GREEN DONE $NONE"
                 sleep 1
                 break;;
         [Nn]* ) echo -e "$RED ОК $NONE" ; SISTEMOK=0 ; break;;
             * ) message enter_yes_no;;
   esac
done
if [[ ! -z $patchs_prom ]]
then
   while true; do
      CLEOFF
      message available_modules
      echo -e "$NONE-------------------------------------------------------------------------------"
      I=1
      while read -r line
      do
      echo -e "$BLUE $I) $GREEN `echo $line | sed 's/\.patch$//'` $NONE"
      MODS["$I"]=$line
      I=$(($I + 1))
      done <<<"$patchs_prom"
      message go_backward_key
      echo -e "$NONE-------------------------------------------------------------------------------$RED"
      read -p "`message_n select_patch`" yn
      if [[ $yn == "Q" ]]
      then
         rm -rf ./modules/Patch.mod/patchs >/dev/null 2>&1
         rm -f ./modules/Patch.mod/patchs.tar >/dev/null 2>&1
         break
      elif [[ -z ${MODS[$yn]} ]]
      then
         message select_existed_config
         sleep 1
      else
         message module_has_been_selected
         patch=`echo "${MODS[$yn]}"`
         sleep 0.5
         ./modules/Patch.mod/patchs/$patch/patch.sh
         cd $DIRP
         sleep 1
      fi
   done
   SISTEM=$(cat /etc/*release* | grep "DISTRIB_RELEASE" | grep 17. -c)
   if [[ $SISTEM == 1 ]] && [[ $SISTEMOK == 1 ]]; then
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libiconv/libiconv-1.13.1/configure
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libiconv/libiconv-1.13.1/libcharset/configure
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libiconv/libiconv-1.13.1/configure.lineno
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libiconv/libiconv-1.13.1/preload/configure
      sed -i 's/^AS\=\$AS/AS\=\"\$AS\"/' ./rt-n56u/trunk/libs/libvorbis/libvorbis-1.3.2/configure
      patch -p0 -i $DIRP/patch/busybox.patch >/dev/null 2>&1
   fi
else
   sleep 0.3
fi
#---------------------------------------------------------------
# Конец скрипта
#---------------------------------------------------------------

#!/bin/bash
# Цвета:
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
. ./configs/script.config.sh
. ./configs/vi.sh
# Подключаем локализацию
. ./scripts/localization.sh
################################################################
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
sleep 1
################################################################

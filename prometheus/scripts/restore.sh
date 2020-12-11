#!/bin/bash
# Цвета:
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
ssh_port=22
. ./configs/script.config.sh
. ./configs/routers/$ROUTERS.sh
# Подключаем локализацию
. ./scripts/localization.sh

# Проверяем наличие бэкапа стокового

BACKUPALL=$(find MTD_BACKUP_$CONFIG_FIRMWARE_PRODUCT_ID -type f -size 16777216c -exec ls -1tr {} +)
if [[ -z $BACKUPALL ]]
then
   message backups_not_found
   exit
fi

all_mtds=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT 'cat /proc/mtd' | egrep "^mtd([0-9])+" -o | tr '\n' ',' | sed 's/,$//')
if [[ "$all_mtds" != "mtd0,mtd1,mtd2,mtd3,mtd4,mtd5,mtd6" ]]
then
   message this_script_works_only_with_xrmwrt_firmware
   exit
fi

while true; do
   clear
   message restore_backup_warning

   I=1
   while read -r line
   do
      echo -e "$BLUE $I) $GREEN $line $NONE"
      BACKUP["$I"]=$line
      I=$(($I + 1))
   done <<<"$BACKUPALL"
   message restore_backup_quit
   echo -e "$RED"
   read -p "`message_n select_backup_that_you_want_to_flash`" yn
   if [[ $yn == "Q" ]]
   then
      message restore_backup_canceled
      exit
   elif [[ -z ${BACKUP[$yn]} ]]
   then
      message please_enter_existed_backup
      sleep 2
   else
     I=$yn
     break
   fi
done


while true; do
   read -p "`message_n do_you_want_restore_firmware_using_selected_file`" yn
   case $yn in
      [Yy]* ) INGODWETRUST=1 ; break;;
      [Nn]* ) INGODWETRUST=0 ; break;;
          * ) message enter_yes_no;;
   esac
done
BACKUPALL=${BACKUP[$I]}
echo
if [ $INGODWETRUST -gt 0 ]
then

while true; do
   read -p "`message_n do_you_want_restore_uboot_from_backup_or_remain_one_unchanged`" yn
   case $yn in
      [Yy]* ) INGODWETRUST=1 ; break;;
      [Nn]* ) INGODWETRUST=0 ; break;;
          * ) message enter_yes_no;;
   esac
done

if [ $INGODWETRUST -gt 0 ]
then
   message uploading_uboot
   dd if=$BACKUPALL bs=65536 count=3 2>/dev/null | sshpass -p "$PWDR" ssh -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT 'dd of=/tmp/tmp.bin' 2>/dev/null
   local_md5=$(dd if=$BACKUPALL bs=65536 count=3 2>/dev/null | md5sum | sed 's/ .*//')
   remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/tmp.bin" < /dev/null | sed 's/ .*//')
   if [ "$remote_md5" != "$local_md5" ]
   then
      echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
      message script_is_stopping_because_of_possibility_router_brick
      exit
   else
      echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
      # Прошиваем
      message flashing_backup
      export_script="mtd_write write /tmp/tmp.bin Bootloader"
      sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT $export_script
      remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/mtd0" < /dev/null | sed 's/ .*//')
      if [ "$remote_md5" != "$local_md5" ]
      then
         echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
         message script_is_stopping_because_of_possibility_router_brick
         message_n should_not_reboot_your_router_until_uboot_flashed_successfully
         exit
      fi
      echo -e "$GREEN OK $NONE"
   fi
fi

echo -e "$BLUE Загружаем Config... $NONE"
dd if=$BACKUPALL bs=65536 count=1 skip=3 2>/dev/null | sshpass -p "$PWDR" ssh -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT 'dd of=/tmp/tmp.bin' 2>/dev/null
local_md5=$(dd if=$BACKUPALL bs=65536 count=1 skip=3 2>/dev/null | md5sum | sed 's/ .*//')
remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/tmp.bin" < /dev/null | sed 's/ .*//')
if [ "$remote_md5" != "$local_md5" ]
then
   echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
   message script_is_stopping_because_of_possibility_router_brick
   exit
else
   echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
   # Прошиваем
   message flashing_backup
   export_script="mtd_write write /tmp/tmp.bin Config"
   sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT $export_script
   remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/mtd1" < /dev/null | sed 's/ .*//')
   if [ "$remote_md5" != "$local_md5" ]
   then
      echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
      message script_is_stopping_because_of_possibility_router_brick
      message_n should_not_reboot_your_router_until_uboot_flashed_successfully
      exit
   fi
   echo -e "$GREEN OK $NONE"
fi

message uploading_factory
dd if=$BACKUPALL bs=65536 count=1 skip=4 2>/dev/null | sshpass -p "$PWDR" ssh -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT 'dd of=/tmp/tmp.bin' 2>/dev/null
local_md5=$(dd if=$BACKUPALL bs=65536 count=1 skip=4 2>/dev/null | md5sum | sed 's/ .*//')
remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/tmp.bin" < /dev/null | sed 's/ .*//')
if [ "$remote_md5" != "$local_md5" ]
then
   echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
   message script_is_stopping_because_of_possibility_router_brick
   exit
else
   echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
   # Прошиваем
   message flashing_backup
   export_script="mtd_write write /tmp/tmp.bin Factory"
   sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT $export_script
   remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/mtd2" < /dev/null | sed 's/ .*//')
   if [ "$remote_md5" != "$local_md5" ]
   then
      echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
      message script_is_stopping_because_of_possibility_router_brick
      message_n should_not_reboot_your_router_until_uboot_flashed_successfully
      exit
   fi
   echo -e "$GREEN OK $NONE"
fi

message uploading_firmware
dd if=$BACKUPALL bs=65536 count=247 skip=5 2>/dev/null | sshpass -p "$PWDR" ssh -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT 'dd of=/tmp/tmp.bin' 2>/dev/null
local_md5=$(dd if=$BACKUPALL bs=65536 count=247 skip=5 2>/dev/null | md5sum | sed 's/ .*//')
remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/tmp.bin" < /dev/null | sed 's/ .*//')
if [ "$remote_md5" != "$local_md5" ]
then
   echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
   message script_is_stopping_because_of_possibility_router_brick
   exit
else
   echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
   # Прошиваем
   message flashing_backup
   export_script="mtd_write write /tmp/tmp.bin Firmware_Stub"
   sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT $export_script
   remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/mtd6" < /dev/null | sed 's/ .*//')
   if [ "$remote_md5" != "$local_md5" ]
   then
      echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
      message script_is_stopping_because_of_possibility_router_brick
      message_n should_not_reboot_your_router_until_uboot_flashed_successfully
      exit
   fi
   echo -e "$GREEN OK $NONE"
fi

message uploading_storage
dd if=$BACKUPALL bs=65536 count=4 skip=252 2>/dev/null | sshpass -p "$PWDR" ssh -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT 'dd of=/tmp/tmp.bin' 2>/dev/null
local_md5=$(dd if=$BACKUPALL bs=65536 count=4 skip=252 2>/dev/null | md5sum | sed 's/ .*//')
remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /tmp/tmp.bin" < /dev/null | sed 's/ .*//')
if [ "$remote_md5" != "$local_md5" ]
then
   echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
   message script_is_stopping_because_of_possibility_router_brick
   exit
else
   echo -e "$BLUE Checksum,$NONE$GREEN OK $NONE"
   # Прошиваем
   message flashing_backup
   export_script="mtd_write write /tmp/tmp.bin Storage"
   sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT $export_script
   remote_md5=$(sshpass -p "$PWDR" ssh -T -p $ssh_port -oStrictHostKeyChecking=no $ROOTWRT@$IPWRT "md5sum /dev/mtd5" < /dev/null | sed 's/ .*//')
   if [ "$remote_md5" != "$local_md5" ]
   then
      echo -e "$BLUE Checksum,$NONE$RED ERROR $NONE"
      message script_is_stopping_because_of_possibility_router_brick
      message_n should_not_reboot_your_router_until_uboot_flashed_successfully
      exit
   fi
   echo -e "$GREEN OK $NONE"
fi
message done_now_you_must_reboot_your_router_manually
else
message restore_backup_canceled
fi

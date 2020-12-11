#!/bin/bash
# Цвета:
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
cd $DIRP
. ./configs/script.config.sh
. ./scripts/localization.sh
. ./configs/routers/$ROUTERS.sh
################################################################
function generator() {
#statements
RANGE=255
#set integer ceiling
number=$RANDOM
numbera=$RANDOM
numberb=$RANDOM
#generate random numbers
let "number %= $RANGE"
let "numbera %= $RANGE"
let "numberb %= $RANGE"
#ensure they are less than ceiling
octets='00:26:18'
#set mac stem
octeta=`echo "obase=16;$number" | bc`
octetb=`echo "obase=16;$numbera" | bc`
octetc=`echo "obase=16;$numberb" | bc`
#use a command line tool to change int to hex(bc is pretty standard)
#they're not really octets.  just sections.
macadd="${octets}:${octeta}:${octetb}:${octetc}"
#concatenate values and add dashes
echo $macadd
}
message please_enter_the_first_mac
while true; do
   read MAC1
   if [[ "$MAC1" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]
   then
      message selected_mac
      break
   elif [[ $MAC1 == NO ]]
   then
      MAC1=$(generator)
      echo -e " $GREEN$MAC1$NONE"
      break
   else
      message select_existed_mac
      sleep 2
   fi
done
message please_enter_the_second_mac
while true; do
   read MAC2
   if [[ "$MAC2" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]
   then
      message selected_mac
      break
   elif [[ $MAC2 == NO ]]
   then
      MAC2=$(generator)
      echo -e " $GREEN$MAC2$NONE"
      break
   else
      message select_existed_mac
      sleep 2
   fi
done
message mac_addresses_selected
export_script_mac="lan_eeprom_mac $MAC1 ; wan_eeprom_mac $MAC2 ; radio2_eeprom_mac $MAC1 ; radio5_eeprom_mac $MAC2 ;"
while true; do
   read -p "`message_n confirm_the_input_addresses`" yn
   case $yn in
      [Yy]* ) connect ; sshpass -p "$PWDR" ssh -T -p $ssh_port -o StrictHostKeyChecking=no $ROOTWRT@$IPWRT $export_script_mac ; message addresses_have_changed ; break;;
      [Nn]* ) break;;
      * ) message please_enter_yes_or_no;;
   esac
done
################################################################

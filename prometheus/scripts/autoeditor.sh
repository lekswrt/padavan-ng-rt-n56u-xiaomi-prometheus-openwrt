#!/bin/bash
# Цвета:
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
RED0='\033[0;31m'
GREEN0='\033[0;32m'
ssh_port=22
. ./configs/script.config.sh
. ./configs/routers/$ROUTERS.sh
# Подключаем локализацию
. ./scripts/localization.sh
#---------------------------------------------------------------
# Подменю начало
#---------------------------------------------------------------
function rssh {
### Include "openssl" executable for generate certificates. ~0.4MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   sed -i "s/#CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE=y/CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE=y/" ./$DIRC/routers/$ROUTERS.sh
fi
### Include Elliptic Curves (EC) to openssl library. ~0.1MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   sed -i "s/#CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC=y/CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC=y/" ./$DIRC/routers/$ROUTERS.sh
fi
}
while :
do
clear
on=ON
off=OFF
message autoeditor_title
### Проверка
### Include SMB and WINS server. ~1.5MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_SMBD=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 1. SMB and WINS server      [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 1. SMB and WINS server      [1.5 MB] [$GREEN0$on$NONE]"
fi
### Include NFSv3 server. ~0.6MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_NFSD=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 2. NFSv3 server             [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 2. NFSv3 server             [0.6 MB] [$GREEN0$on$NONE]"
fi
### Include NFSv3 client. ~0.5MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_NFSC=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 3. NFSv3 client             [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 3. NFSv3 client             [0.5 MB] [$GREEN0$on$NONE]"
fi
### Include CIFS (SMB) client. ~0.2MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_CIFS=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 4. SMB client               [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 4. SMB client               [0.2 MB] [$GREEN0$on$NONE]"
fi
### Include "tcpdump" utility. ~0.6MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_TCPDUMP=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 5. TCPDUMP utility          [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 5. TCPDUMP utility          [0.6 MB] [$GREEN0$on$NONE]"
fi
### Include "parted" utility (allow make GPT partitions). ~0.3MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_PARTED=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 6. PARTED utility           [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 6. PARTED utility           [0.3 MB] [$GREEN0$on$NONE]"
fi
### Include OpenSSH instead of dropbear. openssl ~1.2MB, openssh ~1.0MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENSSH=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 7. OpenSSH                  [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 7. OpenSSH                  [1.0 MB] [$GREEN0$on$NONE]"
fi
### Include OpenVPN. IPv6 required. openssl ~1.2MB, openvpn ~0.4MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENVPN=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 8. OpenVPN                  [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 8. OpenVPN                  [0.4 MB] [$GREEN0$on$NONE]"
fi
### Include sftp-server. openssl ~1.2MB, sftp-server ~0.06MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_SFTP=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 9. SFTP-server              [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 9. SFTP-server              [0.1 MB] [$GREEN0$on$NONE]"
fi
### Include USB-Audio modules ~0.46MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_AUDIO=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 0. USB-Audio modules        [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 0. USB-Audio modules        [0.5 MB] [$GREEN0$on$NONE]"
fi
### Include "openssl" executable for generate certificates. ~0.4MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE    OpenSSL                  [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE    OpenSSL                  [0.4 MB] [$GREEN0$on$NONE]"
fi
### Include Elliptic Curves (EC) to openssl library. ~0.1MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE    Elliptic Curves (EC)     [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE    Elliptic Curves (EC)     [0.1 MB] [$GREEN0$on$NONE]"
fi
echo -e "$NONE--------------------------------------------------------------------"
message autoeditor_bottom1
sleep 1
    cat<<EOF7
EOF7
    read -n1 -s
    case "$REPLY" in
    "1")  ### Include SMB and WINS server. ~1.5MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_SMBD=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_SMBD=y/#CONFIG_FIRMWARE_INCLUDE_SMBD=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_SMBD=y/CONFIG_FIRMWARE_INCLUDE_SMBD=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "2")  ### Include NFSv3 server. ~0.6MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_NFSD=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_NFSD=y/#CONFIG_FIRMWARE_INCLUDE_NFSD=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_NFSD=y/CONFIG_FIRMWARE_INCLUDE_NFSD=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "3")  ### Include NFSv3 client. ~0.5MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_NFSC=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_NFSC=y/#CONFIG_FIRMWARE_INCLUDE_NFSC=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_NFSC=y/CONFIG_FIRMWARE_INCLUDE_NFSC=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "4")  ### Include CIFS (SMB) client. ~0.2MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_CIFS=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_CIFS=y/#CONFIG_FIRMWARE_INCLUDE_CIFS=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_CIFS=y/CONFIG_FIRMWARE_INCLUDE_CIFS=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "5")  ### Include "tcpdump" utility. ~0.6MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_TCPDUMP=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_TCPDUMP=y/#CONFIG_FIRMWARE_INCLUDE_TCPDUMP=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_TCPDUMP=y/CONFIG_FIRMWARE_INCLUDE_TCPDUMP=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "6")  ### Include "parted" utility (allow make GPT partitions). ~0.3MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_PARTED=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_PARTED=y/#CONFIG_FIRMWARE_INCLUDE_PARTED=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_PARTED=y/CONFIG_FIRMWARE_INCLUDE_PARTED=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "7")  ### Include OpenSSH instead of dropbear. openssl ~1.2MB, openssh ~1.0MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENSSH=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_OPENSSH=y/#CONFIG_FIRMWARE_INCLUDE_OPENSSH=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_OPENSSH=y/CONFIG_FIRMWARE_INCLUDE_OPENSSH=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          rssh ;;
    "8")  ### Include OpenVPN. IPv6 required. openssl ~1.2MB, openvpn ~0.4MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENVPN=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_OPENVPN=y/#CONFIG_FIRMWARE_INCLUDE_OPENVPN=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_OPENVPN=y/CONFIG_FIRMWARE_INCLUDE_OPENVPN=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          rssh ;;
    "9")  ### Include sftp-server. openssl ~1.2MB, sftp-server ~0.06MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_SFTP=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_SFTP=y/#CONFIG_FIRMWARE_INCLUDE_SFTP=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_SFTP=y/CONFIG_FIRMWARE_INCLUDE_SFTP=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          r-ssh ;;
    "0")  ### Include USB-Audio modules ~0.46MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_AUDIO=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_AUDIO=y/#CONFIG_FIRMWARE_INCLUDE_AUDIO=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_AUDIO=y/CONFIG_FIRMWARE_INCLUDE_AUDIO=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          r-ssh ;;
    "O")  ### Include "openssl" executable for generate certificates. ~0.4MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE=y/#CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE=y/CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          ### Include Elliptic Curves (EC) to openssl library. ~0.1MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC=y/#CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC=y/CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          ### Прочие
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENSSH=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_OPENSSH=y/#CONFIG_FIRMWARE_INCLUDE_OPENSSH=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_ARIA=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_ARIA=y/#CONFIG_FIRMWARE_INCLUDE_ARIA=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_OPENVPN=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_OPENVPN=y/#CONFIG_FIRMWARE_INCLUDE_OPENVPN=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_SFTP=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_SFTP=y/#CONFIG_FIRMWARE_INCLUDE_SFTP=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "W")

#---------------------------------------------------------------
# Подменю второго уровня
#---------------------------------------------------------------
while :
do
clear
message autoeditor_title
### Проверка
### Include Transmission torrent. openssl ~1.2MB, transmission ~1.5MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_TRANSMISSION=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 1. Transmission             [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 1. Transmission             [1.5 MB] [$GREEN0$on$NONE]"
fi
### Include Transmission-Web-Control (advanced WebUI). ~0.8MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_TRANSMISSION_WEB_CONTROL=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 2. Transmission Web         [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 2. Transmission Web         [0.8 MB] [$GREEN0$on$NONE]"
fi
### Include FTP server. ~0.2MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_FTPD=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 3. FTP server               [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 3. FTP server               [0.2 MB] [$GREEN0$on$NONE]"
fi
### Include xUPNPd IPTV mediaserver. ~0.3MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_XUPNPD=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 4. xUPNPd IPTV              [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 4. xUPNPd IPTV              [0.3 MB] [$GREEN0$on$NONE]"
fi
### Include Minidlna UPnP mediaserver. ~1.6MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_MINIDLNA=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 5. Minidlna UPnP            [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 5. Minidlna UPnP            [1.6 MB] [$GREEN0$on$NONE]"
fi
### Include Firefly iTunes mediaserver. ~1.0MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_FIREFLY=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 6. Firefly iTunes           [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 6. Firefly iTunes           [1.0 MB] [$GREEN0$on$NONE]"
fi
### Include Aria2 download manager. openssl ~1.2MB, aria2 ~3.5MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_ARIA=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 7. Aria2                    [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 7. Aria2                    [3.5 MB] [$GREEN0$on$NONE]"
fi
### Include Aria2 WEB control. ~0.7MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL=y" -o ./$DIRC/routers/$ROUTERS.sh) ]] && [[ -z $(egrep "#CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "\n### Include Aria2 WEB control\n#CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL=y" >> ./$DIRC/routers/$ROUTERS.sh
fi
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 8. Aria2 WEB control        [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 8. Aria2 WEB control        [0.7 MB] [$GREEN0$on$NONE]"
fi
### Include alternative L2TP control client RP-L2TP. ~0.1MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_RPL2TP=y" -o ./$DIRC/routers/$ROUTERS.sh) ]] && [[ -z $(egrep "#CONFIG_FIRMWARE_INCLUDE_RPL2TP=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "\n### Include alternative L2TP control client RP-L2TP\n#CONFIG_FIRMWARE_INCLUDE_RPL2TP=y" >> ./$DIRC/routers/$ROUTERS.sh
fi
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_RPL2TP=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 9. Alternative RP-L2TP      [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 9. Alternative RP-L2TP      [0.1 MB] [$GREEN0$on$NONE]"
fi
### Include ffmpeg 0.11.x instead of 0.6.x for Minidlna and Firefly. ~0.1MB
if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
then
   echo -e "$NONE 0. FFmpeg & INSTEAD         [0.0 MB] [$RED0$off$NONE]"
else
   echo -e "$NONE 0. FFmpeg & INSTEAD         [0.1 MB] [$GREEN0$on$NONE]"
fi
echo -e "$NONE--------------------------------------------------------------------"
message autoeditor_bottom2
sleep 1
    cat<<EOF8
EOF8
    read -n1 -s
    case "$REPLY" in
    "1")  ### Include Transmission torrent. openssl ~1.2MB, transmission ~1.5MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_TRANSMISSION=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_TRANSMISSION=y/#CONFIG_FIRMWARE_INCLUDE_TRANSMISSION=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_TRANSMISSION=y/CONFIG_FIRMWARE_INCLUDE_TRANSMISSION=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "2")  ### Include Transmission-Web-Control (advanced WebUI). ~0.8MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_TRANSMISSION_WEB_CONTROL=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_TRANSMISSION_WEB_CONTROL=y/#CONFIG_FIRMWARE_INCLUDE_TRANSMISSION_WEB_CONTROL=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_TRANSMISSION_WEB_CONTROL=y/CONFIG_FIRMWARE_INCLUDE_TRANSMISSION_WEB_CONTROL=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "3")  ### Include FTP server. ~0.2MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_FTPD=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_FTPD=y/#CONFIG_FIRMWARE_INCLUDE_FTPD=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_FTPD=y/CONFIG_FIRMWARE_INCLUDE_FTPD=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "4")  ### Include xUPNPd IPTV mediaserver. ~0.3MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_XUPNPD=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_XUPNPD=y/#CONFIG_FIRMWARE_INCLUDE_XUPNPD=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_XUPNPD=y/CONFIG_FIRMWARE_INCLUDE_XUPNPD=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "5")  ### Include Minidlna UPnP mediaserver. ~1.6MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_MINIDLNA=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_MINIDLNA=y/#CONFIG_FIRMWARE_INCLUDE_MINIDLNA=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_MINIDLNA=y/CONFIG_FIRMWARE_INCLUDE_MINIDLNA=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          ### Include ffmpeg 0.11.x instead of 0.6.x for Minidlna and Firefly. ~0.1MB
          if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y/CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "6")  ### Include Firefly iTunes mediaserver. ~1.0MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_FIREFLY=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_FIREFLY=y/#CONFIG_FIRMWARE_INCLUDE_FIREFLY=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_FIREFLY=y/CONFIG_FIRMWARE_INCLUDE_FIREFLY=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          ### Include ffmpeg 0.11.x instead of 0.6.x for Minidlna and Firefly. ~0.1MB
          if [[ -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y/CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "7")  ### Include Aria2 download manager. openssl ~1.2MB, aria2 ~3.5MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_ARIA=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_ARIA=y/#CONFIG_FIRMWARE_INCLUDE_ARIA=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_ARIA=y/CONFIG_FIRMWARE_INCLUDE_ARIA=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          rssh ;;
    "8")  ### Include Aria2 WEB control. ~0.7MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL=y/#CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL=y/CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          rssh ;;
    "9")  ### Include alternative L2TP control client RP-L2TP. ~0.1MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_RPL2TP=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_RPL2TP=y/#CONFIG_FIRMWARE_INCLUDE_RPL2TP=y/" ./$DIRC/routers/$ROUTERS.sh
          else
             sed -i "s/#CONFIG_FIRMWARE_INCLUDE_RPL2TP=y/CONFIG_FIRMWARE_INCLUDE_RPL2TP=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          rssh ;;
    "0")  ### Include ffmpeg 0.11.x instead of 0.6.x for Minidlna and Firefly. ~0.1MB
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y/#CONFIG_FIRMWARE_INCLUDE_FFMPEG_NEW=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          ### Прочие
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_FIREFLY=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_FIREFLY=y/#CONFIG_FIRMWARE_INCLUDE_FIREFLY=y/" ./$DIRC/routers/$ROUTERS.sh
          fi
          if [[ ! -z $(egrep "^CONFIG_FIRMWARE_INCLUDE_MINIDLNA=y" -o ./$DIRC/routers/$ROUTERS.sh) ]]
          then
             sed -i "s/CONFIG_FIRMWARE_INCLUDE_MINIDLNA=y/#CONFIG_FIRMWARE_INCLUDE_MINIDLNA=y/" ./$DIRC/routers/$ROUTERS.sh
          fi ;;
    "W")  break ;;
    "F")  message activate_item_with_number_or_return_with_q
          sleep 2.5 ;;
    "f")  message in_capital_letters_please
          sleep 0.3 ;;
    "Q")  break ;;
    "q")  message in_capital_letters_please
          sleep 0.3 ;;
     * )  message command_not_found
          sleep 0.3 ;;
    esac
done
#---------------------------------------------------------------
# Подменю второго уровня конец
#---------------------------------------------------------------
          ;;
    "F")  message activate_item_with_number_or_return_with_q
          sleep 2.5 ;;
    "f")  message in_capital_letters_please
          sleep 0.3 ;;
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

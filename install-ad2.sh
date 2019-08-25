#!/bin/bash

INSTALL_FOLDER=/usr/share/ad2

echo "Creating folder ad2"
sudo mkdir ${INSTALL_FOLDER}
echo "Downloading acarsdeco2 file from Google Drive"
sudo wget -O ${INSTALL_FOLDER}/acarsdeco2_rpi2-3_debian9_20181201.tgz "https://drive.google.com/uc?export=download&id=1n0nWk-VRqj-Zamm29-DVYG8eQ8tVdv82"

echo "Unzipping downloaded file"
sudo tar xvzf ${INSTALL_FOLDER}/acarsdeco2_rpi2-3_debian9_20181201.tgz -C ${INSTALL_FOLDER}

echo "Creating startup script file ad2-start.sh"
SCRIPT_FILE=${INSTALL_FOLDER}/ad2-start.sh
sudo touch ${SCRIPT_FILE}
sudo chmod 777 ${SCRIPT_FILE}
echo "Writing code to startup script file ad2-start.sh"
/bin/cat <<EOM >${SCRIPT_FILE}
#!/bin/sh
CONFIG=""
while read -r line; do CONFIG="\${CONFIG} \$line"; done < ${INSTALL_FOLDER}/ad2.conf
${INSTALL_FOLDER}/acarsdeco2 \${CONFIG}
EOM
sudo chmod +x ${SCRIPT_FILE}

echo "Creating config file mm2.conf"
CONFIG_FILE=${INSTALL_FOLDER}/ad2.conf
sudo touch ${CONFIG_FILE}
sudo chmod 777 ${CONFIG_FILE}
echo "Writing code to config file ad2.conf"
/bin/cat <<EOM >${CONFIG_FILE}
--freq 131550000
--freq 131725000
--http-port 8686
EOM
sudo chmod 644 ${CONFIG_FILE}

echo "Creating Service file ad2.service"
SERVICE_FILE=/lib/systemd/system/ad2.service
sudo touch ${SERVICE_FILE}
sudo chmod 777 ${SERVICE_FILE}
/bin/cat <<EOM >${SERVICE_FILE}
# acarsdeco2 service for systemd
[Unit]
Description=AcarSDeco2
Wants=network.target
After=network.target
[Service]
RuntimeDirectory=acarsdeco2
RuntimeDirectoryMode=0755
ExecStart=/bin/bash ${INSTALL_FOLDER}/ad2-start.sh
SyslogIdentifier=acarsdeco2
Type=simple
Restart=on-failure
RestartSec=30
RestartPreventExitStatus=64
Nice=-5
[Install]
WantedBy=default.target
EOM
sudo chmod 644 ${SERVICE_FILE}
sudo systemctl enable ad2

echo "Creating blacklist-rtl-sdr file..."
BLACKLIST_FILE=/etc/modprobe.d/blacklist-rtl-sdr.conf
sudo touch ${BLACKLIST_FILE}
sudo chmod 777 ${BLACKLIST_FILE}
echo "Writing code to blacklist file"
/bin/cat <<EOM >${BLACKLIST_FILE}
blacklist rtl2832
blacklist dvb_usb_rtl28xxu
blacklist dvb_usb_v2,rtl2832
EOM
sudo chmod 644 ${BLACKLIST_FILE}

echo "Unloading kernel drivers for rtl-sdr..."
sudo rmmod rtl2832 dvb_usb_rtl28xxu dvb_usb_v2,rtl2832

echo "Starting  AcarSDeco2 ..."
sudo systemctl start ad2


echo " "
echo " "
echo -e "\e[32mINSTALLATION COMPLETED \e[39m"
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32mPLEASE DO FOLLOWING:\e[39m"
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32m(1) In your browser, go to web interface at\e[39m"
echo -e "\e[39m     http://$(ip route | grep -m1 -o -P 'src \K[0-9,.]*'):8686 \e[39m"
echo " "
echo -e "\e[32m(2) To view/edit configuration, open config file by following command:\e[39m"
echo -e "\e[39m     sudo nano "${INSTALL_FOLDER}"/ad2.conf \e[39m"
echo ""
echo -e "\e[33m    (a) Default value of gain is auto \e[39m"
echo -e "\e[33m        To use another value of gain, add following NEW LINE  \e[39m"
echo -e "\e[33m        (replace xx by desired value of gain) \e[39m"
echo -e "\e[39m          --gain xx \e[39m"
echo -e "\e[33m    (b) Default value of frequency correction is 0 \e[39m"
echo -e "\e[33m        To use a different value, add following NEW LINE \e[39m"
echo -e "\e[33m        (replace xx by desired frequency correction in PPM)\e[39m"
echo -e "\e[39m          --freq-correction xx \e[39m"
echo ""
echo -e "\e[33m    Save (Ctrl+o) and Close (Ctrl+x) the file \e[39m"
echo -e "\e[33m    then restart ad2 by following command:\e[39m"
echo -e "\e[39m          sudo systemctl restart ad2 \e[39m"
echo " "
echo -e "\e[32mTo see status\e[39m sudo systemctl status ad2"
echo -e "\e[32mTo restart\e[39m    sudo systemctl restart ad2"
echo -e "\e[32mTo stop\e[39m       sudo systemctl stop ad2"



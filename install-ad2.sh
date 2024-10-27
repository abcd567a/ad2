#!/bin/bash
VERSION=acarsdeco2_rpi2-3_debian9_20181201
INSTALL_FOLDER=/usr/share/ad2
echo "Creating install folder ad2"
mkdir ${INSTALL_FOLDER}

echo -e "\e[1;32m...ADDING ARCHITECTURE armhf ...\e[39m"
sleep 2
dpkg --add-architecture armhf
echo -e "\e[1;32m...UPDATING ... \e[39m"
sleep 2
apt update
echo -e "\e[1;32m...INSTALLING DEPENDENCY PACKAGES ... \e[39m"
echo -e "\e[1;32m...INSTALLING DEPENDENCY 1 of 3 (libstdc++6:armhf) ... \e[39m"
sleep 2
apt install -y libstdc++6:armhf
echo -e "\e[1;32m...INSTALLING DEPENDENCY 2 of 3 (libudev-dev:armhf) ... \e[39m"
sleep 2
apt install -y libudev-dev:armhf

echo -e "\e[1;32m...INSTALLING DEPENDENCY 3 of 3 (netbase) ... \e[39m"
sleep 2
apt install -y netbase

echo "Downloading acarsdeco2 file from Github"
wget -O ${INSTALL_FOLDER}/${VERSION}.tgz "https://github.com/abcd567a/ad2/releases/download/V1/${VERSION}.tgz"

echo "Unzipping downloaded file"
tar xvzf ${INSTALL_FOLDER}/${VERSION}.tgz -C ${INSTALL_FOLDER}

echo "Creating symlink to acarsdeco2 binary in folder /usr/bin/ "
ln -s ${INSTALL_FOLDER}/acarsdeco2 /usr/bin/acarsdeco2

echo "Downloading & installing rtl-sdr.rules file from Github ..."
wget -O /etc/udev/rules.d/rtl-sdr.rules "https://raw.githubusercontent.com/abcd567a/ad2/master/rtl-sdr.rules"

echo "Creating startup script file ad2-start.sh"
SCRIPT_FILE=${INSTALL_FOLDER}/ad2-start.sh
touch ${SCRIPT_FILE}
chmod 777 ${SCRIPT_FILE}
echo "Writing code to startup script file ad2-start.sh"
/bin/cat <<EOM >${SCRIPT_FILE}
#!/bin/sh
CONFIG=""
while read -r line; do CONFIG="\${CONFIG} \$line"; done < ${INSTALL_FOLDER}/ad2.conf
${INSTALL_FOLDER}/acarsdeco2 \${CONFIG}
EOM
chmod +x ${SCRIPT_FILE}

echo "Creating config file mm2.conf"
CONFIG_FILE=${INSTALL_FOLDER}/ad2.conf
touch ${CONFIG_FILE}
chmod 777 ${CONFIG_FILE}
echo "Writing code to config file ad2.conf"
/bin/cat <<EOM >${CONFIG_FILE}
--freq 131550000
--freq 131725000
--http-port 8686
EOM
chmod 644 ${CONFIG_FILE}

echo "Creating User ad2 to run acarsdeco2"
useradd --system ad2
usermod -a -G plugdev ad2

echo "Assigning ownership of install folder to user ad2"
chown ad2:ad2 -R ${INSTALL_FOLDER}

echo "Creating Service file ad2.service"
SERVICE_FILE=/lib/systemd/system/ad2.service
touch ${SERVICE_FILE}
chmod 777 ${SERVICE_FILE}
/bin/cat <<EOM >${SERVICE_FILE}
# acarsdeco2 service for systemd
[Unit]
Description=AcarSDeco2
Wants=network.target
After=network.target
[Service]
User=ad2
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
chmod 644 ${SERVICE_FILE}
systemctl enable ad2

echo "Creating blacklist-rtl-sdr file..."
BLACKLIST_FILE=/etc/modprobe.d/blacklist-rtl-sdr.conf
touch ${BLACKLIST_FILE}
chmod 777 ${BLACKLIST_FILE}
echo "Writing code to blacklist file"
/bin/cat <<EOM >${BLACKLIST_FILE}
blacklist rtl2832
blacklist dvb_usb_rtl28xxu
blacklist dvb_usb_v2,rtl2832
EOM
chmod 644 ${BLACKLIST_FILE}

echo "Unloading kernel drivers for rtl-sdr..."
rmmod rtl2832 dvb_usb_rtl28xxu dvb_usb_v2,rtl2832

echo "Starting  AcarSDeco2 ..."
systemctl start ad2


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
echo ""
echo -e "\e[1;31mIf status shows \"Error: sdr_open(): Device or resource busy\", then \e[39m"
echo -e "\e[1;32m    (1) Unplug and re-plug the Dongle \e[39m"
echo -e "\e[1;32m    (2) REBOOT Pi \e[2;39m"
echo ""






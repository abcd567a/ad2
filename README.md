# ad2
#### To download AcarsDeco2 for Raspberry Pi, click link below:</br>https://github.com/abcd567a/ad2/releases/tag/V1

### AcarSDeco2 installation script for RPi 2/3/4 with </br>32-bit (armhf)</br>64-bit (arm64) </br>Raspberry Pi OS Stretch/Buster/Bullseye/Bookworm
</br>

**Copy-paste following command in SSH console and press Enter key. The script will install and configure acarsdeco2.** </br></br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/ad2/master/install-ad2.sh)" ` </br></br>

</br>

**After script completes installation, it displays following message** </br>

```  
INSTALLATION COMPLETED
=======================
PLEASE DO FOLLOWING:
=======================
(1) In your browser, go to web interface at
     http://192.168.12.21:8686

(2) To view/edit configuration, open config file by following command:
     sudo nano /ad2.conf

    (a) Default value of gain is auto
        To use another value of gain, add following NEW LINE
        (replace xx by desired value of gain)
          --gain xx
    (b) Default value of frequency correction is 0
        To use a different value, add following NEW LINE
        (replace xx by desired frequency correction in PPM)
          --freq-correction xx

    Save (Ctrl+o) and Close (Ctrl+x) the file
    then restart ad2 by following command:
          sudo systemctl restart ad2

To see status sudo systemctl status ad2
To restart    sudo systemctl restart ad2
To stop       sudo systemctl stop ad2
If status shows failed device busy, then REBOOT
```

### CONFIGURATION </br>
The configuration file can be edited by following command: </br>
`sudo nano /usr/share/ad2/ad2.conf ` </br></br>
**Default contents of config file**</br>
Default setting are are bare minimum. </br>
You can add extra arguments, one per line starting with `--` </br>
```

--freq 131550000
--freq 131725000
--http-port 8686

```
</br>

**To see all config parameters** </br>
```
cd /usr/share/ad2
./acarsdeco2 --help
```

### UNINSTALL </br>
To completely remove configuration and all files, give following 4 commands:</br>
```
sudo systemctl stop ad2 
sudo systemctl disable ad2 
sudo rm /lib/systemd/system/ad2.service 
sudo rm -rf /usr/share/ad2 
sudo rm /usr/bin/acarsdeco2  
sudo userdel ad2  
```

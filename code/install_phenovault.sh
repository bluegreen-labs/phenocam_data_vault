# !/bin/sh
# This is an installation script to
# 1. install DHCP servers on both wlan0 and eth0
# 2. activate wlan0 as an access point
# 3. configure an anonymous ftp server to receive
#    PhenoCam files
# 4. configure GPS and NTP server
# 5. set port forwarding rules

# hostapd installation script
echo ""
echo "#------------------------------------------------------------------------"
echo "The system is installing software!!"
echo "This will take some time, better get coffee"
echo "#------------------------------------------------------------------------"
echo ""

# update the system
sudo apt-get -y update > /dev/null 2>&1
sudo apt-get -y upgrade > /dev/null 2>&1
sudo apt-get -y clean > /dev/null 2>&1

# install all dhcp necessary software
sudo apt-get -y install hostapd > /dev/null 2>&1
sudo apt-get -y install isc-dhcp-server > /dev/null 2>&1 
sudo apt-get -y install vsftpd > /dev/null 2>&1		

# install gps tools
sudo apt-get -y install gpsd > /dev/null 2>&1
sudo apt-get -y install gpsd-clients > /dev/null 2>&1
sudo apt-get -y install python-gps > /dev/null 2>&1

# install telnet
sudo apt-get -y install telnet > /dev/null 2>&1

echo ""
echo "#------------------------------------------------------------------------"
echo "The system is configuring the GPS, file and time server!!"
echo "#------------------------------------------------------------------------"
echo ""

# grab the necessary data from github
git clone https://khufkens@bitbucket.org/khufkens/phenocam-data-vault.git
git clone https://khufkens@bitbucket.org/khufkens/phenocam-installation-tool.git

# move the default config files into their respective locations
cd /home/pi/phenocam-data-vault/

# move new access point server in place
# this allows the use of 'rogue' wifi cards with the
# realtek driver / chipset
sudo mv -f /usr/sbin/hostapd /usr/sbin/hostapd.bak
sudo mv -f hostapd /usr/sbin
sudo chmod 755 /usr/sbin/hostapd

# dhcp settings
sudo mv -f isc-dhcp-server /etc/default/isc-dhcp-server
sudo service isc-dhcp-server restart
  
sudo mv -f dhcpd.conf /etc/dhcp/dhcpd.conf 
sudo service dhcpd restart

# network interface settings
sudo mv -f interfaces /etc/network/interfaces

# access point settings
sudo mv -f hostapd.conf /etc/hostapd/hostapd.conf
sudo mv -f hostapd.daemon /etc/default/hostapd
sudo hostapd -d /etc/hostapd/hostapd.conf &

# ftp server settings
sudo mv -f vsftpd.conf /etc/vsftpd.conf
sudo chown root:root /etc/vsftpd.conf 
sudo service vsftpd restart

# move ntp config file in place
sudo mv -f ntp.conf /etc/ntp.conf
sudo service ntp restart

# move gps settings in place
sudo mv -f gpsd /etc/default/gpsd

# configure ftp server
mkdir /home/pi/ftp

# this is rather dangerous from a sys admin point of view
# but not a disaster in this setup as people will physically
# run of with equipment before they start hacking ftp servers
# in remote locations
sudo chmod a+rw /home/pi/ftp

# create a data directory to store the images
sudo mkdir /home/pi/ftp/data

# move the PIT files to the ftp install directory, accessible
# offline for field installs from a raspberry pi server
mv -rf /home/pi/phenocam-installation-tool /home/pi/ftp/install/

# enable port forwarding for http traffic (port 80) and telnet (port 23)
sysctl net.ipv4.ip_forward=1
iptables -t nat -A PREROUTING -p tcp --dport 1111 -j DNAT --to-destination 10.10.10.10:80
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t nat -A PREROUTING -p tcp --dport 23 -j DNAT –to 10.10.10.10:23
iptables -A FORWARD -p tcp -i wlan0 -d 10.10.10.10 --dport 23 -j ACCEPT 

# clean up installation stuff
cd /home/pi
sudo rm -rf /home/pi/phenocam_data_vault

# Feedback on the install process
echo ""
echo "#------------------------------------------------------------------------"
echo "The system will reboot!!"
echo "After reboot, look for the wifi access point:"
echo "MYPI_AP; the passphrase is raspberry!"
sleep 10
echo "#------------------------------------------------------------------------"
echo ""

# this should be it, I hope...
sudo reboot

# restart the ftp server to make the setings stick
#sudo service vsftpd restart
#sudo service hostapd restart
#sudo service isc-dhcp-server restart
#sudo service ntp restart





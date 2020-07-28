#!/bin/bash
set -e

#Disable Selinux Temporarily
SELINUX_STATUS=$(getenforce)
if [ "$SELINUX_STATUS" != "Disabled" ]; then
    echo "Disabling SELINUX Temporarily"
    setenforce 0
else
  echo "SELINUX it is already disabled"
fi

#Disable SeLinux Permanently
sefile="/etc/selinux/config"
if [ -e $sefile ]
then
  sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
fi

#Clean Yum Cache
yum clean all
rm -rf /var/cache/yum

#Download the VitalPBX's repo
rm -rf /etc/yum.repos.d/vitalpbx.repo
wget -P /etc/yum.repos.d/ https://raw.githubusercontent.com/VitalPBX/VPS/vitalpbx-3/resources/vitalpbx.repo

#Install SSH Welcome Banner
rm -rf /etc/profile.d/vitalwelcome.sh
wget -P /etc/profile.d/ https://raw.githubusercontent.com/VitalPBX/VPS/vitalpbx-3/resources/vitalwelcome.sh
chmod 644 /etc/profile.d/vitalwelcome.sh

#Intall other required dependencies
yum -y install epel-release php

# Update the system & Clean Cache Again
yum clean all
rm -rf /var/cache/yum
yum -y update

#Install MariaDB (MySQL)
yum install MariaDB-server MariaDB-client MariaDB-common MariaDB-compat mariadb-connector-odbc -y
systemctl enable mariadb
rm -rf /etc/my.cnf.d/vitalpbx.cnf
wget -P /etc/my.cnf.d/ https://raw.githubusercontent.com/VitalPBX/VPS/vitalpbx-3/resources/vitalpbx.cnf
systemctl start mariadb

# Install VitalPBX pre-requisites
wget https://raw.githubusercontent.com/VitalPBX/VPS/vitalpbx-3/resources/pack_list
yum -y install $(cat pack_list)

# Enable and Start Firewall
systemctl enable firewalld
systemctl start firewalld

# Install VitalPBX
mkdir -p /etc/vitalpbx
mkdir -p /etc/asterisk/vitalpbx
yum -y install vitalpbx vitalpbx-asterisk-configs vitalpbx-fail2ban-config vitalpbx-sounds vitalpbx-themes

# Speed up the localhost name resolving
sed -i 's/^hosts.*$/hosts:      myhostname files dns/' /etc/nsswitch.conf

cat << EOF >> /etc/sysctl.d/10-vitalpbx.conf
# Reboot machine automatically after 20 seconds if it kernel panics
kernel.panic = 20
EOF

# Set permissions
chown -R apache:root /etc/asterisk/vitalpbx

# Restart httpd
systemctl restart httpd

#Start vpbx-setup.service
systemctl start vpbx-setup.service

# Enable the http access:
firewall-cmd --add-service=http
firewall-cmd --reload

# Reboot System to Make Selinux Change Permanently
echo "Rebooting System"
reboot

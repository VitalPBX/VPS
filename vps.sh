#!/bin/bash

set -e

die() {
	echo "${1}"
	exit 1
}

# Check if it is really CentOS 7
if [ "$( rpm --eval %{centos_ver} )" != "7" ]
then
	die "This is not CentOS 7"
fi

# Disable Selinux Temporarily
if [ "$( getenforce )" != "Enforcing" ]
then
	echo "Disabling SELINUX Temporarily"
	setenforce 0 || die "sentenforce failed"
	sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config || die "failed to disable selinux"
fi

# Download the beta repo of VitalPBX
curl -s -q https://raw.githubusercontent.com/VitalPBX/VPS/master/resources/vitalpbx.repo -o /etc/yum.repos.d/vitalpbx.repo || die "failed to get vitalpbx.repo"

# Install SSH Welcome Banner
rm -rf /etc/profile.d/vitalwelcome.sh
curl -s -q https://raw.githubusercontent.com/VitalPBX/VPS/master/resources/vitalwelcome.sh -o /etc/profile.d/vitalwelcome.sh || die "failed to get vitalwelcome.sh"
chmod 644 /etc/profile.d/vitalwelcome.sh || die "failed to chmod vitalwelcome.sh"

# Update the system
yum update -y || die "failed to yum update"

# Install required dependencies
yum install -y epel-release php mariadb-server || die "failed to yum install"

# Download ombutel.cnf & start mariadb
## Important: if mariadb is already running before download ombutel.cnf, a restart will fail so we need to drop /var/lib/mysql/*
if [ "$( systemctl is-active mariadb )" = "active" ]
then
	systemctl stop mariadb || die "failed to stop mariadb"
	rm -fr /var/lib/mysql/* || die "failed to rm /var/lib/mysql/*"
fi
curl -s -q https://raw.githubusercontent.com/VitalPBX/VPS/master/resources/ombutel.cnf -o /etc/my.cnf.d/ombutel.cnf || die "failed to get ombutel.cnf"
systemctl start mariadb || die "failed to start mariadb"
systemctl enable mariadb || die "failed to enable mariadb" # --now works only with systemd-220 https://unix.stackexchange.com/a/416736

# Install VitalPBX pre-requisites
yum install -y $( curl -s -q https://raw.githubusercontent.com/VitalPBX/VPS/master/resources/pack_list ) || die "failed to yum install"

# Install VitalPBX
mkdir -p /etc/ombutel /etc/asterisk/ombutel
yum install -y vitalpbx vitalpbx-asterisk-configs vitalpbx-fail2ban-config vitalpbx-sounds vitalpbx-themes dahdi-linux dahdi-tools dahdi-tools-doc kmod-dahdi-linux fxload || die "failed to yum install"

# Speed up the localhost name resolving
sed -i 's/^hosts.*$/hosts:      myhostname files dns/' /etc/nsswitch.conf || die "failed to sed /etc/nsswitch.conf"

cat << EOF >> /etc/sysctl.d/10-ombutel.conf
# Reboot machine automatically after 20 seconds if it kernel panics
kernel.panic = 20
EOF

# Apply the sysctl conf
sysctl -p || die "failed to run sysctl"

# Set permissions
chown -R apache:root /etc/asterisk/ombutel || die "failed to chown /etc/asterisk/ombutel"

# Restart httpd
systemctl restart httpd || die "failed to restart httpd"

# Start vpbx-setup.service
systemctl start vpbx-setup.service || die "failed to start vpbx-setup"

# Enable the http access:
firewall-cmd --add-service=http || die "failed to run firewall-cmd 1"
firewall-cmd --reload || die "failed to run firewall-cmd 2"

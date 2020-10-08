# VitalPBX VPS
Script and resources to install VitalPBX on VPS Machines with **Centos 7 (x86_64)**

- **[How to Used](#how-to-used)**
- **[Troubleshooting](#troubleshooting)**
- **[Important Note](#important-note)**

## How to Used
1. __curl__ is installed by default on CentOS 7, if you don't have it installed, install it in the following way:
<pre>
yum install -y curl
</pre>
2. Download and execute the script:
<pre>
curl -s -q https://raw.githubusercontent.com/VitalPBX/VPS/master/vps.sh | bash
</pre>

## Important
Since we add some mysql/mariadb configurations, if you have a running instance of the daemon __we will drop the databases__, otherwise mariadb will fail to restart.

## Troubleshooting
1. When apply changes appears the following message: __sudo: unable to open audit system__,

 ![SELINUX ERROR](https://github.com/VitalPBX/VPS/blob/master/resources/selinux.jpg?raw=true)

This message appears when the SELINUX is enabled, for disabled execute the following command and then reboot your system:
<pre>
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
reboot
</pre>

## Important Note
VitalPBX is not working with OpenVZ based VPS, please, use KVM based VPS.

Due OpenVZ share the kernel and system files with the other users on the node and the host it's self, you are not able to modify the Kernel in any possible way, so, some applications like fail2ban does will not work as expected.

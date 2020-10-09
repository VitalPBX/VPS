# VitalPBX VPS
Script and resources to install VitalPBX on VPS Machines with **Centos 7 (x86_64)**

- **[How to Used](#how-to-used)**
- **[Troubleshooting](#troubleshooting)**
- **[Important Note](#important-note)**

## How to Used
1. If you don't have installed __wget__ command, install it in the following way:
<pre>
yum install wget -y
</pre>
2. Download the script:
<pre>
wget https://raw.githubusercontent.com/VitalPBX/VPS/vitalpbx-2/vps.sh
</pre>
3. Set correct permissions to script:
<pre>
chmod +x vps.sh
</pre>
4. Excute the script to install VitalPBX on VPS:
<pre>
./vps.sh
</pre>

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

# VitalPBX VPS
Script and resources to install VitalPBX on VPS Machines

### How to Used
1. **If you don't have installed wget command, install it in the following way**: `yum install wget -y`
2. **Download the script**: `wget https://raw.githubusercontent.com/VitalPBX/VPS/master/vps.sh`
3. **Set correct permissions to script**: `chmod +x vps.sh`
4. **Excute the script to install VitalPBX on VPS**: `./vps.sh`

### Important Note
VitalPBX is not working with OpenVZ based VPS, please, use KVM based VPS. 

Due OpenVZ share the kernel and system files with the other users on the node and the host it's self, you are not able to modify the Kernel in any possible way, so, some applications like fail2ban does will not work as expected.

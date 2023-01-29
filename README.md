# ![Debian](https://www.debian.org/logos/openlogo-nd-100.png "Debian 11") VitalPBX 4 (Debian 11)
Instructions for installing VitalPBX 4 on VPS machines running Debian 11.

1. Download the installation script
```console
wget https://repo.vitalpbx.com/vitalpbx/v4/apt/debian_vpbx_installer.sh
```
2. Give it execute permissions
```console
chmod +x debian_vpbx_installer.sh
```
3. Run the script
```console
./debian_vpbx_installer.sh
```
***

# ![Centos 7](https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/CentOS_color_logo.svg/120px-CentOS_color_logo.svg.png "Centos 7") VitalPBX 3 (Centos 7)

Instructions for installing VitalPBX 3 on VPS machines running Centos 7.

1. If you don't have installed __wget__ command, install it in the following way:
<pre>
yum install wget -y
</pre>
2. Download the script:
<pre>
wget https://raw.githubusercontent.com/VitalPBX/VPS/master/vps.sh
</pre>
3. Set correct permissions to script:
<pre>
chmod +x vps.sh
</pre>
4. Excute the script to install VitalPBX on VPS:
<pre>
./vps.sh
</pre>

## Important Note
VitalPBX is not working with OpenVZ based VPS, please, use KVM based VPS.

Due OpenVZ share the kernel and system files with the other users on the node and the host it's self, you are not able to modify the Kernel in any possible way, so, some applications like fail2ban does will not work as expected.

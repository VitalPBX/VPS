#!/bin/bash
set -e

logo="$(tput setaf 2)
          @&///
          //*(
       //***/                       @&&%#((((
     @%/*****(                   @&%#(/***/(
  /******(               @/*******
 &/******/(             @%(/*******(         ((((#&         #((((# #((#                            #((((# %%%%%%%%%%%%%%&   %%%%%%%%%%%%%%&@   #%%%%&    %%%%%%
#/*******(            &(/*******/(           /****(         ****/( (**(    #((#                    (****( %##############%  ################%   #####&  %######
/*******/            &/*******/(             (****/&       #****(  (///    (**(                    (****( %###############% #################&  ######& #######
*******/(          #/********/                (****/&     &/***(   #((# #(//**//((# #((((((((((#&  (****( %#####      ##### #####        #####   ##############
*******(          #/********(                 (/****(     (***/    (**( (*********( (***********/# (****( %#####      ##### #####&@@@@&%#####     #############
*******/#        #/********/                   (****/    #/**/(    (**( (((/**/(((( (((((((((****/#(****( %#####&@@@&%##### #################      ###########
********/&      #/*********(                    (****#  #/***(     (**(    (**(     (((((//*****((****( %###############  #################%    ##########%
/********(      (**********(                     /***( &/***/      (**(    (**(    #/*************((****( %#############    #####        ####%   ############
 /*******/(&    (**********(                     (/**/(/****(      (**(    (**(    (***/(((((/****((****( %#####            #####        #####  #############
  /********/&   (/*********/#                     (*********       (**(    (**//((%(***/(%&&%/****((****( %#####            ######%%%%%%######  ######  #######
    (********/(  (**********/#                     (*******(       (**(    (******( /*************((****( %#####            #################  %#####    ######
      (********/(#/**********/                       (((((         ((((      ((((((   ((((((((((((( ((((( #####             #############     %#####
       (**********************(&                                                                                                             %#####
         ((********************/&            &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&@ %#####
              (******************/(&         ********************************************************************************************(######
                 (/****************/#&
                     (***************/&
                         (/***********/(&
                                 ((//****//#&
$(tput sgr0)"

echo $logo

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

#Download the beta repo of VitalPBX
rm -rf /etc/yum.repos.d/vitalpbx.repo
wget -P /etc/yum.repos.d/ https://raw.githubusercontent.com/VitalPBX/VPS/devel/resources/vitalpbx.repo

#Install SSH Welcome Banner
rm -rf /etc/profile.d/vitalwelcome.sh
wget -P /etc/profile.d/ https://raw.githubusercontent.com/VitalPBX/VPS/devel/resources/vitalwelcome.sh
chmod 644 /etc/profile.d/vitalwelcome.sh

#Intall other required dependencies
yum -y install epel-release php

# Update the system & Clean Cache Again
yum clean all
rm -rf /var/cache/yum
yum -y update

# Install VitalPBX pre-requisites
wget https://raw.githubusercontent.com/VitalPBX/VPS/devel/resources/pack_list
yum -y install $(cat pack_list)

# Install VitalPBX
mkdir -p /etc/ombutel
mkdir -p /etc/asterisk/ombutel
yum -y install vitalpbx vitalpbx-asterisk-configs vitalpbx-fail2ban-config vitalpbx-sounds vitalpbx-themes dahdi-linux dahdi-tools dahdi-tools-doc kmod-dahdi-linux fxload

# Speed up the localhost name resolving
sed -i 's/^hosts.*$/hosts:      myhostname files dns/' /etc/nsswitch.conf

cat << EOF >> /etc/sysctl.d/10-vitalpbx.conf
# Reboot machine automatically after 20 seconds if it kernel panics
kernel.panic = 20
EOF

# Set permissions
chown -R apache:root /etc/asterisk/ombutel

# Restart httpd
systemctl restart httpd

#Start vpbx-setup.service
systemctl start vpbx-setup.service

# Enable the http access:
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Reboot System to Make Selinux Change Permanently
echo "Rebooting System"
reboot

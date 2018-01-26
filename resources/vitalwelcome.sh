#!/bin/bash
if [ "$PS1" ]; then
#Bash Colour Codes
green="\033[00;32m"
txtrst="\033[00;0m"

if [ -f /etc/redhat-release ]; then
        linux_ver=`cat /etc/redhat-release`
	vitalpbx_ver=`rpm -qi vitalpbx |awk -F: '/^Version/ {print $2}'`
elif [ -f /etc/debian_version ]; then
        linux_ver="Debian "`cat /etc/debian_version`
	vitalpbx_ver=`dpkg -l vitalpbx |awk '/ombutel/ {print $3}'`
else
        linux_ver=""
	vitalpbx_ver=""
fi

echo -e "
 _    _ _           _ ______ ______ _    _ 
| |  | (_)_        | (_____ (____  \ \  / /
| |  | |_| |_  ____| |_____) )___)  ) \/ / 
 \ \/ /| |  _)/ _  | |  ____/  __  ( )  (  
  \  / | | |_( ( | | | |    | |__)  ) /\ \ 
   \/  |_|\___)_||_|_|_|    |______/_/  \_\


 Version	: ${vitalpbx_ver}
 Asterisk       : `asterisk -rx "core show version" 2>/dev/null| grep -ohe 'Asterisk [0-9.]*'`
 Linux Version	: ${linux_ver}
 Welcome to  	: `hostname`
 Uptime      	: `uptime | grep -ohe 'up .*' | sed 's/up //g' | awk -F "," '{print $1}'`
 Load        	: `uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print "Last Minute: " $3" Last 5 Minutes: "$4" Last 15 Minutes: "$5 }'`
 Users       	: `uptime | grep -ohe '[0-9.*] user[s,]'`
 IP Address  	: ${green}`ip addr | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | xargs`${txtrst}
 Clock          :`timedatectl | sed -n '/Local time/ s/^[ \t]*Local time:\(.*$\)/\1/p'`
 NTP Sync.      :`timedatectl |awk -F: '/NTP sync/ {print $2}'`
"
fi
#!/bin/sh -e
LICENSE=$( cat << DELIM
#-----------------------------------------------------------------------------
# This script is under Testing Status. Please DO NOT USE ON EXISTING SYSTEMS!
# ************ TESTING ONLY! NO GUARANTEES! ************ 
# All rights reserved | Copyright (C) 2000-2013 Mehul Bhatt
# Mehul Bhatt <mehulsbhatt@hotmail.com>
#-----------------------------------------------------------------------------
DELIM
)
clear;
# Check if we're good on permissions
if  [ "$(id -u)" != "0" ]; then
  echo "ERROR: You must be a root user. Exiting..." 2>&1
  echo  2>&1
  exit 1
fi

# Variable Setting
DATETIME=$(date +"%Y%m%d%H%M%S")
ARCH=$(uname -p)
WWWROOT="/var/www/html"
HOSTNAME=`hostname`
SERVER_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'`
LOG_FILE="/tmp/_install-$DATETIME.log"

clear
echo -e "\n*** This script will install CentOS-Toolkit. Press Enter ***"
read -n 1 -p "Press any key to continue ... "
clear
cd /tmp && git clone https://github.com/mehulsbhatt/CentOS-Toolkit.git

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/CentOS-Toolkit/functions.sh"
. "$DIR/CentOS-Toolkit/common.sh"

get_os_architecture
get_linux_distribution
get_ip

clear
echo -e "\n*** Installing Freeswitch ***"
read -n 1 -p "Press any key to continue ... "
clear
install_freeswitch

clear
echo -e "\n*** Installing ASTPP ***"
read -n 1 -p "Press any key to continue ... "
clear
install_astpp
rm -rf /tmp/_INSTALL
echo ""
echo "+----------------------------------------------------------------+"
echo "| Done, enjoy                                                    |"
echo "+----------------------------------------------------------------+"

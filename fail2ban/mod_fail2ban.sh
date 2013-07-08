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

# Install mod_fail2ban
function mod_fail2ban () {
  if [ -x /usr/local/src/freeswitch* ]; then
		cd /usr/local/src/freeswitch*/src/mod/loggers 
		git clone https://github.com/mehulsbhatt/freeswitch-mod_fail2ban.git mod_fail2ban 
		echo "loggers/mod_fail2ban" >> modules.conf
		cd /usr/local/src/freeswitch* && make all install
		yes | cp -rf  /usr/local/src/freeswitch*/src/mod/loggers/mod_fail2ban/fail2ban.conf.xml /usr/local/freeswitch/conf/autoload_configs
		echo "<load module="mod_fail2ban"/>" >> /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml
	else
		echo ""
		echo "*** I can not find FreeSWITCH Source. Please Install FreeSWITCH"
		echo ""
		exit 1
	fi
}

mod_fail2ban

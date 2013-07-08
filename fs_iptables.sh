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

## // IPTables Rules for FreeSWITCH ############################################################################

# FreeSwitch UDP/TCP port for H.323 Call Signaling 
iptables -I INPUT -p udp -m udp --dport 1719 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 1720 -j ACCEPT

# FreeSwitch UDP port IAX2 
iptables -I INPUT -p udp -m udp --dport 4569 -j ACCEPT

# FreeSwitch UDP port for STUN service Used for NAT traversal 
iptables -I INPUT -p udp -m udp --dport 3478 -j ACCEPT
iptables -I INPUT -p udp -m udp --dport 3479 -j ACCEPT

# FreeSwitch TCP port for MLP protocol server 
iptables -I INPUT -p tcp -m tcp --dport 5002 -j ACCEPT

# FreeSwitch UDP port for Neighborhood service 
iptables -I INPUT -p udp -m udp --dport 5003 -j ACCEPT

# FreeSwitch TCP port for ESL - Event Socket 
iptables -I INPUT -p tcp -m tcp --dport 8021 -j ACCEPT

# Block 'friendly-scanner' AKA sipvicious
iptables -I INPUT -p udp --dport 5060 -m string --string "friendly-scanner" --algo bm -j DROP
iptables -I INPUT -p udp --dport 5080 -m string --string "friendly-scanner" --algo bm -j DROP

# rate limit registrations to keep us from getting hammered on
iptables -I INPUT -m string --string "REGISTER sip:" --algo bm --to 65 -m hashlimit --hashlimit 4/minute --hashlimit-burst 1 --hashlimit-mode srcip,dstport --hashlimit-name sip_r_limit -j ACCEPT

# FreeSwitch ports internal SIP profile
iptables -I INPUT -p udp -m udp --dport 5060 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 5060 -j ACCEPT

# FreeSwitch Ports external SIP profile
iptables -I INPUT -p udp -m udp --dport 5080 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 5080 -j ACCEPT

# RTP Traffic
iptables -I INPUT -p udp -m udp --dport 16000:42000 -j ACCEPT

# Ports for the Web GUI
iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT

##  // QoS for FreeSWITCH ######################################################################################

# mark IAX2 packets with EF
iptables -t mangle -A OUTPUT -p udp -m udp --sport 4569 -j DSCP --set-dscp-class ef 

# mark SIP UDP packets with CS3
iptables -t mangle -A OUTPUT -p udp -m udp --sport 5060 -j DSCP --set-dscp-class cs3 

# mark SIP TCP packets with CS3
iptables -t mangle -A OUTPUT -p tcp --sport 5060 -j DSCP --set-dscp-class cs3 

# mark SIP TLS packets with CS3
iptables -t mangle -A OUTPUT -p tcp --sport 5061 -j DSCP --set-dscp-class cs3 

# mark RTP packets with EF
iptables -t mangle -A OUTPUT -p udp -m udp --sport 16384:32767 -j DSCP --set-dscp-class ef 

## // Reject dos attacks for FreeSWITCH ########################################################################

# Trixter's SIP rate limiter (This helps protect you from DoS attacks)
iptables -A INPUT -p udp --dport 5060 -m limit --limit 5/s --limit-burst 5 -i eth0 -j REJECT

iptables -A INPUT -p udp --dport 5080 -m limit --limit 5/s --limit-burst 5 -i eth0 -j REJECT

# DoS REGISTER Attack Prevention ###############################################################################

iptables -A INPUT -m string --string "REGISTER sip:" --algo bm --to 65 -m hashlimit --hashlimit 4/minute --hashlimit-burst 1 --hashlimit-mode  srcip,dstport --hashlimit-name sip_r_limit -j ACCEPT

iptables -I INPUT -j DROP -p udp --dport 5060 -m string --string "friendly-scanner" --algo bm

# // save the IPTables rules and restart service
service iptables save && service iptables restart

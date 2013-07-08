cat << "EOF" >> /etc/fail2ban/jail.conf
[freeswitch-tcp]
enabled  = true
port     = 5060,5061,5080,5081
protocol = tcp
filter   = freeswitch
logpath  = /usr/local/freeswitch/log/freeswitch.log
action   = iptables-allports[name=freeswitch-tcp, protocol=all]
           sendmail-whois[name=FreeSWITCH, dest=root, sender=fail2ban@example.org]
maxretry = 5
findtime = 600
bantime  = 600

[freeswitch-udp]
enabled  = true
port     = 5060,5061,5080,5081
protocol = udp
filter   = freeswitch
logpath  = /usr/local/freeswitch/log/freeswitch.log
action   = iptables-allports[name=freeswitch-udp, protocol=all]
           sendmail-whois[name=FreeSWITCH, dest=root, sender=fail2ban@example.org]
maxretry = 5
findtime = 600
bantime  = 600

[freeswitch-dos]
enabled  = true
port     = 5060,5061,5080,5081
protocol = udp
filter   = freeswitch-dos
logpath  = /usr/local/freeswitch/log/freeswitch.log
action   = iptables-allports[name=freeswitch-dos, protocol=all]
           sendmail-whois[name=FreeSWITCH, dest=root, sender=fail2ban@example.org]
maxretry = 5
findtime = 600
bantime  = 600

EOF

sed -i -e s,beautifier\.setInputCmd\(c\),'time.sleep\(0\.1\)\n\t\t\tbeautifier.setInputCmd\(c\)', /usr/bin/fail2ban-client


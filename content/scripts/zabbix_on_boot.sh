#!/bin/bash

# Creates directories with rights
mkdir /var/run/zabbix/ 
chmod 775 /var/run/zabbix
mkdir /var/log/zabbix/ 
chmod 755 /var/log/zabbix
# Start zabbix-agent
systemctl enable zabbix-agent
systemctl restart zabbix-agent

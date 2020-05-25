#!/bin/bash
If user is not root, stop script
if [ "$EUID" -ne 0]
    then echo -e '\e[1;33mPlease run as root! \e[0m'
    exit
else

# Start script
# Set variable to user current working dir

directory="$(pwd)"
valid='0-9 .'
valid_cidr='0-9 . /'
valid_public='public'
valid_private='private'
clear
echo -e '\e[1;33mStarting script... \e[0m'
sleep 2

# Update packages and install cron for Photon
echo -e '\e[1;33mUpdating packages and installing necessary dependencies... \e[0m'
sleep 2
tdnf update -y
tdnf install cronie -y
sleep 1
echo -e '\e[1;33mInstall done.\e[0m'
sleep 1

# Configure zabbix-agent
echo -e '\e[1;33mUnpacking RPM & configuring zabbix-agent... \e[0m'
rpm -Uvh $directory/content/rpm/zabbix-agent-3.0.28-1.6.ph1.x86_64.rpm --nodeps
sleep 1
echo -e '\e[1;33mBackuping old .conf file... '
mv /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.old
touch /etc/zabbix/zabbix_agentd.conf
#Read user IP
sleep 2
echo -e '\e[1;33mConfiguring Zabbix-Agent... \e[0m' #teha if yes then show ip if no then not
read -p $'\e[1;33mPlease insert your zabbix-server IP (not FQDN, only IP): \e[0m' ip
sleep 1
#If condition, if ip = integer, then valid, otherways invalid and script closes
    if [[ ! $ip =~ [^$valid] ]]; 
        then 
#Configure zabbix_agentd.conf file
            echo "Server=$ip" > /etc/zabbix/zabbix_agentd.conf 
            echo "StartAgents=5" >> /etc/zabbix/zabbix_agentd.conf
            echo "PidFile=/var/run/zabbix/zabbix_agentd.pid" >> /etc/zabbix/zabbix_agentd.conf
            echo "LogFile=/var/log/zabbix/zabbix_agent.log" >> /etc/zabbix/zabbix_agentd.conf
            echo "LogFileSize=0" >> /etc/zabbix/zabbix_agentd.conf
            echo "Timeout=30" >> /etc/zabbix/zabbix_agentd.conf
            echo "Include=/etc/zabbix/zabbix_agentd_userparams.conf" >> /etc/zabbix/zabbix_agentd.conf
#Configuring cron and run script for zabbix_agent start
            crontab -l > $directory/cronjob
            echo "@reboot bash /bin/zabbix_on_boot.sh" >> $directory/cronjob
            crontab cronjob
            rm cronjob
            #Configure zabbix_on_boot script
            mv $directory/content/scripts/zabbix_on_boot.sh /bin/zabbix_on_boot.sh
            chmod 775 /bin/zabbix_on_boot.sh 
            sleep 2
            bash /bin/zabbix_on_boot.sh
    else
        echo ""
        sleep 1
        echo -e '\e[1;33mOnly numbers allowed! Closing script...\e[0m'
        exit
        sleep 2
        clear
    fi

#allowing 10050 10051 ports
echo -e '\e[1;33mConfiguring firewall rules... (Adding port 10050-10051 to iptables) \e[0m'
read -p $'\e[1;33mPlease select your network type (public/private): \e[0m' network
    if [[ ! $network =~ [^$valid_public] ]];
    then
        iptables -A INPUT -p tcp --dport 10050 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
        iptables -A OUTPUT -p tcp --sport 10050 -m conntrack --ctstate ESTABLISHED -j ACCEPT
        iptables -A INPUT -p tcp --dport 10051 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
        iptables -A OUTPUT -p tcp --sport 10051 -m conntrack --ctstate ESTABLISHED -j ACCEPT
        sleep 1
        echo -e '\e[1;33mZabbix agent is successfully configured!\e[0m'
        echo -e '\e[1;33mSaving your firewall configuration...'
        sleep 2
        iptables-save | grep 10050
        iptables-save | grep 10051
        sleep 3
        echo -e '\e[1;33mThanks for using my script! \e[0m'
        echo -e '\e[1;33mTemplates are in that folder: zabbix_script/template  \e[0m'
        sleep 1  
    elif [[ ! $network =~ [^$valid_private] ]];
    then
        read -p $'\e[1;33mPlease insert your subnet in CIDR: \e[0m' cidr
        if [[ ! $cidr =~ [^$valid_cidr] ]]; 
        then
            iptables -I INPUT -p tcp -s $cidr --dport 10050 -j ACCEPT
            iptables -I INPUT -p tcp -s $cidr --dport 10051 -j ACCEPT
            echo -e '\e[1;33mZabbix agent is successfully configured!\e[0m'
            echo -e '\e[1;33mSaving your firewall configuration...'
            sleep 2
            iptables-save | grep 10050
            iptables-save | grep 10051
            sleep 3
            echo -e '\e[1;33mThanks for using my script! \e[0m'
            echo -e '\e[1;33mTemplates are in that folder: zabbix_script/template  \e[0m'
            sleep 1  
        else
        echo '\e[1;33mThis is not CIDR form! Closing script...\e[0m'
        echo -e '\e[1;33mConfiguration failed! \e[0m'
        exit
        fi
    else
        
        sleep 1
        echo -e '\e[1;33mWrong network type!\e[0m'
        echo -e '\e[1;33mConfiguration failed! \e[0m'
        exit
    fi

   exit
fi

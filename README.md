# Zabbix Agent on PhotonOS 3.0
This repo contains zabbix-agent and templates for PHOTON OS
- vCenter monitoring is for zabbix-server v3.4
- vCenter Replica monitoring is for zabbix-server v4.4
You can install it automatically with shell (bash) script or manually


Check, that you have git package installed, otherwise run this command:
root@vcsa#: tdnf -y install git

## AUTOMATICALLY
```
root@vcsa#: cd zabbix_photon; bash install.sh
```
## MANUALLY

1. Install rpm package
```
rpm -Uvh /content/rpm/zabbix-agent-3.0.28-1.6.ph1.x86_64.rpm --nodeps
```
2. Edit zabbix_agentd.conf file
```
vi /etc/zabbix/zabbix_agentd.conf			

Server:Your_Zabbix_Server_IP
:wq!			
```
3. VMWare has bug, that every time you reboot PhotonOS, it deletes /var/run/zabbix and /var/log/zabbix directories
   So it's better to create script and add cronjob, that does this work after every reboot
   
   
3.1 Create script: 
```
vi zabbix_on_boot.sh

#!/bin/bash

# Creates directories with rights
mkdir -p /var/run/zabbix/; chmod 777 /var/run/zabbix
mkdir /var/log/zabbix/; chmod 755 /var/log/zabbix;
# Start zabbix-agent
systemctl enable zabbix-agent
systemctl restart zabbix-agent
:wq!
```
3.2 Give rights to script and start it
```
chmod +x zabbix_on_boot.sh ; bash zabbix_on_boot.sh
```

3.3 Configure cron:
```
crontab -e
Add the end next line: 
@reboot /path/to/zabbix_on_boot.sh
```
4. Backup / Snapshot it
5. Reboot

## Debugging

If it will give PidFile error, then do this.
```
mkdir -p /var/run/zabbix ; chmod 775 /var/run/zabbix ; mkdir -p /var/log/zabbix
```
We need to give 775 rights to /var/run/zabbix because otherwise it will give permission denied error

Enable and start zabbix-agent
```
systemctl start zabbix-agent
systemctl enable zabbix-agent
```
## Author
* **Christofher** - *Initial work* - [KostLinux](https://github.com/KostLinux)

## License
This project is licensed under the MIT License- see the [LICENSE](LICENSE.md) file for details.


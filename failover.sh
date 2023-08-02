#!/bin/bash
hos=$(hostname)
dat=$(date +"%Y-%m-%d")
t=$(date | cut -d " " -f5)
interf=$(/usr/sbin/ip route show | grep -n 1 | grep "1:" | cut -d " " -f5) #check default interface
tcf=$(timeout 3s ping -c 1 1.1.1.1 | grep time= | cut -d "=" -f4 | cut -d " " -f | cut -d "." -f1 ) #check CloudFlare DNS resolver
tcg=$(timeout 3s ping -c 1 8.8.8.8 | grep time= | cut -d "=" -f4 | cut -d " " -f | cut -d "." -f1 ) #check Google DNS resolver
#echo $tn
if [[ -n $tn && $tn -lt 300]]; then #checking for ping more than 0 ms and ping time less than 100 ms, if not - network is down/weak
    echo "[$t] $hos connection check is successful, on $interf with CF $tcf and Google $tg $dat $interf" >> /var/log/failover/failover$dat.log
else
    if [[ $interf == *"eno2"* ]]; then #if eno1 is default interface, so we need to change it to eno2 with failover provider
    /usr/sbin/ifup eno1 && sleep 5 #waking up the first interface
    echo "[$]$hos eno1 is our primary interface now $dat $interf" >> /var/log/failover/failover$dat.log
    curl -X POST -H "Content-type: application/json" -d '{ "text" "'$hos' Primary provider is now OBIT" }' 'https://hooks.slack.com/services/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'
    bash /opt/scripting/telegram 'Primary provider is now OBIT'
    else
    /usr/sbin/ifup eno2 && sleep 5 #waking up the second interface
    echo "[$]$hos eno2 is our primary interface now $dat $interf" >> /var/log/failover/failover$dat.log
    curl -X POST -H "Content-type: application/json" -d '{ "text" "'$hos' Primary provider is now GIS" }' 'https://hooks.slack.com/services/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'
    bash /opt/scripting/telegram 'Primary provider is now GIS'
    fi
fi
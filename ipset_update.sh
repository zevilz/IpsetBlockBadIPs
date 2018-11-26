#!/bin/bash
# Ipset Block Bad IPs
# URL: https://github.com/zevilz/IpsetBlockBadIPs
# Author: zEvilz
# License: MIT
# Version: 1.1.0

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

if [ ! $# -eq 1 ]
then
	echo "Period not set!"
	echo "Usage: bash $0 1|7|30|90|180|365"
	exit 1
fi
if [[ $1 != 1 && $1 != 7 && $1 != 30 && $1 != 90 && $1 != 180 && $1 != 365 ]]
then
	echo "Wrong period set!"
	echo "Period must be set to 1 or 7 or 30 or 90 or 180 or 365"
	exit 1
fi
CUR_PATH=$(dirname $0)

echo -n "Download blacklist from stopforumspam.com..."
cd $CUR_PATH
wget -qN http://www.stopforumspam.com/downloads/listed_ip_$1.zip

if ! [ -f listed_ip_$1.zip ]; then

	echo "Can't download!"
	exit 1

else

	unzip -oq listed_ip_$1.zip
	echo "Done"

	echo -n "Applying blacklist to IPSET..."
	ipset -q -N blacklist iphash
	ipset -q -F blacklist
	xfile=$(cat $CUR_PATH/listed_ip_$1.txt)
	for ipaddr in $xfile
	do
		ipset -exist -A blacklist $ipaddr
	done
	echo "Done"

	if [ -f whitelist ]; then
		echo -n "Remove whitelisted IPs from blacklist..."
		wxfile=$(cat $CUR_PATH/whitelist)
		for ipaddr in $wxfile
		do
			ipset del blacklist $ipaddr > /dev/null 2>/dev/null
		done
		echo "Done"
	fi

	echo -n "Applying blacklist to IPTABLES..."
	iptables -I INPUT -m set --match-set blacklist src -j REJECT
	iptables -I INPUT -m set --match-set blacklist src -j LOG --log-prefix "REJECT blacklist entry"
	echo "Done"

	echo -n "Num of blacklisted IPs..."
	sleep 5
	ipset -L blacklist | grep -A999999999 'Members:' | tail -n +2 | wc -l

fi

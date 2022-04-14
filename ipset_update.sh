#!/bin/bash
# Ipset Block Bad IPs
# URL: https://github.com/zevilz/IpsetBlockBadIPs
# Author: zEvilz
# License: MIT
# Version: 1.4.0

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

if [ $# -eq 0 ]; then
	echo "Period not set!"
	echo "Usage: bash $0 1|7|30|90|180|365"
	exit 1
fi

if [[ "$1" != 1 && "$1" != 7 && "$1" != 30 && "$1" != 90 && "$1" != 180 && "$1" != 365 ]]; then
	echo "Wrong period set!"
	echo "Period must be set to 1 or 7 or 30 or 90 or 180 or 365"
	exit 1
fi

LOGGING=0
CUR_PATH=$(dirname $0)

if [[ "$2" == 1 ]]; then
	LOGGING=1
fi

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
	BLACKLIST=$(cat $CUR_PATH/listed_ip_$1.txt)
	for IP in $BLACKLIST
	do
		ipset -exist -A blacklist $IP
	done
	echo "Done"

	if [ -f blacklist ]; then
		echo -n "Add IPs from custom blacklist to IPSET blacklist..."
		CUSTOM_BLACKLIST=$(cat $CUR_PATH/blacklist)
		for IP in $CUSTOM_BLACKLIST
		do
			ipset -exist -A blacklist $IP
		done
		echo "Done"
	fi

	if [ -f whitelist ]; then
		echo -n "Remove whitelisted IPs from IPSET blacklist..."
		WHITELIST=$(cat $CUR_PATH/whitelist)
		for IP in $WHITELIST
		do
			ipset del blacklist $IP > /dev/null 2>/dev/null
		done
		echo "Done"
	fi

	if [[ -z $(iptables -L -n | grep 'match-set blacklist') ]]; then
		echo -n "Applying blacklist to IPTABLES..."
		iptables -I INPUT -m set --match-set blacklist src -j REJECT
		echo "Done"
	fi

	if [ $LOGGING -eq 1 ] && [[ -z $(iptables -L -n | grep 'REJECT blacklist entry') ]]; then
		echo -n "Enabling logging..."
		iptables -I INPUT -m set --match-set blacklist src -j LOG --log-prefix "REJECT blacklist entry"
		echo "Done"
	fi

	if [ $LOGGING -eq 0 ] && ! [[ -z $(iptables -L -n | grep 'REJECT blacklist entry') ]]; then
		echo -n "Disabling logging..."
		iptables -D INPUT -m set --match-set blacklist src -j LOG --log-prefix "REJECT blacklist entry"
		echo "Done"
	fi

	echo -n "Num of blacklisted IPs..."
	IPS_COUNT=$(ipset -L blacklist | grep 'Number of entries' | awk '{print $NF}')
	if ! [ -z "$IPS_COUNT" ]; then
		echo "$IPS_COUNT"
	else
		sleep 5
		ipset -L blacklist | grep -A999999999 'Members:' | tail -n +2 | wc -l
	fi
fi

#!/bin/bash
# Ipset Block Bad IPs
# Author: zEvilz
# License: MIT

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
wget -qN http://www.stopforumspam.com/downloads/listed_ip_7.zip
unzip -oq listed_ip_7.zip
echo "Done"
echo -n "Applying blacklist to IPSET..."
ipset -q -N blacklist iphash
xfile=$(cat $CUR_PATH/listed_ip_7.txt)
for ipaddr in $xfile
do
	ipset -exist -A blacklist $ipaddr
done
echo "Done"
echo -n "Applying blacklist to IPTABLES..."
iptables -I INPUT -m set --match-set blacklist src -j REJECT
iptables -I INPUT -m set --match-set blacklist src -j LOG --log-prefix "REJECT blacklist entry"
echo "Done"
echo -n "Num of blacklisted IPs..."
ipset -L blacklist | grep -A999999999 'Members:' | wc -l
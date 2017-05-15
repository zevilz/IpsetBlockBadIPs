# IpsetBlockBadIPs
Automatic block bad IPs with lists from www.stopforumspam.com

Requirements
------------

- ipset
- unzip
- wget

Configuring
-----------

1. Login server in root user

2. Copy **ipset_update.sh** to other directory on your server.

Usage
-----

### Directly in shell

    bash ipset_update.sh <period>

Example:

    bash ipset_update.sh 7

Supported periods:

- 1 - include IPs list logged within the last 1 day (hourly updates)
- 7 - include IPs list logged within the last 7 day (hourly updates)
- 30 - include IPs list logged within the last 30 day (hourly updates)
- 90 - include IPs list logged within the last 90 day (daily updates)
- 180 - include IPs list logged within the last 180 day (daily updates)
- 365 - include IPs list logged within the last 365 day (daily updates)

Note that there is a limits for day downloading (for the first - 24 daily downloads, for the others - 2 daily downloads). Downloading skip if the local list archive same as in www.stopforumspam.com.

### Cron

Add line in root crontab like below

    0 0 * * * bash /path/to/script/ipset_blacklist/ipset_update.sh 7 # daily updates in 00:00 with including IPs list logged within the last 7 day

If you want receive script result to email add below to the top of crontab list (require working MTA on your server)

    MAILTO=name@domain.com

Checking
--------

There are included logging for IPs blocking. For check type

    grep "REJECT blacklist entry" /path/to/kernel/log

Example:

    grep "REJECT blacklist entry" /var/log/kern.log

Changelog
---------

15.05.2017 - 1.0.1 - added PATH var for fix errors when run via crontab
13.05.2017 - 1.0.0 - released

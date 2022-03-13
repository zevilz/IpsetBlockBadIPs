# IpsetBlockBadIPs [![Version](https://img.shields.io/badge/version-v1.3.0-brightgreen.svg)](https://github.com/zevilz/IpsetBlockBadIPs/releases/tag/1.3.0)
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

### Whitelist

You may create whitelist if you want automatically delete custom IPs from blacklist after it create. Put your IPs in `whitelist` file (one per row) in the same directory and run script. You will see appropriate message during script work.

### Custom blacklist

You may create static blacklist if you want automatically add custom IPs to main blacklist after it create. Put your IPs in `blacklist` file (one per row) in the same directory and run script. You will see appropriate message during script work.

### Cron

Add line in root crontab like below

    0 0 * * * /bin/bash /path/to/script/ipset_update.sh 7 # daily updates in 00:00 with including IPs list logged within the last 7 day

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

- 13.03.2022 - 1.3.0 - added support for custom static blacklist for add to main blacklist
- 11.10.2020 - 1.2.0 - [bugfixes](https://github.com/zevilz/IpsetBlockBadIPs/releases/tag/1.2.0)
- 26.11.2018 - 1.1.0 - added whitelist support and added check for successful list download
- 24.12.2017 - 1.0.4 - fixed wrong number of members in set
- 23.12.2017 - 1.0.3 - fixed wrong number of members in set
- 11.06.2017 - 1.0.2 - added flush set before update blacklist
- 15.05.2017 - 1.0.1 - added PATH var for fix errors when run via crontab
- 13.05.2017 - 1.0.0 - released

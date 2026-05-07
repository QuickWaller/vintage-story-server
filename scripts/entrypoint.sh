#!/bin/bash

# Install crontab for gameserver user and start cron daemon
crontab -u gameserver /srv/gameserver/vintagestory/crontab
service cron start

# Drop to gameserver and run the server
exec su -s /bin/bash gameserver -c /srv/gameserver/vintagestory/check_and_start.sh

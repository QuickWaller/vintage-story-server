#!/bin/bash

LOGS=/srv/gameserver/data/vs/Logs
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "[$TIMESTAMP] Starting log rotation..."

# Compress logs older than 1 day that aren't already compressed
find "$LOGS" -name "*.log" -mtime +1 ! -name "*.gz" -exec gzip -f {} \;

# Delete compressed logs older than 14 days
find "$LOGS" -name "*.gz" -mtime +14 -delete

echo "[$TIMESTAMP] Log rotation complete"

#!/bin/bash

DATA=/srv/gameserver/data/vs
BACKUP_DIR=$DATA/Backups
SAVES_DIR=$DATA/Saves

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup-$TIMESTAMP.tar.gz"

echo "[$TIMESTAMP] Starting backup..."
tar -czf "$BACKUP_FILE" -C "$DATA" Saves

if [ $? -eq 0 ]; then
    SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
    echo "[$TIMESTAMP] Backup complete: $BACKUP_FILE ($SIZE)"
else
    echo "[$TIMESTAMP] Backup FAILED"
    rm -f "$BACKUP_FILE"
    exit 1
fi

# Keep last 7 backups, delete older ones
ls -t "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f
echo "[$TIMESTAMP] Old backups pruned (keeping last 7)"

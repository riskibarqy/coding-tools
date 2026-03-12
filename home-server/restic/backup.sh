#!/bin/sh
set -eu

RESTIC_REPOSITORY="${RESTIC_REPOSITORY:?RESTIC_REPOSITORY must be set}"
RESTIC_PASSWORD="${RESTIC_PASSWORD:?RESTIC_PASSWORD must be set}"

backup_paths="
/backup/config
/backup/postgres
/backup/redis
/backup/mysql
/backup/mongo
/backup/grafana
/backup/prometheus
/backup/tempo
"

if ! restic snapshots >/dev/null 2>&1; then
  restic init
fi

while true; do
  echo "[$(date -Iseconds)] starting restic backup"
  restic backup $backup_paths --tag home-server
  restic forget --keep-last "${RESTIC_KEEP_LAST:-7}" --keep-daily "${RESTIC_KEEP_DAILY:-7}" --prune
  echo "[$(date -Iseconds)] restic cycle complete"
  sleep "${RESTIC_BACKUP_INTERVAL_SECONDS:-86400}"
done

#!/bin/bash

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
ENV="${SCRIPT_DIR}/.env"

# Ensure DATABASE_UTL or load .env file
if ! [ $DATABASE_UTL ]; then
  if [ -f $ENV ]; then
    set -a # set -o allexport
    . ./.env
    set +a
  else
    error "DATABASE_UTL is empty or $(realpath "${ENV}") do not exist or not a file" 
    exit 1
  fi
fi

BACKUP_DIR="${SCRIPT_DIR}/folder"

mkdir -p "${BACKUP_DIR}"

BACKUP_FILE="$BACKUP_DIR/backup-$(date +'%Y-%m-%d-%H-%M-%S').dump"

pg_dump "$DATABASE_URL" -F c -b -v -f "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "Backup completed successfully. Backup saved to: $BACKUP_FILE"
else
  echo "Backup failed."
fi

#!/bin/bash

# PostgreSQL database credentials
DB_USER="your_username"
DB_NAME="your_database_name"
DB_HOST="localhost"  # Change to your database host if necessary
DB_PORT="5432"       # Change to your database port if necessary

# Backup directory
BACKUP_DIR="/path/to/backup/folder"

# Create a folder with the current date as the name
BACKUP_FOLDER="$BACKUP_DIR/$(date +'%Y-%m-%d')"

# Ensure the backup directory exists
mkdir -p "$BACKUP_FOLDER"

# Filename for the backup file
BACKUP_FILE="$BACKUP_FOLDER/$DB_NAME-$(date +'%Y-%m-%d-%H-%M-%S').dump"

# Perform the backup using pg_dump
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -F c -b -v -f "$BACKUP_FILE" "$DB_NAME"

# Check if the backup was successful
if [ $? -eq 0 ]; then
  echo "Backup completed successfully. Backup saved to: $BACKUP_FILE"
else
  echo "Backup failed."
fi

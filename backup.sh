#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Will be name of directory in backet dd-mm-yyyy_hh-mm-ss
    timestamp=$(date +%d-%m-%Y_%H-%M-%S)

# Export stuff
    export PGPASSWORD=$POSTGRES_PASSWORD

# Will create base backup
    echo "Creating backup of $POSTGRES_DB database..."
    pg_dump --username $POSTGRES_USER \
            -h $POSTGRES_HOST \
            -p $POSTGRES_PORT \
            -d $POSTGRES_DB \
            $POSTGRES_EXTRA_OPTS \
            > $POSTGRES_DB.sql
# Do compression
    tar -czvf $POSTGRES_DB.$BACKUP_SUFFIX $POSTGRES_DB.sql

# Set S3 connection configuration
    mcli alias set backup $S3_ENDPOINT $S3_ACCESS_KEY_ID $S3_SECRET_ACCESS_KEY

# Create the bucket
    mcli mb backup/$S3_BUCKET
    mcli cp $POSTGRES_DB.$BACKUP_SUFFIX backup/$S3_BUCKET/$timestamp/$POSTGRES_DB.$BACKUP_SUFFIX

# Do nettoyage
    echo "Maid is here... Doing cleaning..."
    rm -f $POSTGRES_DB.*

#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
RETRY=$DIR/../common/retry
e "Creating nova and glance databases."
mysql -u $SETUP_DB_USERNAME -p$SETUP_DB_PASSWORD -e "drop database if exists nova; drop database if exists glance; drop database if exists melange; create database nova; create database glance; create database melange; create database quantum;"
chex $? "Error creating databases"

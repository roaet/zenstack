#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
RETRY=$DIR/../common/retry
OSDIR="$HOME/openstack"
PREVDIR=`pwd`
if [ ! -d $OSDIR ]; then
    mkdir $OSDIR 
    chex $? "Could not make OS Dir"
fi
LAUNCHERDIR="$DIR/../launchers"
TEMP="$LAUNCHERDIR-temp"
LAUNCHTOOL=novatools/nova_launcher_tmux.sh
if [ -d $TEMP ]; then
    rm -rf $TEMP
fi
mkdir $TEMP
chex $? "Could not make $TEMP"
cp_ -r $LAUNCHERDIR/* $TEMP
sed_sub "s|OPENSTACK_DIR|$OSDIR|g" "$TEMP/$LAUNCHTOOL"
sed_sub "s/XENSERVER_IP/$SETUP_XEN_IP/g" "$TEMP/$LAUNCHTOOL"
sed_sub "s/DBUSER/$SETUP_DB_USERNAME/g" "$TEMP/$LAUNCHTOOL"
sed_sub "s/DBPASS/$SETUP_DB_PASSWORD/g" "$TEMP/$LAUNCHTOOL"
sed_sub "s/YOUR-XEN-PASSWORD/$SETUP_XEN_PASSWORD/g" "$TEMP/$LAUNCHTOOL"
cp_ -r $TEMP/* $OSDIR/launchers

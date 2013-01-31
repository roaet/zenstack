#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
PREVDIR=`pwd`
OSDIR="$HOME/openstack"
GLANCEDIR="$OSDIR/glance"
KEYSTONEDIR="$OSDIR/keystone"
NOVADIR="$OSDIR/nova"
QUANTUMDIR="$OSDIR/quantum"
LAUNCHERDIR="$OSDIR/launchers"

e "Installing tools"
# COPY KEYSTONE STUFF
cp_ $DIR/../tools/keystone_setup.sh $KEYSTONEDIR
chmod +x $KEYSTONEDIR/keystone_setup.sh

#COPY LAUNCHER STUFF
cp_ $DIR/../tools/firstrun.sh $LAUNCHERDIR
chmod +x $LAUNCHERDIR/firstrun.sh
if [ -f ~/firstrun.sh ]; then
    rm ~/firstrun.sh
fi
ln -s $LAUNCHERDIR/firstrun.sh ~/firstrun.sh
e "Finished!"

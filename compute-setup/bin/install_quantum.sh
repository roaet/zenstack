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
    chex $? "Could not make OS dir"
fi
QUANTUMDIR="$OSDIR/quantum"
if [ -d $QUANTUMDIR ]; then
    rm -rf $QUANTUMDIR
fi
git clone https://github.com/openstack/quantum.git $QUANTUMDIR
chex $? "error git clone quantum.git"
sudo chown -R $SETUP_VM_USERNAME:$SETUP_VM_USERNAME $QUANTUMDIR
chex $? "chown $QUANTUMDIR"
virtualenv $QUANTUMDIR/.venv --prompt="(quantum)"
chex $? "error make virtualenv"
cd_ $QUANTUMDIR
chex $? "error cd $QUANTUMDIR"
source .venv/bin/activate --no-site-packages
chex $? "error activate venv"
GHINTERNAL=`checkforhost github.rackspace.com`
if [ "$GHINTERNAL" = "0" ]; then
    git remote add o3eng https://github.rackspace.com/O3Eng/quantum.git
    git checkout master
    git branch -D development
    git fetch o3eng
    git checkout -b development o3eng/development
fi
pip_install -r tools/pip-requires
pip_install tox
pip_install mysql-python
pip_install -r tools/test-requires
pip_install ./
chex $? "error install"
if [ $SETUP_DO_TEST -eq 1 ]; then
    tox -r -e py26
fi
deactivate
chex $? "error deactivate"
if [ -d $HOME/.quantum ]; then
    rm -rf $HOME/.quantum
fi
mkdir $HOME/.quantum
chex $? "error mkdir ~/.quantum"
cp -r $QUANTUMDIR/etc/* $HOME/.quantum
chex $? "error cp quantum/etc"
QUANTUMCONF="$DIR/../defconfs/quantum.conf"
TEMPCONF="$DIR/../defconfs/quantum.conf.temp"
cp_ $QUANTUMCONF $TEMPCONF
sed_sub "s/%SERVICE_TENANT_NAME%/openstack/" $HOME/.quantum/api-paste.ini
sed_sub "s/%SERVICE_USER%/admin/" $HOME/.quantum/api-paste.ini
sed_sub "s/%SERVICE_PASSWORD%/password/" $HOME/.quantum/api-paste.ini
sed_sub "s/DBUSER/$SETUP_DB_USERNAME/" $TEMPCONF
sed_sub "s/DBPASS/$SETUP_DB_PASSWORD/" $TEMPCONF
sed_sub "s/auth_strategy = noauth/auth_strategy=keystone/" $TEMPCONF
sed_sub "s/auth_admin_password = secrete/auth_admin_password=password/" $TEMPCONF
cp_ $TEMPCONF $OSDIR/quantum.conf
chex $? "error cp $TEMPCONF"
if [ -f $HOME/.quantum/quantum.conf ]; then
    rm $HOME/.quantum/quantum.conf
fi
ln -s $OSDIR/quantum.conf $HOME/.quantum/quantum.conf
chex $? "error symlink quantum.conf"
if [ -d /etc/quantum ]; then
    sudo rm -rf /etc/quantum
fi
sudo ln -s $HOME/.quantum /etc/quantum
chex $? "error symlink quantum"
e "installing quark plugin"
git clone https://github.com/jkoelker/quark.git
cd_ quark
python setup.py develop
cd_ -

e "Creating /var/lib/quantum"
sudo mkdir /var/lib/quantum
sudo chown $SETUP_VM_USERNAME:$SETUP_VM_USERNAME /var/lib/quantum

cd_ $PREVDIR
chex $? "error cd $PREVDIR"

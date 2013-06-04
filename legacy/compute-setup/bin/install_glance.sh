#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
OSDIR="$HOME/openstack"
PREVDIR=`pwd`
if [ ! -d $OSDIR ]; then
    mkdir $OSDIR 
    chex $? "Error mkdir OS"
fi
GLANCEDIR="$OSDIR/glance"
if [ -d $GLANCEDIR ]; then
    rm -rf $GLANCEDIR
    chex $? "Error rm glance dir"
fi
git clone https://github.com/openstack/glance.git $GLANCEDIR
chex $? "Error cloning glance"
virtualenv $GLANCEDIR/.venv --prompt="(glance)"
chex $? "Error creating venv"
cd_ $GLANCEDIR
ETCWORK=etc_working
source .venv/bin/activate --no-site-packages
pip install --upgrade distribute
chex $? "Error activating venv"
cp_ -r etc $ETCWORK
IMAGE_DIR="$GLANCEDIR/images"
IMAGECACHE_DIR="$GLANCEDIR/image-cache"
if [ ! -d $IMAGE_DIR ]; then
    mkdir $IMAGE_DIR
fi
if [ ! -d $IMAGECACHE_DIR ]; then
    mkdir $IMAGECACHE_DIR
fi
USER="$SETUP_VM_USERNAME"

if [ $USER = "root" ]; then
    HOMEDIR="/root/openstack/"
else
    HOMEDIR="/home/$USER/openstack/"
fi
sed_sub "s|image_cache_dir = .*$|image_cache_dir = $IMAGE_DIR|" $ETCWORK/glance-*.conf
sed_sub "s|filesystem_store_datadir = .*$|filesystem_store_datadir = IMAGECACHE_DIR|" $ETCWORK/glance-*.conf
e "Setting mysql authentication settings:"
MYSQL_A="mysql://"
MYSQL_CRED="$SETUP_DB_USERNAME:$SETUP_DB_PASSWORD"
MYSQL_N="@127.0.0.1/glance"

sed_sub "s|sql_connection = .*$|sql_connection = $MYSQL_A$MYSQL_CRED$MYSQL_N|" $ETCWORK/glance-*.conf

e "FYI: Will require super-user to copy configuration to /etc."
if [ -d /etc/glance ]; then
    sudo rm -rf /etc/glance
fi
sudo mkdir /etc/glance
chex $? "error mkdir /etc/glance"
echo "FYI: created /etc/glance"
sudo cp $ETCWORK/* /etc/glance
chex $? "Error moving $ETCWORK files to /etc/glance"
e "FYI: moved configuration files to /etc/glance"
pip_install -r tools/pip-requires
pip_install tox
pip_install mysql-python
pip_install python-glanceclient
pip_install keyring
pip_install -r tools/test-requires
pip_install ./
chex $? "error install setup"
if [ $SETUP_DO_TEST -eq 1 ]; then
    tox -r -e py26
fi
sudo mkdir -p /var/log/glance
chex $? "error mkdir /var/log/glance"
sudo chown compute:compute -R /var/log/glance
chex $? "error chown compute"
sudo mkdir -p /var/lib/glance
chex $? "error mkdir /var/lib/glance"
sudo chown compute:compute -R /var/lib/glance
chex $? "error chown compute"
deactivate

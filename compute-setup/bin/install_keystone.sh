#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
OSDIR="$HOME/openstack"
ETCWORK=etc_working
PREVDIR=`pwd`
if [ ! -d $OSDIR ]; then
    mkdir $OSDIR 
    chex $? "Error mkdir OS"
fi
KEYSTONEDIR="$OSDIR/keystone"
if [ -d $KEYSTONEDIR ]; then
    rm -rf $KEYSTONEDIR
    chex $? "Error rm glance dir"
fi
git clone https://github.com/openstack/keystone.git $KEYSTONEDIR
chex $? "Error cloning keystone"
virtualenv $KEYSTONEDIR/.venv --prompt="(keystone)"
chex $? "Error creating venv"
cd_ $KEYSTONEDIR
source .venv/bin/activate --no-site-packages
chex $? "Error activating venv"
cp_ -r etc $ETCWORK
mv $ETCWORK/keystone.conf.sample $ETCWORK/keystone.conf
e "Setting mysql authentication settings:"
MYSQL_A="mysql://"
MYSQL_CRED="$SETUP_DB_USERNAME:$SETUP_DB_PASSWORD"
MYSQL_N="@127.0.0.1/keystone"

sed_sub "s|connection = .*$|connection = $MYSQL_A$MYSQL_CRED$MYSQL_N|" $ETCWORK/keystone.conf
sed_sub "s/#token_format = PKI/token_format = UUID/" $ETCWORK/keystone.conf

e "FYI: Will require super-user to copy configuration to /etc."
if [ -d /etc/keystone ]; then
    sudo rm -rf /etc/keystone
fi
sudo mkdir /etc/keystone
chex $? "error mkdir /etc/keystone"
echo "FYI: created /etc/keystone"
sudo cp $ETCWORK/* /etc/keystone
chex $? "Error moving $ETCWORK files to /etc/keystone"
e "FYI: moved configuration files to /etc/keystone"
pip_install -r tools/pip-requires
pip_install tox
pip_install mysql-python
pip_install keyring
pip_install ./
chex $? "error install setup"
if [ $SETUP_DO_TEST -eq 1 ]; then
    tox -r -e py26
fi
sudo mkdir -p /var/log/keystone
chex $? "error mkdir /var/log/keystone"
sudo chown compute:compute -R /var/log/keystone
chex $? "error chown compute"

#e "Upgrading openssl"
#wget http://ftp.us.debian.org/debian/pool/main/e/eglibc/multiarch-support_2.13-38_amd64.deb
#wget http://ftp.us.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1c-4_amd64.deb
#wget http://ftp.us.debian.org/debian/pool/main/o/openssl/openssl_1.0.1c-4_amd64.deb
#sudo dpkg --install multiarch-*.deb
#sudo dpkg --install libssl*.deb
#sudo dpkg --install openssl_*.deb

deactivate

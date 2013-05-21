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
    chex $? "Cannot make OS Dir"
fi
NOVADIR="$OSDIR/nova"
if [ -d $NOVADIR ]; then
    rm -rf $NOVADIR
fi
git clone https://github.com/openstack/nova.git $NOVADIR
chex $? "error clone nova.git"
virtualenv $NOVADIR/.venv --prompt="(nova)"
chex $? "error make virtualenv"
cd_ $NOVADIR
chex $? "error cd $NOVADIR"
source .venv/bin/activate --no-site-packages
pip install --upgrade distribute
chex $? "error activate venv"
GHINTERNAL=`checkforhost github.rackspace.com`
if [ "$GHINTERNAL" = "0" ]; then
    git remote add o3eng https://github.rackspace.com/O3Eng/nova.git
    git checkout master
    git branch -D development
    git fetch o3eng
    git checkout -b development o3eng/development
fi
pip_install -r tools/pip-requires
pip_install tox
pip_install XenAPI "setuptools-git>=0.4" simplejson "requests<1.0" prettytable "warlock<2"
pip_install pyOpenSSL pyparsing "cliff>=1.2.1" "pycrypto>=2.1,!=2.4" "Tempita>=0.4"
pip_install decorator ordereddict importlib "amqp>=1.0.5,<1.1.0" "Markdown>=2.0.1"
pip_install mysql-python
pip_install python-novaclient
pip_install "kombu==2.4.7"
pip_install -r tools/test-requires
pip_install ./
chex $? "error install"
if [ $SETUP_DO_TEST -eq 1 ]; then
    tox -r -e py26
fi
cd_ $PREVDIR
chex $? "error cd $PREVDIR"
deactivate

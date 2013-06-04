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
    chex $? "Could notmake OS dir"
fi
MELANGEDIR="$OSDIR/melange"
if [ -d $MELANGEDIR ]; then
    rm -rf $MELANGEDIR
fi
git clone https://github.com/openstack/melange.git $MELANGEDIR
chex $? "error clone melange.git"
virtualenv $MELANGEDIR/.venv --prompt="(melange)"
chex $? "error make virtualenv"
cd_ $MELANGEDIR
source .venv/bin/activate --no-site-packages
pip install --upgrade distribute
chex $? "error activate venv"
GHINTERNAL=`checkforhost github.rackspace.com`
if [ "$GHINTERNAL" = "0" ]; then
    git remote add o3eng https://github.rackspace.com/O3Eng/melange.git
    git checkout master
    git branch -D development
    git fetch o3eng
    git checkout -b development o3eng/development
fi
pip_install -r tools/pip-requires
pip_install tox httplib2 factory-boy webtest sphinx netaddr sqlalchemy-migrate
pip_install -r tools/test-requires
pip_install ./
chex $? "error install"
pip uninstall -y sqlalchemy
pip_install mysql-python
pip_install sqlalchemy==0.7.9
chex $? "sqlalchemy 0.7.9 failed"
#if [ $SETUP_DO_TEST -eq 1 ]; then
#    tox -r -e py26
#fi
cp_ etc/melange/melange.conf.sample ~/melange.conf
deactivate

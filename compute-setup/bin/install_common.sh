#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
apt_get_install_all git-core git build-essential rabbitmq-server unzip swig screen wget parted curl python-pip python-dev libxml2 libxml2-dev libxslt1.1 libxslt1-dev vim sudo tmux
sudo apt-get -y install euca2ools
chwa $? "apt-get euca2ools"
mysql_uninstall_reinstall
chex $? "error with mysql uninstall reinstall"
sudo apt-get -y install python-mysqldb libmysqlclient-dev
chex $? "apt-get python-mysqldb libmysqlclient-dev"
sudo apt-get -y install ipython
chex $? "apt-get ipython"
sudo apt-get -y install htop
chex $? "apt-get htop"
sudo apt-get -y install bash-completion
chex $? "apt-get bash-completion"
pip_install virtualenv

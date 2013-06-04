#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
RETURN=0
rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
#chex $? "Could not get epel.rpm"
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
#chex $? "Could not get remi rpm"
sed_sub "s/enabled=0/enabled=1/" /etc/yum.repos.d/CentOS-Base.repo
yum -y -v groupinstall "Development Tools" 
chex $? "Error installing development tools"
yum -y -v install git
chex $? "Error installing git"
yum -y -v install httpd
chex $? "Error installing httpd"
yum -y -v install php php-cli php-gd php-mbstring
chex $? "Error installing php"
sed_sub "s/Listen 80$/Listen 8080/" /etc/httpd/conf/httpd.conf
service iptables stop
#chex $? "Error stopping iptables"
service httpd restart
chex $? "Error restarting httpd"
sed_sub "s/enabled=1/enabled=0/" /etc/yum.repos.d/CentOS-Base.repo
exit $RETURN

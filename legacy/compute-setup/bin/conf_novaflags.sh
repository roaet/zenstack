#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PREVDIR=`pwd`
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
RETRY=$DIR/../common/retry
if [ ! -d ~/openstack ]; then
    mkdir ~/openstack
    chex $? "Could not make OS dir"
fi
cd_ ~/openstack
e "Setting mysql authentication settings:"
MYSQL_A="mysql://"
MYSQL_CRED="$SETUP_DB_USERNAME:$SETUP_DB_PASSWORD"
MYSQL_N="@127.0.0.1/nova"
xenapi_ip=$SETUP_XEN_IP
e "Setting xen authentication settings:"
XEN_USER="$SETUP_XEN_USERNAME"
XEN_PASS="$SETUP_XEN_PASSWORD"
FILENAME="$DIR/../defconfs/nova.conf"
WORKING="$DIR/../defconfs/nova-working.conf"
CONF=~/openstack/nova.conf
MYSQL="$MYSQL_A$MYSQL_CRED$MYSQL_N"
cp_ $FILENAME $WORKING
sed_sub "s|sql_connection=.*$|sql_connection=$MYSQL|" $WORKING
sed_sub "s|xenapi_connection_url=.*$|xenapi_connection_url=https://$xenapi_ip|" $WORKING
sed_sub "s|xenapi_connection_username=.*$|xenapi_connection_username=$XEN_USER|" $WORKING
sed_sub "s|xenapi_connection_password=.*$|xenapi_connection_password=$XEN_PASS|" $WORKING
chex $? "Error sub xenpass"
IP=`getip eth0`
sed_sub "s|glance_api_servers=.*$|glance_api_servers=$IP:9292|" $WORKING

e "FYI: Will require super-user to copy configuration to /etc."
if [ -d /etc/nova ]; then
    sudo rm -rf /etc/nova
fi
sudo mkdir /etc/nova
chex $? "Error mkdir nova"
e "FYI: created /etc/nova"
cp_ $WORKING $CONF
chex $? "Error cp $WORKING to $CONF"
if [ -f /etc/nova/nova.conf ]; then
    sudo rm /etc/nova/nova.conf
fi
sudo ln -s $CONF /etc/nova/nova.conf
chex $? "Error symlink $CONF"
e "FYI: made symlink to $CONF in /etc/nova"

cp_ ~/openstack/nova/etc/nova/api-paste.ini ~/openstack/
chex $? "Error cp api-paste"

sed_sub "s/%SERVICE_TENANT_NAME%/openstack/" ~/openstack/api-paste.ini
sed_sub "s/%SERVICE_USER%/admin/" ~/openstack/api-paste.ini
sed_sub "s/%SERVICE_PASSWORD%/password/" ~/openstack/api-paste.ini


if [ -f /etc/nova/api-paste.ini ]; then
    sudo rm /etc/nova/api-paste.ini
fi
sudo ln -s ~/openstack/api-paste.ini /etc/nova/
chex $? "Error symlink api-paste"
e "FYI: made symlink to api-paste.ini in/etc/nova"

cp_ ~/openstack/nova/etc/nova/policy.json ~/openstack/
chex $? "Error cp policy"
if [ -f /etc/nova/policy.json ]; then
    sudo rm /etc/nova/policy.json
fi
sudo ln -s ~/openstack/policy.json /etc/nova/
chex $? "Error symlink policy"
e "FYI: made symlink to policy.json in/etc/nova"

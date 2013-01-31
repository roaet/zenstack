#!/bin/bash
set +v
# some default variables
RETURN=0
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
HTTPDIR=/var/www/html
REPO="http://ftp.us.debian.org/debian/"
OS="Debian Squeeze 6.0 (64-bit)"

DATETIME=`date +%H%M%S`

BASIC="-- quiet console=hvc0 auto=true"
NETWORK="console-setup/ask_detect=false interface=eth0 netcfg/get_hostname=$HOSTNAME netcfg/get_domain=$DOMAIN" 
VMUUID=`xe vm-install template="$OS" new-name-label=$NAME`
xe vm-param-set uuid=$VMUUID other-config:install-repository=$REPO
chex $? "Error setting VM install repo"
xe vm-param-set uuid=$VMUUID PV-args="$BASIC $NETWORK preseed/url=http://$XEN_IP:8080/preseed.cfg"
chex $? "Error setting preseed url"
xe vm-param-set uuid=$VMUUID VCPUs-params:weight=65535
chex $? "Error setting VCPU param"
xe vm-memory-limits-set uuid=$VMUUID static-min=$RAM dynamic-min=$RAM dynamic-max=$RAM static-max=$RAM
chex $? "Error setting memory limits"

VBD_UUID=`xe vbd-list vm-uuid=$VMUUID empty=false | grep "^uuid" | awk '{print $5}'`
SR_UUID=`xe sr-list name-label="Local storage" | grep "^uuid" | awk '{print $5}'`

xe vbd-param-set uuid=$VBD_UUID qos_algorithm_type=ionice
chex $? "Error setting qos_algo"
xe vbd-param-set uuid=$VBD_UUID qos_algorithm_params:sched=rt
chex $? "Error setting qos_algo_param:sched"
xe vbd-param-set uuid=$VBD_UUID qos_algorithm_params:class=7
chex $? "Error setting qos_algo_param:class"
xe sr-param-set uuid=$SR_UUID other-config:scheduler=cfq
chex $? "Error setting scheduler"

e "Adding network to VM with vif:"
xe vif-create network-uuid=`xe network-list bridge=xenbr0 --minimal` vm-uuid=$VMUUID device=0
chex $? "Error creating vif"

e "Creating preseed file"
# need to get the gateway
GATEWAY=`route -n | grep "UG" | awk '{print $2}'`

TEMP=$DIR/preseed-temp.cfg
cp_ $DIR/preseed.cfg $TEMP
sed_sub "s/YOUR-HOSTNAME/$HOSTNAME/g" $TEMP
sed_sub "s/YOUR-DOMAIN/$DOMAIN/g" $TEMP
sed_sub "s/YOUR-ROOT-PASSWORD/$ROOT_PASS/g" $TEMP
sed_sub "s/YOUR-FULLNAME/$USERFULLNAME/g" $TEMP
sed_sub "s/YOUR-USERNAME/$USERNAME/g" $TEMP
sed_sub "s/YOUR-PASSWORD/$USERPASS/g" $TEMP
sed_sub "s/YOUR-VM-IP/$VM_IP/g" $TEMP
sed_sub "s/YOUR-VM-HM/$VM_HM/g" $TEMP
sed_sub "s/YOUR-GATEWAY/$GATEWAY/g" $TEMP
sed_sub "s/YOUR-XEN-IP/$XEN_IP/g" $TEMP

cp_ $TEMP $HTTPDIR/preseed.cfg
rm $TEMP
e "Creating setup archive"
TEMP=$DIR/setup.tar.gz
TEMPSETUP=$DIR/temp-compute
TEMPCOMMON="$TEMPSETUP/common/common.sh"
cp_ -r $DIR/../compute-setup $TEMPSETUP
cp_ -r $DIR/../common $TEMPSETUP

sed_sub "s/YOUR-XEN-USERNAME/$XEN_USER/" $TEMPCOMMON
sed_sub "s/YOUR-XEN-PASSWORD/$XEN_PASS/" $TEMPCOMMON
sed_sub "s/YOUR-DB-USERNAME/$MYSQLUSER/" $TEMPCOMMON
sed_sub "s/YOUR-DB-PASSWORD/$MYSQLPASS/" $TEMPCOMMON
sed_sub "s/YOUR-XEN-IP/$XEN_IP/" $TEMPCOMMON
sed_sub "s/YOUR-USERNAME/$USERNAME/" $TEMPCOMMON
#sed_sub "s/YOUR-GITHUB-USERNAME/$GITHUB_USER/" $TEMPCOMMON
#sed_sub "s/YOUR-GITHUB-PASSWORD/$GITHUB_PASS/" $TEMPCOMMON
cd_ $DIR
chex $? "Error cd $DIR"
tar -zcf $TEMP temp-compute
chex $? "Error making temp-compute tar"
cp_ $TEMP $HTTPDIR/setup.tar.gz
cd_ -
chex $? "Error prev dir"
rm -f $TEMP
rm -rf $TEMPSETUP
export UUID=$VMUUID
e "Starting VM, this may take awhile..."
xe vm-start uuid=$VMUUID
chex $? "Error vm-start for $VMUUID"
e "Letting VM spin up"
sleep 30s
xe vm-param-set uuid=$VMUUID PV-args="-- quiet console=hvc0"
chex $? "Error unsetting preseed setting"
e "Installing Nova xen plugins. This may take awhile."
TEMPNOVA=nova
GIT_SSL_NO_VERIFY=true git clone https://github.com/openstack/nova.git $TEMPNOVA
chex $? "Error cloning nova.git"
cp_ -r $TEMPNOVA/plugins/xenserver/xenapi/etc/* /etc/
rm -rf $TEMPNOVA
chmod a+x /etc/xapi.d/plugins/*
chex $? "Error chmod plugins"
sed_sub "s/enabled=0/enabled=1/" /etc/yum.repos.d/CentOS-Base.repo
chex $? "Error sub yum enable toggle"
yum -y install parted
chex $? "Error install parted"
if [ ! -d /boot/guest ]; then
    mkdir /boot/guest
    chex $? "Error creating guest dir"
fi
sed_sub "s/enabled=1/enabled=0/" /etc/yum.repos.d/CentOS-Base.repo
SRUUID=`xe sr-list name-label="Local storage" --minimal`
xe sr-param-set uuid=$SRUUID other-config:i18n-key=local-storage
e "Created $OS VM with $RAM RAM named $NAME"
e "UUID: $VMUUID"
e "At this point you should be able to access the VM's installer network console"
e "             ssh installer@$VM_IP"
e "then select: open shell"
e "then:        tail -f /var/log/syslog"
exit $RETURN

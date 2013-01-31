#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
RETURN=0
VMTOOLS=`vmware-toolbox --version`

if [ ! -z "$VMTOOLS" ]; then
	e "VMTools installed. Exiting"
	exit $RETURN
fi

echo "Mounting vmware tools. Please mount VMWare Tools from VM menu"

read -p "Press [Enter] when finished"
if [ ! -d "/mnt/cdrom" ]; then
	mkdir /mnt/cdrom
    chex $? "Could not make /mnt/cdrom"
fi
mount /dev/cdrom /mnt/cdrom
chex $? "Could not mount cdrom"

cp_ /mnt/cdrom/VMwareTools*.tar.gz .
tar -zxvf VMwareTools*.tar.gz
chex $? "Could not extract VMwareTools"
TOOLS_INSTALL=`find -iname "vmware-install.pl"`
KERN=`find /usr/src/kernels -iname "2.6.*xen*"`
e "If it cannot find the headers use $KERN/include"
$TOOLS_INSTALL
MOUNTS=`mount | grep "/mnt/cdrom" -c`
if [ ! $MOUNTS -eq 0 ]; then
	umount /mnt/cdrom
fi
exit $RETURN

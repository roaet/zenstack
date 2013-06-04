#!/bin/bash
set +v
RETURN=0
ISDONE=`find /usr/src/kernels -iname "2.6.*xen*" | grep "." -c`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
if [ $ISDONE -eq 1 ]; then
	e "Already have kernel headers. Exiting"
	exit $RETURN
fi
if [ -f "$DIR/../kernelheaders.tar.gz" ]; then
    e "Kernel headers already extracted. Using those"
    tar -zxf "$DIR/../kernelheaders.tar.gz"
    chex $? "Could not extract kernel headers"
    cp_ -r 2.6.*xen-i686 /usr/src/kernels/
    exit $RETURN
fi
exit 1
if [ ! -d "/mnt/ddk" ]; then
	mkdir /mnt/ddk
    chex $? "Could not mkdir ddk"
fi
DDK=`find -iname "xenserver*ddk.iso"`
if [ -n $DDK ]; then
	MOUNTS=`mount | grep "/mnt/ddk" -c`
	if [ $MOUNTS -eq 0 ]; then
		mount $DDK /mnt/ddk -o loop
        chex $? "Could not mount DDK"
	fi
	e "Importing VM, this will take a few minutes"
	DDK_VM_UUID=`xe vm-import filename=/mnt/ddk/ddk/ova.xml`
	NETWORK_UUID=`xe network-list bridge=xenbr0 | grep '^uuid' | awk '{print $5}'`
	e "DDK-UUID: $DDK_VM_UUID"
	e "NET-UUID: $NETWORK_UUID"
	
	VIF_UUID=`xe vif-create network-uuid=$NETWORK_UUID vm-uuid=$DDK_VM_UUID device=0`
	xe vm-start uuid=$DDK_VM_UUID
    chex $? "Could not start ddk vm"
	killall vncterm
	DDK_VM_DOMAIN=`list_domains | grep $DDK_VM_UUID | awk '{print $1}'`
	IP=`ifconfig | grep -i "mask:255.255.255.0" | awk -F : '{print $2}' | awk '{print $1}'`
	e "Waiting for VM to spin up (1-minute or so)..."
	sleep 1m
	e "======================================================"
	e "You will now need to enter another session on this xs."
	e "This xs IP is $IP"
	e "From that session perform the following:"
	e "/usr/lib/xen/bin/xenconsole $DDK_VM_DOMAIN "
	e "# it will request some username/password stuff"
	e "# if it does not respond after a few minutes, hit enter"
	e "scp -r /usr/src/kernels/2.6.*xen-i686 $IP:/usr/src/kernels"
	e "exit"
	e "Break out of XenConsole with CTRL+]"
	e "======================================================"
	read -p "Press [Enter] key to end DDK work"	
	
	e "Performing clean-up"
	xe vm-shutdown uuid=$DDK_VM_UUID
	xe vm-destroy uuid=$DDK_VM_UUID
else
	e "ERROR: Could not find iso"
	RETURN=1
fi

MOUNTS=`mount | grep "/mnt/ddk" -c`
if [ ! $MOUNTS -eq 0 ]; then
	umount /mnt/ddk
fi
exit $RETURN

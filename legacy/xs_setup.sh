#!/bin/bash
set +v
source common/common.sh
DATETIME=`date +%H%M%S`
export XEN_IP=`getip "xenbr0"`
IFS="." read -a ip_parts <<< "$XEN_IP"
DEFAULT_IP="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.169"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export NAME=`prompt_default "Enter name of new vm" "compute-$DATETIME"`
export HOSTNAME=`prompt_default "Enter the hostname of the new vm" "localhost"`
export DOMAIN=`prompt_default "Enter the domain of the new vm" "localdomain"`
export ROOT_PASS=`prompt_default "Enter password of the root user" "password"`
export USERFULLNAME=`prompt_default "Enter full name of primary user" "compute"`
export VM_IP=`prompt_default "Enter the IP of the new vm" "$DEFAULT_IP"`
export VM_HM=`prompt_default "Enter the netmask of the new vm" "255.255.255.0"`
export USERNAME=`prompt_default "Enter the username of primary user (not root)" "compute"`
export USERPASS=`prompt_default "Enter the password of primary user" "password"`
export RAM_VALUE=`prompt_default "How much ram should the VM have (normal limits please)" "512"`
export MYSQLUSER=`prompt_default "Enter username for mysql install on new vm" "root"`
export MYSQLPASS=`prompt_default "Enter password for mysql install on new vm" "password"`
UNAME=`whoami`
export XEN_USER=`prompt_default "Enter your username for this xen server" "$UNAME"`
export XEN_PASS=`prompt_default "Enter your password for this xen server" "password"`
#export GITHUB_USER=`prompt "Enter your github.rackspace.com username"`
#export GITHUB_PASS=`prompt_pass_confirm "Enter your github.rackspace.com password"`
e "Found IP: $XEN_IP"
export RAM_EXT="MiB"
export RAM="$RAM_VALUE$RAM_EXT"
export PREPROMPT=1

RESP=`prompt_confirm "Are the settings correct?"`
if [ $RESP -eq 1 ]; then
    e "Escape!"
    exit 1
fi
if [ -f "$DIR/license.txt" ]; then 
    run_step "xs_license_apply.sh"
fi
run_step "xs_vmware_devsetup.sh"
#run_step "xs_vmware_ddk.sh"
run_step "xs_vmware_tools.sh"
run_step "xs_compute_install.sh"
echo "all done :)"

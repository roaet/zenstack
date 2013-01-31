#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
RETRY=$DIR/../common/retry
e "Updating the apt sources"
if [ -f /etc/apt/sources.list ]; then
	e "Sources exists"
	ADDED=`cat /etc/apt/sources.list | grep -c "ubuntu"`
	if [ $ADDED -eq 0 ]; then
		e "Adding maverick sources"
		echo "deb http://ppa.launchpad.net/nova-core/trunk/ubuntu maverick main" >> /etc/apt/sources.list
	fi 
	e "Adding key for maverick sources"
	e "Getting key, this will take time..."
	KEY=`apt-get update 2>&1 | awk '/PUBKEY/ {print $NF}'`
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $KEY
	e "Running apt-get update"
	apt-get update
    chex $? "Error running apt-get update"
fi
if [ ! -f /etc/apt/sources.list.d/folsom.list ]; then
    sudo touch /etc/apt/sources.list.d/folsom.list
    echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/folsom main" |\
    sudo tee -a /etc/apt/sources.list.d/folsom.list
    e "Adding key for quantum sources"
    e "getting key, this will take time..."
	KEY=`apt-get update 2>&1 | awk '/PUBKEY/ {print $NF}'`
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $KEY
	e "Running apt-get update"
	apt-get update
fi

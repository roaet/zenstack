#!/bin/bash
set +v
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../common/common.sh
if [ $? -ne 0 ]; then
    echo "Fatal Error: Could not source common"
    exit 1
fi
LICENSE="$DIR/../license.txt"
HOST_UUID=`xe host-list | grep "^uuid" | awk '{print $5}'`
xe host-license-add host-uuid=$HOST_UUID license-file=$LICENSE
chex $? "Could not add license"
exit 0

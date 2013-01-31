#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
export SETUP_ROOT_DIR="$DIR"
COMMON_DIR=$DIR/common
if [ ! -d $COMMON_DIR ]; then
    echo "Could not locate common. Failing"
    exit 1
fi
source $DIR/common/common.sh
sudo chown -R $SETUP_VM_USERNAME:$SETUP_VM_USERNAME $SETUP_ROOT_DIR
chex $? "Problem setting ownership"
export SETUP_DO_TEST=1

for arg in "$@"
do
    if [ $arg = 'notest' ]; then
        e "Not running tests"
        export SETUP_DO_TEST=0
    fi
done
export SETUP_DO_TEST=0

if [ -d "$HOME/.pip" ]; then
    rm -rf $HOME/.pip
fi
mkdir $HOME/.pip
mkdir $HOME/.pip/download-cache
cat > $HOME/.pip/pip.conf << EOF
[global]
index-url = http://d.pypi.python.org/simple
timeout = 60
                                                    
[install]
download-cache=$HOME/.pip/download-cache 
use-mirrors = true
mirrors =
    http://b.pypi.python.org/
    http://pypi.openstack.org/
EOF

run_step_sudo "update_sources.sh"
run_step_sudo "install_common.sh"
run_step "install_nova.sh"
run_step "install_glance.sh"
run_step "setup_mysql.sh"
run_step "conf_novaflags.sh"
run_step "install_quantum.sh"
run_step "install_melange.sh"
run_step "install_launchers.sh"
run_step "install_keystone.sh"
run_step "install_tools.sh"
e "Running final setup steps"
cp_ $DIR/novarc $HOME/novarc
echo "all done :)"

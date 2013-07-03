TMUX_SESSION_NAME="novavm"
OS_DIR=OPENSTACK_DIR
TACH=0
JUSTINCUSTOM=1

if [ $TACH -eq 0 ]; then
    echo "Not using Tachometer"
else
    echo "Using Tachometer"
fi

if [ $# -eq 1 ]; then
  if [ $1 = 'purge' ]; then
    PURGE=1
  fi

  if [ $1 = 'env' ]; then
    SHOW_ENV=1
  fi
fi

# Potentially fill these in
# -----------------------------------------------------------

if [ -z "$SSHPASS_DOMZERO" ];  then
  SSHPASS_DOMZERO=YOUR-XEN-PASSWORD
fi

if [ -z "$NOVA_DIR" ];  then
  NOVA_DIR=$OS_DIR/nova
fi

if [ -z "$KEYSTONE_DIR" ];  then
  KEYSTONE_DIR=$OS_DIR/keystone
fi

if [ -z "$MELANGE_DIR" ]; then
  MELANGE_DIR=$OS_DIR/melange
fi

if [ -z "$QUANTUM_DIR" ]; then
  QUANTUM_DIR=$OS_DIR/quantum
fi

if [ -z "$GLANCE_DIR" ]; then
  GLANCE_DIR=$OS_DIR/glance
fi

if [ -z "$TENANT_NAME" ]; then
  TENANT_NAME=admin
fi

# The path to where you keep the images
if [ -z "$IMAGE_DIR" ]; then
  IMAGE_DIR=$OS_DIR/images
fi

if [ -z "$IMAGE_NAME" ]; then
  IMAGE_NAME=squeeze-110613.ova
fi

# Path to where you have Glance keeping its images
if [ -z "$GLANCE_IMAGE_DIR" ]; then
  GLANCE_IMAGE_DIR=$GLANCE_DIR/images
fi

# Set this to <user>@<host>
if [ -z "$DOMZERO" ]; then
  DOMZERO=root@XENSERVER_IP
fi

if [ -z "$NOVA_BRANCH" ]; then
  NOVA_BRANCH=development
fi

if [ -z "$QUANTUM_BRANCH" ]; then
  QUANTUM_BRANCH=development
fi

if [ -z "$MELANGE_BRANCH" ]; then
  MELANGE_BRANCH=master
fi

if [ -z "$GLANCE_BRANCH" ]; then
  GLANCE_BRANCH=master
fi

if [ -z "$NOVA_REMOTE" ]; then
  NOVA_REMOTE=origin
fi

if [ -z "$QUANTUM_REMOTE" ]; then
  QUANTUM_REMOTE=origin
fi

if [ -z "$MELANGE_REMOTE" ]; then
  MELANGE_REMOTE=origin
fi

if [ -z "$GLANCE_REMOTE" ]; then
  GLANCE_REMOTE=origin
fi

if [ -z "$MYSQL_CONNECTION_CREDS" ]; then
  MYSQL_CONNECTION_CREDS="-uDBUSER -pDBPASS"
fi
BASE_DIR=$OS_DIR
echo "***************************************************************"
echo "Environment:"
echo "BASE_DIR: $BASE_DIR"
echo "DOMZERO SSH: $SSHPASSWORD_DOMZERO"
echo "NOVA_DIR: $NOVA_DIR"
echo "MELANGE_DIR: $MELANGE_DIR"
echo "QUANTUM_DIR: $QUANTUM_DIR"
echo "GLANCE_DIR: $GLANCE_DIR"
echo "TENANT_NAME: $TENANT_NAME"
echo "IMAGE_DIR: $IMAGE_DIR"
echo "IMAGE_NAME: $IMAGE_NAME"
echo "GLANCE_IMAGE_DIR: $GLANCE_IMAGE_DIR"
echo "DOMZERO: $DOMZERO"
echo "NOVA_BRANCH: $NOVA_BRANCH"
echo "QUANTUM_BRANCH: $QUANTUM_BRANCH"
echo "MELANGE_BRANCH: $MELANGE_BRANCH"
echo "GLANCE_BRANCH: $GLANCE_BRANCH"
echo "NOVA_REMOTE: $NOVA_REMOTE"
echo "QUANTUM_REMOTE: $QUANTUM_REMOTE"
echo "MELANGE_REMOTE: $MELANGE_REMOTE"
echo "GLANCE_REMOTE: $GLANCE_REMOTE"
echo "MYSQL_CONNECTION_CREDS: $MYSQL_CONNECTION_CREDS"
echo "***************************************************************"

if [ -n "$SHOW_ENV" ]; then
  exit
fi

# -----------------------------------------------------------
# The run once stuff:
#
# Copy melange.conf to ~/
# cp $MELANGE_DIR/etc/melange/melange.conf.sample ~/melange.conf
#
# Quantum will look locally for the config file, in the etc/ directory under the project (sadpanda)
#
# Update nova.conf:
#
# --network_manager=nova.network.quantum.manager.QuantumManager
# --quantum_ipam_lib=nova.network.quantum.melange_ipam_lib
# --xenapi_vif_driver=nova.virt.xenapi.vif.XenAPIOpenVswitchDriver
# --quantum_connection_host=localhost
# --quantum_connection_port=9696
# --quantum_default_tenant_id=rackspace
# --xenapi_ovs_integration_bridge=xapi3
# -----------------------------------------------------------

NL=$'\n'

sudo /etc/init.d/rabbitmq-server restart
source ~/novarc
function changedir() {
  texec "cd $1"
}

function evenpanes() {
 tmux select-layout even-vertical
}

function splitwindow() {
  tmux split-window
}

function selectpane() {
  tmux select-pane -t $1
}

function texec() {
  tmux send-keys -t $TMUX_SESSION_NAME "$1$NL"
}

function new_window() {
  tmux new-window -t $TMUX_SESSION_NAME -n "$1"
}
if [ -n "$PURGE" ]; then
  sudo find $BASE_DIR -not -iwholename "*.tox*" -name "*.pyc" -exec rm {} \;
fi


# Purge your database:
# -----------------------------------------------------------

if [ -n "$PURGE" ]; then
  mysql $MYSQL_CONNECTION_CREDS -e 'drop database if exists nova'
  mysql $MYSQL_CONNECTION_CREDS -e 'drop database if exists melange'
  mysql $MYSQL_CONNECTION_CREDS -e 'drop database if exists keystone'
  mysql $MYSQL_CONNECTION_CREDS -e 'drop database if exists quantum'
  mysql $MYSQL_CONNECTION_CREDS -e 'create database nova'
  mysql $MYSQL_CONNECTION_CREDS -e 'create database melange'
  mysql $MYSQL_CONNECTION_CREDS -e 'create database keystone'
  mysql $MYSQL_CONNECTION_CREDS -e 'create database quantum'
  cd $QUANTUM_DIR
  if [ -f quantum.sqlite ]; then
      rm quantum.sqlite
  fi
  if [ -f $KEYSTONE_DIR/keystone.db ]; then 
      rm $KEYSTONE_DIR/keystone.db
  fi
fi

# Checkout/Update all latest quantum, melange and nova
# -----------------------------------------------------------
cd $NOVA_DIR && git checkout $NOVA_BRANCH && git pull $NOVA_REMOTE $NOVA_BRANCH
cd $QUANTUM_DIR && git checkout $QUANTUM_BRANCH && git pull $QUANTUM_REMOTE $QUANTUM_BRANCH
cd $MELANGE_DIR && git checkout $MELANGE_BRANCH && git pull $MELANGE_REMOTE $MELANGE_BRANCH
cd $GLANCE_DIR && git checkout $GLANCE_BRANCH && git pull $GLANCE_REMOTE $GLANCE_BRANCH


cd $NOVA_DIR

source .venv/bin/activate --no-site-packages
./bin/nova-manage db sync
mysql $MYSQL_CONNECTION_CREDS nova -e 'insert into instance_types set name="supertiny", memory_mb=64, vcpus=1, root_gb=5, ephemeral_gb=0, swap=0, is_public=1, flavorid=6, rxtx_factor=1, deleted=0'
deactivate
# Open mysql
# -----------------------------------------------------------
tmux new-session -s $TMUX_SESSION_NAME -d

#
# Launch Melange
# -----------------------------------------------------------
new_window "quantum/melange"
texec "source ~/novarc"
changedir $MELANGE_DIR
texec "source .venv/bin/activate --no-site-packages"
texec "./bin/melange-manage db_sync"
texec "./bin/melange-server --debug --verbose"
splitwindow

#
# Launch Quantum
# -----------------------------------------------------------
texec "source ~/novarc"
changedir $QUANTUM_DIR
texec "source .venv/bin/activate --no-site-packages"
if [ ! $TACH -eq 0 ]; then
    texec "tach tach-quantum.conf ./bin/quantum-server "
else
    texec "./bin/quantum-server "
fi
splitwindow
texec "source ~/novarc"
changedir $QUANTUM_DIR
texec "source .venv/bin/activate --no-site-packages"
evenpanes

# Launch Glance
# This assumes that you store your glance images in your home directory under ~/images
# -----------------------------------------------------------
new_window "glance"
texec "source ~/novarc"
changedir $GLANCE_DIR
texec "source .venv/bin/activate"
if [ -n "$PURGE" ]; then
  texec "yes | rm glance.sqlite"
  texec "sudo cp ./etc/* /etc/glance"
fi
texec "./bin/glance-manage db_sync || glance-manage db_sync"
texec "./bin/glance-api || glance-api"
splitwindow
texec "source ~/novarc"
changedir $GLANCE_DIR
texec "source .venv/bin/activate"
texec "./bin/glance-registry || glance-registry"
splitwindow
texec "source ~/novarc"
changedir $GLANCE_DIR
texec "source .venv/bin/activate"
evenpanes


# Setting up Nova
# -----------------------------------------------------------

new_window "nova-api"
changedir $NOVA_DIR
texec "source ~/novarc"
texec "source .venv/bin/activate"

# Launching Nova
# -----------------------------------------------------------
if [ ! $TACH -eq 0 ]; then
    texec "tach tach-api.conf ./bin/nova-api"
else
    texec "./bin/nova-api"
fi

splitwindow
#new_window "nova-compute"
changedir $NOVA_DIR
texec "source ~/novarc"
texec "source .venv/bin/activate"
if [ ! $TACH -eq 0 ]; then
    texec "tach tach-compute.conf ./bin/nova-compute"
else
    texec "./bin/nova-compute"
fi
splitwindow
changedir $NOVA_DIR
texec "source ~/novarc"
texec "source .venv/bin/activate"
evenpanes

new_window "nova-stuff"
changedir $NOVA_DIR
texec "source ~/novarc"
texec "source .venv/bin/activate"
if [ ! $TACH -eq 0 ]; then
    texec "tach tach-network.conf ./bin/nova-network"
else
    texec "./bin/nova-network"
fi
splitwindow

#new_window "nova-scheduler"
changedir $NOVA_DIR
texec "source ~/novarc"
texec "source .venv/bin/activate"
if [ ! $TACH -eq 0 ]; then
    texec "tach tach-scheduler.conf ./bin/nova-scheduler"
else
    texec "./bin/nova-scheduler"
fi
splitwindow
#new_window "nova-conductor"
changedir $NOVA_DIR
texec "source ~/novarc"
texec "source .venv/bin/activate"
if [ ! $TACH -eq 0 ]; then
    texec "tach tach-scheduler.conf ./bin/nova-conductor"
else
    texec "./bin/nova-conductor"
fi
evenpanes


new_window "keystone"
changedir $KEYSTONE_DIR
texec "source ~/novarc"
texec "source .venv/bin/activate"
texec "./bin/keystone-manage db_sync"
if [ ! $TACH -eq 0 ]; then
    texec "tach tach-scheduler.conf ./bin/keystone-all --debug"
else
    texec "./bin/keystone-all --debug"
fi
splitwindow
evenpanes
changedir $KEYSTONE_DIR
texec "source ~/novarc"
texec "source .venv/bin/activate"
if [ -n "$PURGE" ]; then
  texec "sleep 30s"
  texec "./keystone_setup.sh"
fi

new_window "work"
changedir $NOVA_DIR
texec "source ~/novarc"
texec "source .venv/bin/activate"
texec "pip install python-novaclient"
texec "pip install python-glanceclient"
texec "pip install python-quantumclient"

# Uploading your images to Glance
# -----------------------------------------------------------

#new_window "htop"
#if [ -n "$PURGE" ]; then
#  texec "sleep 5"
#  texec "sudo rm -rf $GLANCE_IMAGE_DIR"
#  texec "sudo mkdir -p $GLANCE_IMAGE_DIR"
#  changedir $IMAGE_DIR
#  texec "sudo glance --os_image_url http://127.0.0.1:9292 --os_auth_token \"nova:openstack\" add name=$IMAGE_NAME disk_format=vhd container_format=ovf os_type=linux arch=x86-64 is_public=True < $IMAGE_NAME"
#  texec "quantum create_net rackspace public"
#  texec "export NET_ID=\`quantum list_nets rackspace | grep \"Network ID:\" | cut -d' ' -f3\`"
#  texec "melange ip_block create -t rackspace type='public' cidr='10.0.0.1/24' network_id=\$NET_ID gateway='10.0.0.1'"
#  changedir $NOVACLIENT_DIR
#  texec "sudo rm -rf ./build"
#  texec "sudo python setup.py install"
#  texec "melange mac_address_range create cidr=DE:AD:00/1"
#  changedir $NOVA_DIR
#  texec "source novarc"
#  texec "nova network-create private 172.16.0.0/24"
#fi
#
#texec "htop"
#
#new_window "ipy"
#changedir $NOVA_DIR
#texec "source .venv/bin/activate"
#texec "ipython"
#
#
##new_window "yagi"
##texec "yagi-event"
#
##new_window "berra"
##changedir $BERRA_DIR
##texec "python berra.py"
#
#new_window "cli"
#changedir $NOVA_DIR
#texec "source .venv/bin/activate"
#texec "source ~/novarc"
#texec "export NOVA_IMAGE=\`nova image-list | head -n-1 | tail -n1 | cut -d\" \" -f2\`"
#
## Finally, connect to the session we just spun up
tmux a

#!/bin/bash
SETUP_XEN_USERNAME="root"
SETUP_XEN_PASSWORD="password"
SETUP_DB_USERNAME="root"
SETUP_DB_PASSWORD="password"
SETUP_XEN_IP="172.16.207.198"
SETUP_VM_USERNAME="jhammond"
SETUP_GITHUB_USERNAME="YOUR-GITHUB-USERNAME"
SETUP_GITHUB_PASSWORD="YOUR-GITHUB-PASSWORD"
SETUP_NVP_IP="172.16.207.202"

isvarset() {
	local v="$1"
	[[ ! ${!v} && ${!v-unset} ]] && echo "1" || echo "0"
}

e() {
	echo "$1"
}

getip() {
	local ip=`/sbin/ifconfig $1 | awk '/inet/ {print $2}' | awk -F: '{print $2}'`
	echo $ip
}

prompt() {
	local prompt_in=""
	read -p "$1: " prompt_in
	echo $prompt_in
}

prompt_confirm() {
    local prompt_in=""
    while [ 1 ]; do
        read -p "$1 [y/n]: " prompt_in
        case "$prompt_in" in
            y|Y ) return 0
                break;;
            n|N ) return 1
                break;;
            * ) echo "Please answer yes or no";;
        esac
    done 
}

prompt_default() {
    local prompt_in=""
    read -p "$1 [$2]: " prompt_in
    if [ -z "$prompt_in" ]; then
        echo $2
    else
        echo $prompt_in
    fi
}

prompt_confirm_y() {
    local prompt_in=""
    while [ 1 ]; do
        read -p "$1 [Y/n]: " prompt_in
        case "$prompt_in" in
            y|Y ) echo "0"
                break;;
            n|N ) echo "1"
                break;;
            * ) if [ -z "$prompt_in" ]; then
                    echo "0"
                    break
                else
                    echo "Please answer yes or no"
                fi;;
        esac
    done 
}

prompt_confirm_n() {
    local prompt_in=""
    while [ 1 ]; do
        read -p "$1 [y/N]: " prompt_in
        case "$prompt_in" in
            y|Y ) echo "0"
                break;;
            n|N ) echo "1"
                break;;
            * ) if [ -z "$prompt_in" ]; then
                    echo "1"
                    break
                else
                    echo "Please answer yes or no" 1>&2
                fi;;
        esac
    done 
}

prompt_pass_confirm() {
	local prompt_in=""
	local prompt_confirm=""
	while [ 1 ]; do
		read -s -p "$1: " prompt_in
		echo ""
		read -s -p "Confirm: " prompt_confirm
		if [ "$prompt_in" = "$prompt_confirm" ]; then
			echo $prompt_in
			break
        else
            echo ""
            echo  "Didn't match"
        fi
	done
}

chex() {
    RET=$1
    if [ $RET -ne 0 ]; then
        echo "FAIL: $2"
        exit 1
    fi
}

chwa() {
    RET=$1
    if [ $RET -ne 0 ]; then
        echo "WARNING: $2"
    fi
}

run_step() {
    prg="$1"
    ./bin/$prg
    RET=$?
    if [ $RET -eq 0 ]; then
        echo "success :)"
    else
        echo "failure with $prg"
        exit 1
    fi

}

run_step_sudo() {
    prg="$1"
    sudo ./bin/$prg
    RET=$?
    if [ $RET -eq 0 ]; then
        echo "success :)"
    else
        echo "failure with $prg"
        exit 1
    fi

}

mysql_uninstall_reinstall() {
    sudo apt-get -y purge mysql-server
    sudo apt-get -y purge mysql-common
    sudo rm -rf /var/log/mysql
    sudo rm -rf /var/log/mysql.*
    sudo rm -rf /var/lib/mysql
    sudo rm -rf /etc/mysql
    # and then:
    MYSQL_1="mysql-server-5.1 mysql-server/root_password password $SETUP_DB_PASSWORD"
    MYSQL_2="mysql-server-5.1 mysql-server/root_password_again password $SETUP_DB_PASSWORD"
    sudo debconf-set-selections <<< $MYSQL_1
    sudo debconf-set-selections <<< $MYSQL_2
    sudo apt-get -y install mysql-server 
    sudo /etc/init.d/mysql start
    #mysqladmin -u $SETUP_DB_USERNAME password $SETUP_DB_PASSWORD
    echo 0
}

apt_get_install_all() {
    for pkg in "$@"
    do
        sudo apt-get -y install "$pkg"
        if [ $? -ne 0 ]; then
            echo "apt_get_install_all: error installing $pkg"
            return 1
        fi
    done
    return 0
}

pip_install() {
    pip install --timeout 60 -i http://pypi.openstack.org $@ 
    if [ $? -ne 0 ]; then
        pip install --timeout 60 "$@" 
    fi
    chex $? "Error pip_install: $@"
    sleep 5
}

installnoninteractive(){
    sudo bash -c "DEBIAN_FRONTEND=noninteractive aptitude install -q -y $*"
}


checkforhost() {
    PING=`which ping`
    $PING -q -c 1 "$1"
    if [ "$?" -eq 0 ]; then
        echo "0"
    else
        echo "1"
    fi
}
# $1 sed regex
# $2 target file
sed_sub() {
    sed -i -e "$1" $2
    chex $? "Error sed command: $1"
}


cp_() {
    if [ "$1" = "-r" ]; then
        cp -r "$2" "$3"
        chex $? "Error copying $2 to $3"
    else
        cp "$1" "$2"
        chex $? "Error copying $1 to $2"
    fi
}


cd_() {
    cd "$1"
    chex $? "Error cd to $1"
}



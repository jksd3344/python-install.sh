#!/bin/bash
#----------------------------------------------------------
# Auth: mingmings
# Mail: 369413651@qq.com
# Url:  http://mingmings.org/
# Data: 2015-03-24
# Platform: centos 6.5 x86_64 minimal
# Version: 1.0
#----------------------------------------------------------
_RED_="\033[31;49;1m"
_GREEN_="\033[32;49;1m"
_BLUE_="\033[34;49;1m"
_YELLOW_="\033[33;49;1m"
_RESET_="\033[39;49;0m"
BANNER="Centos 6 minimal upgrade python 2.7+ and pip env"
echo
echo -e "${_GREEN_}----- $BANNER ----- ${_RESET_}"
echo
#----------------------------------------------------------
PY_VER="2.7.8"
FLAG="1"
INSTALL_DIR="/usr/local/bin"
DEV_MOD_LIST=("MySQL-python"
        "django==1.8.3"
        )
#----------------------------------------------------------
scriptdir=$(cd $(dirname $0) && pwd)
# determining user
if [ `id -u` != "0" ];then
    echo -e "${_RED_} Error: You must be root to run this script! ${_RESET_}"
    exit 1
fi

function install_dependent_packages()
{
    # install denpendent package
    rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
    yum -y groupinstall 'Development Tools'
    yum -y install openssl-devel* ncurses-devel* zlib*.x86_64 curl wget
    yum -y install bzip2 bzip2-devel bzip2-libs
    yum -y install python-devel mysql-devel
}

function update_python()
{
    # update python to 2.7.8
    tar zxvf Python-${PY_VER}.tgz
    cd Python-${PY_VER}
    ./configure
    make && make install
    echo $?

    if [ $? -eq 0 ];then
        echo -e "${_GREEN_} ---------- install successful... ---------- ${_RESET_}"
    else
        echo -e "${_RED_} install error, please check it again... ${_RESET_}"
    fi

    sudo rm -f /usr/bin/python
    sudo ln -s ${INSTALL_DIR}/python2.7 /usr/bin/python
    sudo ln -s ${INSTALL_DIR}/python2.7 /usr/bin/python2.7

#    # environment path
#    echo -e "export PATH=${INSTALL_DIR}/bin:$PATH" >> /etc/profile.d/python.sh
#    source /etc/profile.d/python.sh

    sudo which python
    python -V

    #replace python dependent for yum
    sed -ie 's#/usr/bin/python$#/usr/bin/python2.6#g' /usr/bin/yum
    cd
}

function update_pip()
{
    # install pip
    curl https://bootstrap.pypa.io/get-pip.py | python -
    #wget https://bootstrap.pypa.io/get-pip.py
    #python get-pip.py
}

function install_development_module()
{
    # install module for python development module list
    count=0
    while [ "x${DEV_MOD_LIST[count]}" != "x" ];do
        count=$(( count + 1 ))
    done

    for MOD in ${DEV_MOD_LIST[@]};do
        pip install ${MOD}
        echo $?
        if [ $? -eq 0 ];then
            echo -e "${_GREEN_} ---------- install ${MOD} successful... ---------- ${_RESET_}"
        else
            echo -e "${_RED_} install ${MOD} error, please check it again... ${_RESET_}"
        fi
    done
}
#----------------------------------------------------------
# run function
install_dependent_packages
update_python
if [ $? -eq 0 ];then
    update_pip
    if [ ${FLAG} -eq 1 ];then
        echo -e "${_YELLOW_} ---------- install development module ... ---------- ${_RESET_}"
        install_development_module
    fi
else
    echo -e "${_RED_} install python error, please check it again... ${_RESET_}"
fi
echo

echo -e "${_GREEN_} ---------- update completed, clean local... ---------- ${_RESET_}"
rm -rf $0
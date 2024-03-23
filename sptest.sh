#!/bin/bash

# Function to install Speedtest CLI on Debian/Ubuntu
install_speedtest_debian() {
    apt install -y curl
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
    apt install -y speedtest
}

# Function to install Speedtest CLI on CentOS/RHEL
install_speedtest_centos () {
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
    yum install -y speedtest
}

# function for uninstalling speedtest
uninstall_speedtest() {
    if [ -f "/etc/debian_version" ]; then
        rm /etc/apt/sources.list.d/ookla_speedtest-cli.list
        apt remove -y speedtest
    elif [ -f "/etc/redhat-release" ]; then
        rm /etc/yum.repos.d/ookla_speedtest-cli.repo
        yum remove -y speedtest
    else
        echo "Unsupported OS."
        exit 1
    fi
}

# check the argument passed to the script
if [ $1 == "-u" ]; then
    uninstall_speedtest
    echo -e "Uninstall done. \033[0;32m[OK]\033[0m"
else
    if [ -f "/etc/debian_version" ]; then
        install_speedtest_debian
        yes | speedtest
    elif [ -f "/etc/redhat-release" ]; then
        install_speedtest_centos
        yes | speedtest
    else
        echo "This script only supports Debian/Ubuntu and CentOS/RHEL."
        exit 1
    fi
fi

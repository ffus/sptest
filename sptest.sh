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
        echo -e "\033[31mUnsupported OS.\033[0m"
        exit 1
    fi
}


if [ $1 == "-u" ]; then
    uninstall_speedtest
    echo -e "\033[0;32mUninstalled or not installed. --- status:[OK]\033[0m"
else
    if command -v speedtest >/dev/null 2>&1; then
        echo "Speedtest is already installed. Running speedtest..."
        speedtest
    else
        if [ -f "/etc/debian_version" ]; then
            install_speedtest_debian
            yes | speedtest
        elif [ -f "/etc/redhat-release" ]; then
            install_speedtest_centos
            yes | speedtest
        else
            echo -e "\033[31mThis script only supports Debian/Ubuntu and CentOS/RHEL.\033[0m"
            exit 1
        fi
    fi
fi

#!/bin/bash

# Check if speedtest is installed
if command -v speedtest &> /dev/null
then
    echo "Speedtest is already installed. Running speedtest..."
    speedtest
    exit 0
fi

# Function to install Speedtest CLI on Debian/Ubuntu
function install_speedtest_debian {
    # If migrating from prior bintray install instructions please first...
    sudo rm /etc/apt/sources.list.d/speedtest.list
    sudo apt-get update
    sudo apt-get remove -y speedtest
    # Other non-official binaries will conflict with Speedtest CLI
    # Example how to remove using apt-get
    sudo apt-get remove -y speedtest-cli
    sudo apt-get install -y curl
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
    sudo apt-get install -y speedtest
}

# Function to install Speedtest CLI on CentOS/RHEL
function install_speedtest_centos {
    # If migrating from prior bintray install instructions please first...
    sudo rm /etc/yum.repos.d/bintray-ookla-rhel.repo
    sudo yum remove -y speedtest
    # Other non-official binaries will conflict with Speedtest CLI
    # Example how to remove using yum
    rpm -qa | grep speedtest | xargs -I {} sudo yum -y remove {}
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.rpm.sh | sudo bash
    sudo yum install -y speedtest
}

if [ -f "/etc/debian_version" ]; then
    install_speedtest_debian
elif [ -f "/etc/redhat-release" ]; then
    install_speedtest_centos
else
    echo "This script only supports Debian/Ubuntu and CentOS/RHEL."
    exit 1
fi

# Run speedtest
speedtest

#!/bin/bash

# Install BCC for python for example to work
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D4284CDD
echo "deb https://repo.iovisor.org/apt/bionic bionic main" | sudo tee /etc/apt/sources.list.d/iovisor.list
#sudo apt-get -y install libbcc
sudo apt-get update
sudo apt-get -y install python-bcc
sudo apt-get -y install python3-bcc

sudo apt -y install linux-headers-$(uname -r)
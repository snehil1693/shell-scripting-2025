#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

echo "############################################"
echo "disk space"
df -h

echo "###########################################"
echo "os version"
cat /etc/os-release

echo "##########################################"
echo "free memory"
free -m

echo "##########################################"
echo "disk partition"
lsblk

echo "#######################################"
echo "list of all the files"
ls -lrth
echo "#########################################"

#!/bin/bash

#check if the script is run as root user
if [ $(id -u) -ne 0 ]; then
    echo -e "\e[31mYou should run this script as root user\e[0m"
    exit 1
fi

VALIDATE(){
    if [ $? -eq 0]; then
        echo -e "\e[32m$1 is successful\e[0m"
    else
        echo -e "\e[31m$1 is failed\e[0m"
        exit 1
    fi
}

##Create the repo for mongo db
echo -e "\e[32mCreating the mongo db repo\e[0m"
cp /mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE "Creating the mongo db repo"

#install mongo db
echo -e "\e[32mInstalling mongo db\e[0m"
dnf install mongodb-org -y
VALIDATE "Installing mongo db"

#Start and enable mongo db
echo -e "\e[32mStarting and enabling mongo db\e[0m"
systemctl enable mongod 
VALIDATE
systemctl start mongod 
VALIDATE "Starting mongo db"


#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf
echo -e "\e[32mUpdating listen address in /etc/mongod.conf\e[0m"
sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/mongod.conf
VALIDATE "Updating listen address in /etc/mongod.conf"

#Restart mongo db
echo -e "\e[32mRestarting mongo db\e[0m"
systemctl restart mongod
VALIDATE "Restarting mongo db"
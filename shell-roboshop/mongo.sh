#!/bin/bash

USER=$(id -u)
SCRIPT_NAME=$(echo $0 | cut -d . -f1)
LOGS_FILE="/var/log/Shell-roboshop/$SCRIPT_NAME.log"
DATE=$(date +%F-%H-%M-%S)
SCRIPT_DIR=$(pwd)

mkdir -p $LOGS_FILE

echo -e "\e[34m********** $SCRIPT_NAME Script Execution Started at $DATE **********\e[0m" >> $LOGS_FILE
#check if the script is run as root user
if [ $USER -ne 0 ]; then
    echo -e "\e[31mYou should run this script as root user\e[0m" >> $LOGS_FILE
    exit 1
fi

VALIDATE(){
    if [ $? -eq 0]; then
        echo -e "\e[32m$1 is successful\e[0m" >> $LOGS_FILE
    else
        echo -e "\e[31m$1 is failed\e[0m" >> $LOGS_FILE
        exit 1
    fi
}

##Create the repo for mongo db
echo -e "\e[32mCreating the mongo db repo\e[0m" >> $LOGS_FILE
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE "Creating the mongo db repo"

#install mongo db
echo -e "\e[32mInstalling mongo db\e[0m" >> $LOGS_FILE
dnf install mongodb-org -y
VALIDATE "Installing mongo db"

#Start and enable mongo db
echo -e "\e[32mStarting and enabling mongo db\e[0m" >> $LOGS_FILE
systemctl enable mongod 
VALIDATE
systemctl start mongod 
VALIDATE "Starting mongo db"


#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf
echo -e "\e[32mUpdating listen address in /etc/mongod.conf\e[0m" >> $LOGS_FILE
sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/mongod.conf
VALIDATE "Updating listen address in /etc/mongod.conf"

#Restart mongo db
echo -e "\e[32mRestarting mongo db\e[0m" >> $LOGS_FILE
systemctl restart mongod
VALIDATE "Restarting mongo db"
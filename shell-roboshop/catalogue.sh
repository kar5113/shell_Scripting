#!/bin/bash

## use set and trap for error handling in bash scripts
set -e
set -o pipefail
trap 'echo -e "\e[31mScript failed at line: $LINENO\e[0m"' ERR


#now take the commonly executed commands and group them into functions similar to ansible roles, and write them to a bash script and call it from the main script, using source ./filename.sh or . /filename.sh

USER=$(id -u)
SCRIPT_NAME=$(echo $0 | cut -d . -f1)
LOGS_FILE="/var/log/Shell-roboshop/$SCRIPT_NAME.log"

MONGODB_SERVER="mongodb-dev.kardev.space"
SCRIPT_DIR=$(pwd)


mkdir -p $LOGS_FILE

echo -e "\e[34m********** $SCRIPT_NAME Script Execution Started at $(date +%F-%H-%M-%S) **********\e[0m" >> $LOGS_FILE
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

#Disable current module
echo -e "\e[32mDisabling current module\e[0m" >> $LOGS_FILE
dnf module disable nodejs -y
VALIDATE "Disabling current module"

#Enable required module
echo -e "\e[32mEnabling required module\e[0m" >> $LOGS_FILE
dnf module enable nodejs:16 -y
VALIDATE "Enabling required module"

#Install NodeJS
echo -e "\e[32mInstalling NodeJS\e[0m" >> $LOGS_FILE
dnf install nodejs -y
VALIDATE "Installing NodeJS"

#Add application User "roboshop"
echo -e "\e[32mAdding application User roboshop\e[0m" >> $LOGS_FILE
id roboshop &>> $LOGS_FILE
if [ $? -eq 1 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE "Adding application User roboshop"
    echo -e "\e[32mUser roboshop has been created\e[0m" >> $LOGS_FILE
fi
else
    echo -e "\e[33mUser roboshop already exists, Skipping user creation\e[0m" >> $LOGS_FILE
fi

#Create Application Directory
echo -e "\e[32mCreating Application Directory\e[0m" >> $LOG_FILE
rm -rf /app 
mkdir -p /app
VALIDATE "Creating Application Directory"

#Download the application code
echo -e "\e[32mDownloading the application code\e[0m" >> $LOGS_FILE
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE "Downloading the application code" 

#Extract the application code
echo -e "\e[32mExtracting the application code\e[0m" >> $LOGS_FILE
cd /app
unzip /tmp/catalogue.zip    
VALIDATE "Extracting the application code"

#Install the application dependencies
echo -e "\e[32mInstalling the application dependencies\e[0m" >> $LOGS_FILE
npm install
VALIDATE "Installing the application dependencies"

#Setup SystemD Catalogue Service
echo -e "\e[32mSetting up SystemD Catalogue Service\e[0m" >> $LOGS_FILE
sed -i -e "s/<MONGODB-SERVER-IPADDRESS>/$MONGODB_SERVER/" $SCRIPT_DIR/catalogue.service
VALIDATE "Updating MongoDB Server IP in Service File"
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE "Setting up SystemD Catalogue Service"

#Start and Enable Catalogue Service
echo -e "\e[32mStarting and Enabling Catalogue Service\e[0m"
systemctl daemon-reload
VALIDATE "Reloading SystemD Daemon"
systemctl enable catalogue
VALIDATE "Enabling Catalogue Service"
systemctl start catalogue
VALIDATE "Starting Catalogue Service"

echo -e "\e[32mCreating the mongo db repo\e[0m" >> $LOGS_FILE
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE "Creating the mongo db repo"

#install mongo db
echo -e "\e[32mInstalling mongo db\e[0m" >> $LOGS_FILE
dnf install mongodb-mongosh -y
VALIDATE "Installing mongo db"

INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -ne 0 ]; then 
    #Load the catalogue schema
    echo -e "\e[32mLoading the catalogue schema\e[0m" >> $LOGS_FILE
    mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js
    VALIDATE "Loading the catalogue schema"
else
    echo -e "\e[33mCatalogue schema is already present, Skipping catalogue schema load\e[0m" >> $LOGS_FILE
fi

#Restart Catalogue Service
echo -e "\e[32mRestarting Catalogue Service\e[0m" >> $LOGS_FILE
systemctl restart catalogue
VALIDATE "Restarting Catalogue Service"

echo -e "\e[34m********** $SCRIPT_NAME Script Execution Completed at $(date +%F-%H-%M-%S) **********\e[0m" >> $LOGS_FILE














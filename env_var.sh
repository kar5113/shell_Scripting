#!/bin/bash

#create a env variable with export command, create externally, will persist only for current session or current process
export DB_USER="admin"
export DB_PASSWORD="password123"

#access the env variable
echo "Database  User: $DB_USER"
echo "Database Password: $DB_PASSWORD"

#to make the env variable permanent, add the export command to ~/.bashrc or ~/.bash_profile file which is available in home directory
#as it is a hidden file, use ls -a to see the hidden files
#it is executed evry time when a new terminal session is started
# nano ~/.bashrc
# export DB_USER="admin"
# export DB_PASSWORD="password123"
# source ~/.bashrc
# echo "Database  User: $DB_USER"
# echo "Database Password: $DB_PASSWORD"
#to check all the env variables, use env command
# env
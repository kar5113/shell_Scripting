#!/bin/bash

priority for variables
env_var > set variables in script > 


#variables, must not contain space between equal sign
 person1="Ramesh"
 person2="Suresh"
# $1 and $2, ...... are cmd line parameters
 person3=$1
 person4=$2
#  $0 is the script name
 person5=$0



 echo "This is a conversation script by $person1."
 echo "How are you today? by $person2."
 echo "I hope you're doing well! by $person1."
 echo "I'm doing great, thank you! by $person2."
 echo "Nice to meet you, $person3! by $person1."
 echo "Pleasure to meet you too, $person4! by $person2. and this script name is $person5."


##### read inputs from command line and user


#read command to take input from user
#read -s means silent mode, input will not be shown on terminal
#read -p means prompt mode, input will be shown on terminal
#read without any option means normal mode, input will be shown on terminal

 read -p "Enter your password: "  password1
 read -s password2
 read password3
 echo "Your password is $password1 and $password2 and $password3"



#### env variables



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


#execute command in shell script
#look in hello.sh
#place the command in between braces $(command), can be saved in variables also
 
echo "date is $(date)"


#### special variables


# $@ is all the variables passed to the script
echo "All variables passed to the script are: $@"

# $# is the number of variables passed to the script
echo "Number of variables passed to the script: $#"

# * is all the variables passed to the script
echo "All of variables passed to the script: $*"

# $$ is the process id of the current script
echo "process id of the current script: $$"

#add & to run a command in background
sleep 5 &  # Example background command
echo "process id of the last background command: $!"

#process id of previous command is $?
echo "process id of previous command: $?"

# Example command to get exit status
echo "$(sleep 2)" # Example command to get exit status


#### data types in shell script
#there are no data types in shell script, everything is string
#but we can do arithmetic operations on numbers
# everything in shell is considerd as string
NUMBER1=100
NUMBER2=200
NAME=DevOps

#arithmetic operations, use $((expression))
#wont consider the string values in arithmetic operations, string effective value is 0
SUM=$(($NUMBER1+$NUMBER2+$NAME))

echo "SUM is: ${SUM}"

# Size = 4, Max index = 3 
LEADERS=("Modi" "Putin" "Trudo" "Trump")

echo "All leaders: ${LEADERS[@]}"
echo "First Leader: ${LEADERS[0]}"
# This will not return any value as there is no index 10 in the array
echo "invalid index: ${LEADERS[10]}"









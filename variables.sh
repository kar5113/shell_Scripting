#!/bin/bash

#variables, must not contain space between equal sign
person1="Ramesh"
person2="Suresh"
#$1 and $2, ...... are cmd line parameters
person3=$1
person4=$2
# $0 is the script name
person5=$0



echo "This is a conversation script by $person1."
echo "How are you today? by $person2."
echo "I hope you're doing well! by $person1."
echo "I'm doing great, thank you! by $person2."
echo "Nice to meet you, $person3! by $person1."
echo "Pleasure to meet you too, $person4! by $person2. and this script name is $person5."



#read command to take input from user
#read -s means silent mode, input will not be shown on terminal
#read -p means prompt mode, input will be shown on terminal
#read without any option means normal mode, input will be shown on terminal

# read -p "Enter your password: "  password1
# read -s password2
# read password3
# echo "Your password is $password1 and $password2 and $password3"
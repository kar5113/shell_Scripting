#!/bin/bash

#read command to take input from user
#read -s means silent mode, input will not be shown on terminal
#read -p means prompt mode, input will be shown on terminal
#read without any option means normal mode, input will be shown on terminal
read -p "Enter your password: "  password1
read -s password2
read password3
echo "Your password is $password1 and $password2 and $password3"
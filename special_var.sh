#!/bin/bash

echo "All variables passed to the script are: $@"
echo "Number of variables passed to the script: $#"
echo "All of variables passed to the script: $*"
echo "process id of the current script: $$"

#add & to run a command in background
sleep 5 &  # Example background command
echo "process id of the last background command: $!"

# Example command to get exit status
echo "$(sleep 2)" # Example command to get exit status

# previous command exit status
echo "Exit status of previous command: $?"





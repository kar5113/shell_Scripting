#!/bin/bash

#### if else condition

if [ $1 -gt 10 ]; then
    echo "The number is greater than 10"
else
    echo "The number is not greater than 10"
fi    


#### if elif else condition

if [ $1 -gt 20 ]; then
    echo "The number is greater than 20"
elif [ $1 -gt 10 ]; then
    echo "The number is greater than 10 but less than or equal to 20"
else
    echo "The number is less than or equal to 10"
fi
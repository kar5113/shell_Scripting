#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SC_ID="sg-0e26215670f90eb6a"


for instance in $@; do 
    echo "creating ec2 instance for $instance" 
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids "$SC_ID" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

if [ $instance == "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
fi

echo "EC2 Instance $instance has been created with Instance ID: $INSTANCE_ID and IP Address: $IP"

done

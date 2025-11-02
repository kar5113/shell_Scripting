#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SC_ID="sg-0e26215670f90eb6a"
HOSTED_ZONE="Z0806995L2997E89SFOF"
DOMAIN_NAME="kardev.space"

for instance in $@; do 
    echo "creating ec2 instance for $instance" 
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids "$SC_ID" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

if [ $instance == "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    RECORD_NAME="$DOMAIN_NAME"
else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    RECORD_NAME="$instance.$DOMAIN_NAME"
fi

echo "EC2 Instance $instance has been created with Instance ID: $INSTANCE_ID and IP Address: $IP"

aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE \
    --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'$RECORD_NAME'","Type":"A","TTL":3,"ResourceRecords":[{"Value":"'$IP'"}]}}]}'
done

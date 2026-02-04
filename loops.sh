#!/bin/bash

for COMPONENT in catalogue user cart shipping payment frontend; do
  echo "Setting up $COMPONENT component"
  # Add your setup commands here
done

# while loop example
COUNT=1
while [ $COUNT -le 5 ]; do
  echo "Count is: $COUNT"
  COUNT=$((COUNT + 1))
done

#comlex example of for loop with array
SERVICES=("catalogue" "user" "cart" "shipping" "payment" "frontend")
for SERVICE in "${SERVICES[@]}"; do
  echo "Starting setup for $SERVICE service"
  # Add your setup commands here
done

# Example of until loop
STATUS=0
until [ $STATUS -eq 1 ]; do
  echo "Waiting for service to be up..."
  # Simulate checking service status
  STATUS=1
done




#!/bin/bash

services=("ssh" "cron" "docker")

for service in "${services[@]}"; do
	echo "Checking $service..."
	
	if systemctl is-active "$service"; then
		echo "$service is running..."
	else
		echo "$service is not running..."
	fi
	
	
	echo "-----------------------------------------"
done

#!/bin/bash

usage=$(df -h | sort -k5 -hr | awk 'NR==1 {print $5}' | tr -d '%')

echo "Current Disk Usage: $usage%"

if [ "$usage" -ge 80 ]; then
	echo "WARNING!! Disk usage is high!"
else
	echo "OK: Disk usage is within the safe limit."
fi

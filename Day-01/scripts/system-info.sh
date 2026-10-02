#!/usr/bin/env bash

set -u

echo "=== System Information ==="
echo "User: $(whoami)"
echo "Hostname: $(hostname)"

echo
echo "Operating System:"
grep '^PRETTY_NAME=' /etc/os-release

echo
echo "Disk Usage:"
df -h /

echo
echo "Memory Usage:"
free -h

echo
echo "System Uptime:"
uptime

echo
echo "Present Working Dir"
pwd

echo
echo


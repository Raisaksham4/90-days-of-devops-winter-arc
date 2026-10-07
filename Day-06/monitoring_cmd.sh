#!/bin/bash

echo "========== SYSTEM UPTIME =========="
uptime

echo
echo "========== MEMORY USAGE =========="
free -h

echo
echo "========== TOP MEMORY PROCESSES =========="
ps aux --sort=-%mem | head -n 11

echo
echo "========== TOP CPU PROCESSES =========="
ps aux --sort=-%cpu | head -n 11

echo
echo "========== LISTENING TCP SERVICES =========="
ss -ltnp

echo
echo "========== LISTENING UDP SERVICES =========="
ss -lunp

echo
echo "========== RUNNING SYSTEM SERVICES =========="
systemctl --type=service --state=running --no-pager

echo
echo "========== CURRENT BOOT ERRORS =========="
sudo journalctl -p err -b --no-pager

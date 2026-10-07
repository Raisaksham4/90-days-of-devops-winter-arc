#!/bin/bash

echo "========== SYSTEM UPTIME =========="
uptime

echo
echo "========== MEMORY USAGE =========="
free -h

echo
echo "========== TOP MEMORY PROCESSES =========="
ps aux --sort=-%mem | head

echo
echo "========== TOP CPU PROCESSES =========="
ps aux --sort=-%cpu | head

echo
echo "========== LISTENING SERVICES =========="
ss -tulpn

echo
echo "-------------------------------------------"

#!/bin/bash

echo "============Header Request================"
echo
curl -I http://127.0.0.1


echo


echo "==========Checking Stauts of Nginx============="
echo
systemctl is-active nginx

echo

echo "=============Checking if port 80 is Listening==========="

echo

ss -tulnp | grep ':80'

echo

echo "=============Checking logs of Nginx======================"

echo

journalctl -u nginx -n 20 --no-pager

echo

echo "------------------------------------------------------------"

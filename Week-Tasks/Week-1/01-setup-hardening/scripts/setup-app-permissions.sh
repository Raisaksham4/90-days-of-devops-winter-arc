#!/usr/bin/env bash

set -Eeuo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script with sudo."
    exit 1
fi

echo "=== TESTING LEAST-PRIVILEGE SUDO ==="

if sudo -u devopsadmin sudo -n /usr/sbin/sshd -t; then
    echo "PASS: devopsadmin can validate SSH configuration"
else
    echo "FAIL: allowed SSH command was rejected"
fi

if sudo -u devopsadmin sudo -n /usr/bin/id; then
    echo "FAIL: command outside the policy was allowed"
else
    echo "PASS: command outside the policy was refused"
fi

echo
echo "=== CREATING APPLICATION DIRECTORY ==="

install \
    -d \
    -o appsvc \
    -g appops \
    -m 2770 \
    /opt/devops-app

echo "Created /opt/devops-app"

echo
echo "=== TESTING AUTHORIZED ACCESS ==="

sudo -u appsvc touch /opt/devops-app/service-created.txt
echo "PASS: appsvc created a file"

sudo -u devopsadmin touch /opt/devops-app/admin-created.txt
echo "PASS: devopsadmin created a file through appops membership"

echo
echo "=== TESTING UNAUTHORIZED ACCESS ==="

if sudo -u nobody touch /opt/devops-app/unauthorized.txt; then
    echo "FAIL: unauthorized user wrote to the directory"
    rm -f /opt/devops-app/unauthorized.txt
else
    echo "PASS: unauthorized user was denied"
fi

echo
echo "=== DIRECTORY PERMISSIONS ==="

stat -c '%A %a %U:%G %n' /opt/devops-app

echo
echo "=== CREATED FILES ==="

ls -l /opt/devops-app

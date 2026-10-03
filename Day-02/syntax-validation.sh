#!/bin/bash

for script in scripts/*.sh; do
	if bash -n $script; then
		echo "Pass: $script"
	else
		echo "Fail: $script"
	fi
done

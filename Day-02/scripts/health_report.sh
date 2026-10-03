#!/bin/bash

show_header() {
	echo "============= SYSTEM HEALTH REPORT ============="
	echo "Generated Date: $(date)"
	echo
}

check_disk() {
	echo "DISK USAGE: "
	df -h /
	echo

}

check_memory() {
	echo "MEMORY USAGE: "
	free -h
	echo
}

check_uptime() {
	echo "SYSTEM UPTIME: "
	uptime
	echo
}

show_header
check_disk
check_memory
check_uptime

echo "============= Health Report Generated ============="

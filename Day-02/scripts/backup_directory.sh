#!/bin/bash


source_dir="$1"
backup_dir="../backups"

if [ -z "$source_dir" ]; then
	echo "Usage: $0 <directory>"
	exit 1
fi

if [ ! -d "$source_dir" ]; then
	echo "ERROR: Directory '$source_dir' does not exists."
	exit 2
fi

mkdir -p "$backup_dir"

timestamp=$(date +%Y-%m-%d_%H:%M:%S)

backup_file="$backup_dir/backup_$timestamp.tar.gz"

tar -czf "$backup_file" "$source_dir"

if [ $? -eq 0 ]; then
	echo "Backup Created Successfully: "
	echo "$backup_file"
	exit 0
else
	echo "ERROR: Backup failed."
	exit 3
fi

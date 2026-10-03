#!/bin/bash

name="Saksham"

challenge="90-days-DevOps Challenge"


curr_user=$(whoami)
curr_dir=$(pwd)
curr_date=$(date)
kernel_version=$(uname -r)



echo "Hello, $name!"
echo "Challenge: $challenge"
echo "User: $curr_user"
echo "Directory: $curr_dir"
echo "Today's Date: $curr_date"
echo "Kernel: $kernel_version"



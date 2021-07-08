#!/bin/bash

# This script will only work correctly with the custom Jetson nano image prepared for the PiK8kE testbed

# Run this *as root* inside your Jetson nano after it boots up for the first time

if [[ $# -eq 0 ]] ; then
    echo 'Usage: $1 XYZ, where XYZ is the last octet of the PiK8kE virtual IP address (include leading zeroes)'
    exit 0
fi

# name of evio config file
EVIO_CONFIG_FILE=config-$1.json

if [ ! -f "$EVIO_CONFIG_FILE" ]; then
    echo "$EVIO_CONFIG_FILE does not exist."
    exit 0
fi

# Install evio
echo "deb [trusted=yes] https://apt.fury.io/evio/ * *" > /etc/apt/sources.list.d/fury.list
apt update
apt install evio

# copy evio configuration file
mkdir -p /etc/opt/evio
cp $EVIO_CONFIG_FILE /etc/opt/evio/config.json

# add authorized_keys for remote installation via ssh
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat authorized_keys >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# start evio
systemctl start evio

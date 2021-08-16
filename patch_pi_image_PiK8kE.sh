#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Usage: $1 XYZ, where XYZ is the last octet of the PiK8kE virtual IP address (include leading zeroes)'
    exit 0
fi

# name of the base image file
PI_IMAGE_FILE=ubuntu-20.04.2-preinstalled-server-arm64+raspi.img.xz

# name of evio config file
EVIO_CONFIG_FILE=config-$1.json

# name of cloud-init files
USER_DATA_FILE=user-data-PiK8kE.yml
NETWORK_CONFIG_FILE=network-config-PiK8kE.yml

# constants for the loopback mount - can be found with fdisk -d on the image
LOOP_BOOT_START=2048
LOOP_BOOT_SIZE=524288
LOOP_BOOT_BLOCK=512
LOOP_ROOT_START=526336
LOOP_ROOT_SIZE=5839840
LOOP_ROOT_BLOCK=512

if [ ! -f "$PI_IMAGE_FILE" ]; then
    echo "$PI_IMAGE_FILE does not exist."
    exit 0
fi

if [ ! -f "$EVIO_CONFIG_FILE" ]; then
    echo "$EVIO_CONFIG_FILE does not exist."
    exit 0
fi

if [ ! -f "$USER_DATA_FILE" ]; then
    echo "$USER_DATA_FILE does not exist."
    exit 0
fi

if [ ! -f "$NETWORK_CONFIG_FILE" ]; then
    echo "$NETWORK_CONFIG_FILE does not exist."
    exit 0
fi

# create directories to loop-mount boot and root partitions
mkdir -p mnt_boot
mkdir -p mnt_root

# copy base image file
cp $PI_IMAGE_FILE PiK8kE-$1.img.xz

# extract
xz -d PiK8kE-$1.img.xz

# mount boot partition
sudo mount -t vfat -o loop,rw,offset=$(($LOOP_BOOT_START * $LOOP_BOOT_BLOCK)),sizelimit=$(($LOOP_BOOT_SIZE * $LOOP_BOOT_BLOCK)) ./PiK8kE-$1.img ./mnt_boot

# copy cloud-init data
sudo cp $USER_DATA_FILE ./mnt_boot/user-data
sudo cp $NETWORK_CONFIG_FILE ./mnt_boot/network-config

# patch cmdline.txt
sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' ./mnt_boot/cmdline.txt

# unmount boot partition
sudo umount ./mnt_boot

# mount root partition
sudo mount -t ext4 -o loop,rw,offset=$(($LOOP_ROOT_START * $LOOP_ROOT_BLOCK)),sizelimit=$(($LOOP_ROOT_SIZE * $LOOP_ROOT_BLOCK)) ./PiK8kE-$1.img ./mnt_root

# copy evio config
sudo mkdir -p mnt_root/etc/opt/evio
sudo cp $EVIO_CONFIG_FILE mnt_root/etc/opt/evio/config.json

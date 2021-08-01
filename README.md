# PiK8kE

Tools to prepare images to flash Raspberry Pi 4 SD cards and customize Jetson nano devices to join the PRAGMA PiK8kE testbed

# Introduction

PiK8kE is an evolving international testbed for federated edge computing on Raspberry Pi 4 and Jetson nano devices using Kubernetes (with other architectures such as Jetson planned for future expansion). The tools in this repository are used to create custom images to join the testbed.

Currently, the testbed is restricted to members of [PRAGMA](http://www.pragma-grid.net). [You can check our overlay visualizer](http://viz.edgevpn.io:5802/#/) to see the current state of the network.

If you are interested in using the software for your own testbed, the developers are considering expansion plans for the future, so please feel free to contact us. 

# What you'll need

To join the testbed, you'll need:

* One or more edge devices. Currently, we support Raspberry Pi 4 and nVidia Jetson Nano devices, with at least 2GB memory, 4 cores, and 64GB SD card storage
* An Ethernet (wired or wireless) network to connect the Pis to. The recommended setup is to deploy on a private network, with DHCP assigned addresses
* The Pi needs to be connected to the Internet when you first boot it in order for it to self-configure into the virtual network
* PiK8kE configuration files for [EdgeVPN.io](https://edgevpn.io) handed out by the PRAGMA PiK8kE team (Renato or Ken)
* Ubuntu 20.04 server Raspberry Pi base image, or Ubuntu 18.04 Jetson Nano base image
* A Linux computer with a micro SD card reader, and software to flash the SD card

*Note: the testbed runs Docker and Kubernetes, and software is installed and managed by a front-end node via ansible. The front-end node needs public ssh keys configured to allow the testbed system managers to remotely ssh and escalate to root privileges in order to install and run Docker+Kubernetes. Please make sure you are comfortable with this prior to agreeing to join. Please contact the PiK8kE team if you have any questions*

# Raspberry Pi 4 setup

The Raspberry Pi setup is the simplest one: essentially, create custom images for each device following the instructions below, then plugging in to each Pi, and turning them on

## Creating a custom Raspberry Pi 4 image

* Create a folder PiK8kE on your Linux computer and clone this repository with git clone https://github.com/renatof/PiK8kE.git
* [Download the 64-bit Ubuntu 20.04.2 LTS image](https://ubuntu.com/download/raspberry-pi) to your Linux computer
* Copy the config-XYZ.json EdgeVPN.io configuration files for your IP address allocation. Here, XYZ describes the last octet of the virtual IP address (with leading zeroes if necessary). The first three bytes are 10.10.100. For example, config-004.json is the configuration for node 10.10.100.4
* Edit the cloud-init file user-data-PiK8kE to customize for your site:

1) _You must change the password for the ubuntu user from the default PiK8kE to a secure password_
2) or, alternatively (and preferably) you may add a ssh authorize public key(s) and disable password login by setting ssh_pwauth: false in the cloud-init file
3) Please don't delete the existing ssh authorized_key - that is required for remote installation and management of Kubernetes via ansible

* (Optional) edit the cloud-init file network-config-PiK8kE if you need for your local site. By default, it is configured to use DHCP on eth0 (wired Ethernet) - if that is avaialble on your site, there's nothing you need to change.
* (Optional) edit the config-XYZ.json files and enter your site's geographical coordinates (lat/lon separated by comma) in the JSON "GeoCoordinate" key. This is not required but helps us keep track of where nodes are running on a map
* Run the patch script to create a custom image PiK8kE-XYZ.img for IP address 10.10.100.XYZ

```
./patch_pi_image_PiK8kE.sh XYZ
```

Then, you're ready to flash the SD card with PiK8kE-XYZ.img, plug it into your Pi, and boot it up. *Note: make sure the Pi is connected to the Internet when you first boot it - the cloud-init boot process needs Internet connectivity to automatically install and configure the EdgeVPN.io virtual network*. 

# Joining the Kubernetes cluster 

Please contact the PRAGMA PiK8kE team (Renato, Shinji, or Ken) to give a heads-up that your device is up and running, so we can add it to the Kubernetes cluster.

Once your node is connected to the Kubernetes cluster, we will work with you to create a user account on the kubectl submit node so that you can start deploying containers across the virtual cluster.

# nVidia Jetson Nano setup

The Jetson nano setup is more involved, and requires more manual steps for each device added to the network - we currently do not have a similar mechanism to the Pi 4 where you would create/flash a custom SD card on a Linux machine.

## Customizing a Jetson nano device

### Initial boot from nVidia's stock image

* Flash an SD card for your device using the default nVidia Ubuntu 18.04 image that you can download from their developer's site
* Boot up the Jetson Nano with the default nVidia SD card, and go through the interactive process of configuring your device with timezone, user name, etc. For consistency with the rest of the network, create a user account called ubuntu

### Install custom kernel with PiK8kE dependences for OVS/Evio and K8s

* Once the GUI interface is available, open a terminal and download the custom PiK8kE kernel tarball jetson-custom-kernel-PiK8kE.tgz into the root folder of your device. Please contact the PRAGMA team for a download link
* Install the custom kernel and reboot:

```
sudo bash
cd /
(download jetson-custom-kernel-PiK8kE.tgz from link provided to you)
tar -xf jetson-custom-kernel-PiK8kE.tgz
reboot
```

* After rebooting, you're ready to install an up-to-date version of iset - a dependency from K8s - then the rest of the software

### Build ipset v7.5

* Make sure you have rebooted with the new kernel from the previous step
* First, build and install libmnl

```
git clone git://git.netfilter.org/libmnl.git
cd libmnl
./autogen.sh
./configure
make
sudo make install
```

* Now, build and install ipset

```
git://git.netfilter.org/ipset.git
cd ipset
./autogen.sh
./configure
make
make modules
sudo make install
sudo make modules_install
```

* Place new ipset under /sbin

```
sudo mv /sbin/ipset /sbin/ipset-v6
sudo cp /usr/local/sbin/ipset /sbin
```

* Double-check you are running the new ipset:

```
sudo ipset -v
ipset v7.14, protocol version: 7
```

### Install and run Evio

* Download the PiK8kE installation script: git clone https://github.com/renatof/PiK8kE
* Download the Evio configuration file for your node, config-XYZ.json, that you obtained for your device(s) from the PRAGMA team
* (Optional) edit the config-XYZ.json files and enter your site's geographical coordinates (lat/lon separated by comma) in the JSON "GeoCoordinate" key. This is not required but helps us keep track of where nodes are running on a map
* Execute the installation script, passing XYZ (3-digit of the last octet of the Evio IP address) as an argument; make sure the config-XYZ.json is present:

```
sudo bash
./setup_jetson_nano_PiK8kE.sh XYZ
```

* Please contact the PRAGMA PiK8kE team (Renato or Ken) to give a heads-up that your device is up and running.


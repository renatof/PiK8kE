# PiK8kE

Tools to prepare images to flash Raspberry Pi 4 SD cards to join the PRAGMA PiK8kE testbed

# Introduction

PiK8kE is an evolving international testbed for federated edge computing on Raspberry Pi 4 devices (with other architectures such as Jetson planned for future expansion). The tools in this repository are used to create custom images to join the testbed.

Currently, the testbed is restricted to members of [PRAGMA](http://www.pragma-grid.net). If you are interested in using the software for your own testbed, the developers are considering expansion plans for the future, so please feel free to contact us.

# What you'll need

To join the testbed, you'll need:

* One or more Raspberry Pi devices, with at least 2GB memory, 4 cores, and 64GB SD card storage
* An Ethernet (wired or wireless) network to connect the Pis to. The recommended setup is to deploy on a private network, with DHCP assigned addresses
* PiK8kE configuration files for [EdgeVPN.io](https://edgevpn.io) handed out by the PRAGMA PiK8kE team (Renato or Ken)
* A Ubuntu 20.04 server Raspberry Pi base image
* A Linux computer with a micro SD card reader, and software to flash the SD card

# Creating a custom image

* Create a folder PiK8kE on your Linux computer and clone this repository with git clone https://github.com/renatof/PiK8kE.git
* [Download the 64-bit Ubuntu 20.04.2 LTS image](https://ubuntu.com/download/raspberry-pi) to your Linux computer
* Copy the config-XYZ.json EdgeVPN.io configuration files for your IP address allocation. Here, XYZ describes the last octet of the virtual IP address (with leading zeroes if necessary). The first three bytes are 10.10.100. For example, config-004.json is the configuration for node 10.10.100.4
* Edit the cloud-init file user-data-PiK8kE to: 1) change the password for the ubuntu user from PiK8kE to a secure password, 2) add any ssh authorized keys you'd like to include to authenticate to the ubuntu user. Please don't delete the existing ssh authorized_key - that is required for remote installation and management of Kubernetes.
* (Optional) edit the cloud-init file network-config-PiK8kE if you need for your local site. By default, it is configured to use DHCP on eth0 (wired Ethernet) - if that is avaialble on your site, there's nothing you need to change.
* (Optional) edit the config-XYZ.json files and enter your site's geographical coordinates (lat/lon separated by comma) in the JSON "GeoCoordinate" key. This is not required but helps us keep track of where nodes are running on a map
* Run the patch script to create a custom image PiK8kE-XYZ.img for IP address 10.10.100.XYZ

```
./patch_pi_image_PiK8kE.sh XYZ
```

Then, you're ready to flash the SD card with PiK8kE-XYZ.img, plug it into your Pi, and boot it up. The cloud-init boot process will automatically install and configure the EdgeVPN.io virtual network. Please contact the PRAGMA PiK8kE team (Renato or Ken) to give a heads-up that your device is up and running.




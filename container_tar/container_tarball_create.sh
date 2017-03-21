#!/bin/bash

set -eux

# Check if this script is running as root as sudo user
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, try sudo if you have the rights" 1>&2
   exit 1
fi

# Initialize variables
INSTALL_PKGS1="libvirt-*";
INSTALL_PKGS2="virt-install libguestfs";
KS_FILE_URL="https://raw.githubusercontent.com/kbsingh/atomic-container/master/container_tar/centos-docker-base-minimal.ks";
CENTOS_INSTALL_SOURCE_URL=${CENTOS_INSTALL_SOURCE_URL-"http://mirror.centos.org/centos/7/os/x86_64"};
VM_DOMAIN=${VM_DOMAIN-"centos_atomic_image"};
VM_NETWORK=${VM_NETWORK-"default"};
IMAGE_TAR_NAME=${IMAGE_TAR_NAME-"centos_atomic.tar"};

# Install necessary packages
yum -y install ${INSTALL_PKGS1};
yum -y install ${INSTALL_PKGS2};

# If enable and start libvirtd
systemctl enable libvirtd && systemctl start libvirtd;

virt-install --name ${VM_DOMAIN} --noreboot --memory 4096 --vcpus 1,cpuset=auto \
     --disk size=2,sparse=no,format=raw --network network=${VM_NETWORK} \
     --graphics=none --console pty,target_type=serial \
     --location ${CENTOS_INSTALL_SOURCE_URL} --extra-args "console=ttyS0,115200n8 serial ks=${KS_FILE_URL}";

virt-tar-out -d "${VM_DOMAIN}" / ${IMAGE_TAR_NAME};

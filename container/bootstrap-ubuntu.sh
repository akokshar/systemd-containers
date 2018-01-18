#!/bin/bash

set +x

SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)

SUITE=artful
MIRROR=http://archive.ubuntu.com/ubuntu

MACHINE_NAME=ubuntu
MACHINE_PATH=/var/lib/machines/$MACHINE_NAME

btrfs subvolume create $MACHINE_PATH

debootstrap \
    --arch=amd64 \
    --variant=minbase \
    --include=systemd,dbus \
    --merged-usr \
    $SUITE $MACHINE_PATH $MIRROR

cp $SCRIPT_DIR/80-container-host0.network $MACHINE_PATH/etc/systemd/network/
echo "pts/0" >> $MACHINE_PATH/etc/securetty
echo $MACHINE_NAME > $MACHINE_PATH/etc/hostname

systemd-nspawn \
    --private-users=pick \
    --private-users-chown \
    -D $MACHINE_PATH \
    /bin/bash -c 'systemctl enable systemd-networkd && systemctl disable systemd-resolved'


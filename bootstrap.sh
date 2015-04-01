#!/bin/bash -ex

if date | grep -q 'UTC'; then
    ln -fs "/usr/share/zoneinfo/Asia/Tokyo" "/etc/localtime"
fi

sudo apt-get update -y
sudo apt-get upgrade -y


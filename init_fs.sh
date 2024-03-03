#!/bin/bash

echo
echo -e "\033[1;33mCreate loop device for SDcard image.\033[0m"
sudo losetup -P /dev/loop21 ../runtime/sdcard.img



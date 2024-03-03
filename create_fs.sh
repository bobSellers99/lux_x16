#!/bin/bash

echo -e "\033[1;33mCreate runtime directory and SDcard mount point.\033[0m"
set -e
mkdir  runtime
mkdir  runtime/x16fs

echo
echo -e "\033[1;33mDecompressing blank SDcard image.\033[0m"
unzip sdcard/sdcard.img.zip -d runtime

echo
echo -e "\033[1;33mCreate loop device for SDcard image.\033[0m"
sudo losetup -P /dev/loop21 runtime/sdcard.img

echo
echo -e "\033[1;33mMount SDcard image to runtime/x16fs.\033[0m"
sudo mount -v /dev/loop21p1 runtime/x16fs -o uid=bsellers -o gid=bsellers

echo
echo -e "\033[1;33mCopy default files.\033[0m"
cp -rv sdcard/image/* runtime/x16fs

echo
echo -e "\033[1;33mUnmount SDcard image from runtime/x16fs.\033[0m"
sudo umount -v runtime/x16fs

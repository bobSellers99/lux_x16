#!/bin/bash
echo

echo -e "\033[1;33mBuilding Asset editor (asset) for the X16.\033[0m"
set -e
cd asset/asset
make

echo -e "\033[1;32mBuilding Palette editor module.\033[0m"
set -e
cd ../palette
make

echo -e "\033[1;32mBuilding Keymap editor module.\033[0m"
set -e
cd ../keymap
make

echo -e "\033[1;32mBuilding Tile editor module.\033[0m"
set -e
cd ../tile
make

echo -e "\033[1;32mBuilding Screen editor module.\033[0m"
set -e
cd ../screen
make

cd ../
rm -f ../lib/asm/*.o

echo
echo -e "\033[1;33mMount SDcard image to runtime/x16fs.\033[0m"
sudo mount -v /dev/loop21p1 ../runtime/x16fs -o uid=bsellers -o gid=bsellers

echo
echo -e "\033[1;33mCopy executable files.\033[0m"
cp -v asset/asset ../runtime/x16fs/bin/asset
cp -v palette/palette ../runtime/x16fs/bin/asset
cp -v keymap/keymap ../runtime/x16fs/bin/asset
cp -v tile/tile ../runtime/x16fs/bin/asset
cp -v screen/screen ../runtime/x16fs/bin/asset

#cp -r ../../runtime/x16fs/* ../../lux_x16/sdcard_copy
echo
echo -e "\033[1;33mUnmount SDcard image from runtime/x16fs.\033[0m"
sudo umount -v ../runtime/x16fs

cd ../runtime
./box16 -rom lux.bin -sdcard sdcard.img -nobinds


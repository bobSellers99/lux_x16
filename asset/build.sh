#!/bin/bash
echo

echo -e "\033[1;33mBuilding Asset editor (asset) for the X16.\033[0m"
set -e
cd asset
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

sudo mount /dev/loop21p1 ../../runtime/lux/x16fs -o uid=bsellers -o gid=bsellers
cp asset/asset ../../runtime/lux/x16fs/bin/asset
cp palette/palette ../../runtime/lux/x16fs/bin/asset
cp keymap/keymap ../../runtime/lux/x16fs/bin/asset
cp tile/tile ../../runtime/lux/x16fs/bin/asset
cp screen/screen ../../runtime/lux/x16fs/bin/asset

cp -r ../../runtime/lux/x16fs/* ../../lux_x16/sdcard_copy

sudo umount ../../runtime/lux/x16fs

cd ../../runtime/lux
./box16 -rom lux.bin -sdcard sdcard.img -nobinds


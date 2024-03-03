#!/bin/bash
echo
echo -e "\033[1;33mBuilding Light Unix-like Command Shell (lux) for the X16.\033[0m"
set -e

cd ./lux/bios
make
cd ../lib_1
make
cd ../cmds
make
cd ../shell
make
cd ..

# Copy files to the emulator SDcard
echo
echo -e "\033[1;33mMount SDcard image to runtime/x16fs.\033[0m"
sudo mount -v /dev/loop21p1 ../runtime/x16fs -o uid=bsellers -o gid=bsellers

echo
echo -e "\033[1;33mCopy executable files.\033[0m"
cp -v shell/lux ../runtime/x16fs/bin/lux
cp -v cmds/version ../runtime/x16fs/bin
cp -v cmds/ls ../runtime/x16fs/bin
cp -v cmds/cd ../runtime/x16fs/bin
cp -v cmds/setclock ../runtime/x16fs/bin
cp -v cmds/mkdir ../runtime/x16fs/bin
cp -v cmds/rmdir ../runtime/x16fs/bin
cp -v cmds/rm ../runtime/x16fs/bin
cp -v lib_1/lib_1.bin ../runtime/x16fs/bin/lux

echo
echo -e "\033[1;33mUnmount SDcard image from runtime/x16fs.\033[0m"
sudo umount -v ../runtime/x16fs

#cat ./bios/bios.bin ./lib_1/lib_1.bin > lux.bin
cp ./bios/bios.bin ../runtime/lux.bin
#cp lux.bin ../../runtime
#cp lux.bin /home/bsellers/Projects/minipro
cd ../runtime

./box16 -rom lux.bin -sdcard sdcard.img -nobinds

#minipro -p SST39SF040 -w "lux.bin" -s



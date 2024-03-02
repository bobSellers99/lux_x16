#!/bin/bash
echo
echo -e "\033[1;33mBuilding Light Unix-like Command Shell (lux) for the X16.\033[0m"
set -e

cd ./bios
make
cd ../lib_1
make
cd ../cmds
make
cd ../shell
make
cd ..

# Copy files to the emulator SDcard
sudo mount /dev/loop21p1 ../../runtime/lux/x16fs -o uid=bsellers -o gid=bsellers
cp shell/lux ../../runtime/lux/x16fs/bin/lux
cp cmds/version ../../runtime/lux/x16fs/bin
cp cmds/ls ../../runtime/lux/x16fs/bin
cp cmds/cd ../../runtime/lux/x16fs/bin
cp cmds/setclock ../../runtime/lux/x16fs/bin
cp cmds/mkdir ../../runtime/lux/x16fs/bin
cp cmds/rmdir ../../runtime/lux/x16fs/bin
cp cmds/rm ../../runtime/lux/x16fs/bin
cp lib_1/lib_1.bin ../../runtime/lux/x16fs/bin/lux
sudo umount ../../runtime/lux/x16fs

# Copy files to the physical SDcard transfer dir.
cp shell/lux ../sdcard_copy/bin/lux
cp lib_1/lib_1.bin ../sdcard_copy/bin/lux
cp cmds/version ../sdcard_copy/bin
cp cmds/ls ../sdcard_copy/bin
cp cmds/cd ../sdcard_copy/bin
cp cmds/setclock ../sdcard_copy/bin
cp lib_1/lib_1.bin ../sdcard_copy/bin/lux

#cat ./bios/bios.bin ./lib_1/lib_1.bin > lux.bin
cp ./bios/bios.bin lux.bin
cp lux.bin ../../runtime/lux
cp lux.bin /home/bsellers/Projects/minipro
cd ../../runtime/lux

./box16 -rom lux.bin -sdcard sdcard.img -nobinds

#minipro -p SST39SF040 -w "lux.bin" -s



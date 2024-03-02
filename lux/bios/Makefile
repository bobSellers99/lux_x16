
all:
	cl65 -t none -C bios.cfg -o bios.bin -l bios.list -Ln bios.sym \
	asm/main.asm asm/file.asm asm/int.asm  asm/ps2_keyboard.asm \
	asm/ps2_mouse.asm asm/scheduler.asm asm/fat32.s asm/match.s \
	asm/sdcard.s asm/text_input.s \
	asm/mkfs.s asm/i2c.s asm/joystick.s asm/rtc.s
	rm -f asm/*.o
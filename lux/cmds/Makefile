all:
	cl65 -t none -C cmd.cfg -o version -Ln asm/version.sym -m asm/version.map \
	asm/version.asm

	cl65 -t none -C cmd.cfg -o ls -Ln asm/ls.sym -m asm/ls.map \
	asm/ls.asm

	cl65 -t none -C cmd.cfg -o cd -Ln asm/cd.sym -m asm/cd.map \
	asm/cd.asm

	cl65 -t none -C cmd.cfg -o setclock -Ln asm/setclock.sym -m asm/setclock.map \
	asm/setclock.asm \
	../bios/asm/i2c.s ../bios/asm/rtc.s

	cl65 -t none -C cmd.cfg -o mkdir -Ln asm/mkdir.sym -m asm/mkdir.map \
	asm/mkdir.asm

	cl65 -t none -C cmd.cfg -o rmdir -Ln asm/rmdir.sym -m asm/rmdir.map \
	asm/rmdir.asm

	cl65 -t none -C cmd.cfg -o rm -Ln asm/rm.sym -m asm/rm.map \
	asm/rm.asm

	rm -f asm/*.o

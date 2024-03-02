all:
	cl65 -t none -C tile.cfg -o tile -Ln tile.sym -m tile.map \
	asm/main.asm asm/vera.asm asm/menu1.asm asm/loop.asm asm/area.asm \
	asm/edit.asm asm/data.asm asm/palette.asm asm/suspend.asm

	rm -f asm/*.o

clean:
	rm -f asm/*.o
	rm -f *.sym

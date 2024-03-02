all:
	cl65 -t none -C shell.cfg -o palette -Ln palette.sym -m palette.map \
	asm/main.asm asm/area.asm asm/vera.asm asm/menu1.asm asm/loop.asm \
	asm/edit.asm

	rm -f asm/*.o

clean:
	rm -f asm/*.o
	rm -f *.sym

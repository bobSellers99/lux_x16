all:
	cl65 -t none -C shell.cfg -o lux -Ln shell.sym -m shell.map \
	asm/main.asm asm/vera.asm asm/edit.asm asm/term.asm asm/find.asm \
	asm/history.asm
	rm -f asm/*.o

clean:
	rm -f asm/*.o
	rm -f cmds/*.o
	rm -f *.prg
	rm -f *.sym

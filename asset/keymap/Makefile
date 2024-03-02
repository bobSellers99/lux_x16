all:
	cl65 -t none -C shell.cfg -o keymap -Ln keymap.sym -m keymap.map \
	asm/main.asm asm/vera.asm asm/menu1.asm asm/loop.asm  asm/data.asm

	rm -f asm/*.o

clean:
	rm -f asm/*.o
	rm -f *.sym

all:
	cl65 -t none -C shell.cfg -o screen -Ln screen.sym -m screen.map \
	asm/main.asm asm/area.asm asm/edit.asm asm/loop.asm asm/menu1.asm \
	asm/vera.asm
	  
	rm -f asm/*.o
	rm -f ../lib/asm/*.o

clean:
	rm -f asm/*.o
	rm -f *.sym

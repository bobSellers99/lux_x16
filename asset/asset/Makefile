all:
	cl65 -t none -C asset.cfg -o asset -Ln asset.sym -m asset.map \
	asm/main.asm asm/loop.asm asm/area.asm asm/menu1.asm asm/vera.asm
	  
	rm -f asm/*.o

clean:
	rm -f asm/*.o
	rm -f *.sym

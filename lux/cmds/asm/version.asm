;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.pc02
.org $3000
.segment "CODE"

print_char    = $0303


jmp main_version

ver_str:        .byte "LUX Command Shell version 0.26",0


main_version:
	ldx #0
	@print:
		lda ver_str,x
		beq @return
		jsr print_char
		inx
		bra @print

	@return:
	rts

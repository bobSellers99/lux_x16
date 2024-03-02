;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02

.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/sz.inc"

;.org $3000
.segment "CODE"

print_char			= $0303
set_color			= $0307
lux_cmd_str			= $030c

file_delete			= $ff36


jmp main

new_dir:		.res 256
help_str:		.byte "Remove file at current or absolute path",13,0
help_str2:		.byte "Usage: rm <path>file_te_delete",0
error_str:		.byte "Cannot remove file",0


.macro print string, color
	lda color
	jsr set_color
	memSet_16_16 string, zp_ind
	jsr print_help
	.endmacro


.export print_help
.proc print_help
	ldy #0
	@print:
		lda (zp_ind),y
		beq @return
		jsr print_char
		iny
		bra @print

	@return:
	rts
	.endproc
	

.export main
.proc main
	szGetNumParams #lux_cmd_str, #' '
	cmp #1
	beq :+ 

	print #help_str, #3
	print #help_str2, #7
	rts

	:
	szGetParam #lux_cmd_str, #new_dir, #1, #' '
	memSet_16_16 #new_dir, fat32_ptr 
	jsr file_delete
	bcs @return

	print #error_str, #4

	@return:
	rts
	.endproc

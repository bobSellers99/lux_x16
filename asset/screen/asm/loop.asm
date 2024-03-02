;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_LOOP_ASM_:
.include "../inc/screen.inc"

.export loop_
loop_:

.export loop_last_ascii
.export loop_help_on

loop_debug_on:		.byte 0
loop_help_on:		.byte 0
loop_last_ascii:	.byte 0

help_screen_fn:		.byte "screen.help",0		

.export loop_key_input
.proc loop_key_input
	lda ctl_focus
	bne @return
	lda kyb_ascii
	stz kyb_ascii
	cmp #$dd	; Ctl-Q (Quit)
	beq @quit
	cmp #$eb	; Ctl-S (Suspend)
	beq @suspend
	cmp #$ef	; Ctl-H (Help)
	beq @help

	cmp #'d'
	beq @set_status_mode
	@return:
	rts

	@quit:
	lda #1
	sta main_run
	rts

	@suspend:
	lda #1
	sta main_run
	rts

	@help:
	jsr loop_help
	rts

	@set_status_mode:
	lda loop_debug_on
	eor #$01
	sta loop_debug_on
	textBlank #0, #0, #80, #$b1

	lda loop_debug_on
	beq @set_status_on
	rts

	@set_status_on:
	jsr loop_set_status_mode
	; Draw initial image of status line.
	textString #22, #0 ,#main_txt_title ,#$b1
	rts
	.endproc


.export loop_help
.proc loop_help
	lda loop_help_on
	eor #$01
	sta loop_help_on
	beq @help_off
	metaCopyScreen VRAM_textmap, #1, #$1c00
	metaLoadScreen VRAM_textmap, #help_screen_fn
	rts

	@help_off:
	metaRestoreScreen VRAM_textmap, #1, #$1c00
	.endproc



.export loop_set_status_mode
.proc loop_set_status_mode
	rts
	.endproc


.export loop_set_mouse_image
.proc loop_set_mouse_image
	memSet_IMM_24 VRAM_mouse, ZP24_R1
	
	lda ctl_state
	if_case_else #CTL_STATE_OVER
	math_ADD_IMM_24 256, ZP24_R1

:	if_case_else #CTL_STATE_PRESSED
	math_ADD_IMM_24 256, ZP24_R1

	; params: id, z_order, X, Y 
:	sprite_set #0, #3, mouse_x, mouse_y
	rts
	.endproc


.export loop_status_line
.proc loop_status_line
	lda loop_debug_on
	bne @do_debug
	rts

	@do_debug:
	jsr loop_debug
	rts
	.endproc


.export loop_status
.proc loop_status
	rts
	.endproc


.export loop_debug
.proc loop_debug
	; Keyboard 
	mathBinToBcd_16 scan_code
	textBcd_16 #10, #0, #3, #$b1

	mathBinToBcd_8 loop_last_ascii
	textBcd_16 #14, #0, #3, #$b1

	; Mouse
	mathBinToBcd_16 mouse_x
	textBcd_16 #18, #0, #3, #$b1

	mathBinToBcd_16 mouse_y
	textBcd_16 #22, #0, #3, #$b1

	mathBinToBcd_16 mouse_btns
	textBcd_16 #26, #0, #2, #$b1

	; Controls
	jsr ctl_debug
	rts
	.endproc

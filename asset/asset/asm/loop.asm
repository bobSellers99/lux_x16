;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_LOOP_ASM_:
.include "../inc/asset.inc"

.export loop_
loop_:
.segment "BSS" 

.export loop_last_ascii

loop_debug_on:		.byte 0
loop_last_ascii:	.byte 0

.segment "CODE"


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
;	jsr loop_help
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
	textString #34, #0 ,#main_txt_title ,#$b1
	rts
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
;	jsr loop_status
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


.export loop_init
.proc loop_init
	; Check for asset checksum.
	stz asset_checksum
	clc

	szCopy #main_key, #asset_key

	memSet_16_16 #asset_key, zp_ind
	lda asset_checksum
	ldy #0
	adc (zp_ind),y
	sta asset_checksum
	lda asset_checksum
	iny
	adc (zp_ind),y
	sta asset_checksum
	lda asset_checksum
	iny
	adc (zp_ind),y
	sta asset_checksum
	lda asset_checksum
	iny
	adc (zp_ind),y
	sta asset_checksum


	stz loop_debug_on
	rts
	.endproc

;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_LOOP_ASM_:
.include "../inc/main.inc"

.export loop_
loop_:

.export loop_last_ascii
.export loop_help_on

.segment "DATA"

loop_debug_on:		.byte 0
loop_help_on:		.byte 0

.segment "CODE"

loop_last_ascii:	.byte 0
help_screen_fn:		.byte "tile.help",0		

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
	beq @dropper
;	cmp #'f'
;	beq @fill
;	cmp #'g'
;	beq @global_fill
	cmp #'e'	
	beq @set_status_mode

	cmp #$86	; Page up
	beq @page_up
	cmp #$87	; Page down
	beq @page_down

	cmp #$d1	; Ctl-X (delete)
	beq @delete
	cmp #$d2	; Ctl-C (copy)
	beq @copy
	cmp #$d3	; Ctl-V (paste)
	beq @paste

	cmp #$80	; Left arrow
	beq @left_arrow
	cmp #$81	; Right arrow
	beq @right_arrow
	cmp #$82	; Up arrow
	beq @up_arrow
	cmp #$83	; Down arrow
	beq @down_arrow

	@return:
	rts

	@quit:
	jsr suspend_clear
	lda #1
	sta main_run
	rts

	@suspend:
	jsr suspend_save
	lda #1
	sta main_run
	rts

	@help:
	jsr loop_help
	rts

	@dropper:
	jsr edit_dropper
	rts

	@fill:
	jsr edit_fill
	rts

	@global_fill:
;	jsr edit_global_fill
	rts

	@set_status_mode:
	lda loop_debug_on
	eor #$01
	sta loop_debug_on
	textBlank #0, #0, #80, #$b1

	lda loop_debug_on
	beq @set_status_on
	rts

	@page_up:
	jsr area_page_up
	rts

	@page_down:
	jsr area_page_down
	rts

	@delete:
	jsr data_delete_tile
	math_SUB_16_16 area_base, area_index
	jsr data_load_tile
	rts

	@copy:
	jsr data_copy_tile
	rts

	@paste:
	jsr data_paste_tile
	rts

	@left_arrow:
	jsr data_left_arrow
	rts

	@right_arrow:
	jsr data_right_arrow
	rts

	@up_arrow:
	jsr data_up_arrow
	rts

	@down_arrow:
	jsr data_down_arrow
	rts

	@set_status_on:
	jsr loop_set_status_mode
	; Draw initial image of status line.
	textString #34, #0 ,#main_txt_title ,#$b1
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


.export loop_set_mouse_image 
.proc loop_set_mouse_image
	memSet_IMM_24 VRAM_mouse, ZP24_R1
	sprite_set #0, #3, mouse_x, mouse_y
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


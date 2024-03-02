;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_AREA_ASM_:
.include "../inc/palette.inc"

.export area_
.export area_selected

area_:

area_selected:		.byte 0
area_win_id:		.byte 0
area_name_id:		.byte 0
area_name_sze:		.res 37 ; 32 chars max plus 4 byte overhead and null

text_hex:		.byte '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
area_background_fn:   .byte "palette.scr",0
area_name_def:		.byte 0
area_str_file:		.byte "File:",0
area_str_load:		.byte " Load ",0
area_str_save:		.byte " Save ",0

.export area_init

.proc area_name_callback
	if_case_else #CTL_STATE_OVER
		textStringEdit #area_name_sze ,#$b7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textStringEdit #area_name_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_NORMAL
		textStringEdit #area_name_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr area_name_mouse_left
		rts

:	if_case_else #CTL_KEY_INPUT
		lda ctl_focus
		cmp area_name_id
		bne :+
		jsr ctl_edit_process
:		rts
	.endproc


.proc area_name_mouse_left
	ctlEditBegin #area_name_sze
	rts
	.endproc


.proc area_load_callback
	if_case_else #CTL_STATE_OVER
		textString #40, #29 ,#area_str_load ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #40, #29 ,#area_str_load ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #40, #29 ,#area_str_load ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr area_load_mouse_left
:		rts
	.endproc


.export area_load_file
.proc area_load_file
	@filename		= zp_ind

	; TODO Checks like this (String cannot be zero length.) need to be in the bios
	szEditGetAddr #area_name_sze, @filename	
	szLength @filename
	beq @return

	; Open VERA_data0 to point to palette location.
	memSet_IMM_24 VRAM_palette, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	fileLoad @filename, #vera_data0, #0, #$80

	@return:
	rts
	.endproc


.export area_load_mouse_left 
.proc area_load_mouse_left
	stz mouse_btns
	jsr area_load_file
	jsr area_set_palette_entry
	rts
	.endproc


.proc area_save_callback
	if_case_else #CTL_STATE_OVER
		textString #48, #29 ,#area_str_save ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #48, #29 ,#area_str_save ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #48, #29 ,#area_str_save ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr area_save_mouse_left
:		rts
	.endproc


.export area_save_file
.proc area_save_file
	@filename		= zp_ind
	; TODO Checks like this (String cannot be zero length.) need to be in the bios
	szEditGetAddr #area_name_sze, @filename	
	szLength @filename
	beq @return

	; Open VERA_data0 to point to palette location.
	memSet_IMM_24 VRAM_palette, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	fileSave @filename, #vera_data0, #$0200, #$80

	@return:
	rts
	.endproc


.export area_save_mouse_left 
.proc area_save_mouse_left
	stz mouse_btns
	jsr area_save_file
	rts
	.endproc


.export area_win_callback 
.proc area_win_callback
	if_case_else #CTL_STATE_RELEASE
		jsr area_mouse_left
:		rts
	.endproc


.export area_set_palette_entry
.proc area_set_palette_entry
	bra @start

		@g:		.byte 0
		@index:	.word 0
		@pal_0:	.byte 0
		@pal_1:	.byte 0
	@start:
	; Insert rgb value into editor.
	lda area_selected
	sta @index
	stz @index+1
	mathShiftUp_16 #1, @index 
	memSet_IMM_24 VRAM_palette, ZP24_R0
	math_ADD_16_24 @index, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	lda vera_data0
	sta @pal_0
	lda vera_data0
	sta @pal_1

	memSet_16_16 #text_hex, zp_ind
	ldy @pal_1
	lda (zp_ind),y 

	sta edit_entry_sze+4	; Char 0 of str.

	lda @pal_0
	sta @g
	mathShiftDown_8 #4, @g
	ldy @g
	lda (zp_ind),y 

	sta edit_entry_sze+5	; Char 1 of str.

	lda @pal_0
	and #$0f
	tay
	lda (zp_ind),y 

	sta edit_entry_sze+6	; Char 2 of str.
	stz edit_entry_sze+7	; Null terminator.

	textStringEdit #edit_entry_sze, #$b1 
	rts
	.endproc


.export area_set_highlight_vram
.proc area_set_highlight_vram
	bra @start

		@offset:	.word 0
	@start:
	memSet_IMM_24 VRAM_textmap, ZP24_R0
	lda area_selected
	clc
	and #$0f
	asl
	adc #$08
	asl
	sta @offset
	lda area_selected
	and #$f0
	ror
	ror
	ror
	ror
	adc #$06
	sta @offset+1
	math_ADD_16_24 @offset, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	rts
	.endproc


.export area_reset_highlight
.proc area_reset_highlight
	jsr area_set_highlight_vram

	lda #$20
	sta vera_data0
	lda #$00
	sta vera_data0
	lda #$20
	sta vera_data0
	lda #$00
	sta vera_data0
	rts
	.endproc


.export area_set_highlight
.proc area_set_highlight
	jsr area_set_highlight_vram

	lda #$a0
	sta vera_data0
	lda #$07
	sta vera_data0
	lda #$a1
	sta vera_data0
	lda #$07
	sta vera_data0
	rts
	.endproc


.export area_mouse_left
.proc area_mouse_left
	bra @start

		@x:		.word 0
		@y:		.word 0
	@start:
	jsr area_reset_highlight

	mem_SET_16_16 mouse_x, @x
	math_SUB_IMM_16 64, @x
	mathShiftDown_16 #4, @x

	mem_SET_16_16 mouse_y, @y
	math_SUB_IMM_16 96, @y
	mathShiftDown_16 #4, @y

	lda @y
	sta area_selected
	mathShiftUp_8 #4, area_selected
	lda area_selected
	ora @x
	sta area_selected

	mathBinToBcd_8 area_selected
	textBcd_8 #26, #4, #3, #$95
	
	jsr area_set_palette_entry
	jsr area_set_highlight
	rts
	.endproc


.export area_background
.proc area_background
	memSet_IMM_24 VRAM_textmap, ZP24_R0
	inc ZP24_R0+1
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr 0, Stride 1	
	fileLoad #area_background_fn, #vera_data0, #0, #$80
	rts
	.endproc


.export area_init
.proc area_init
 	jsr area_background

	ctlCreate #64, #96, #256, #256, #area_win_callback
	sta area_win_id

	textString #0, #29 ,#area_str_file ,#$b5
	szEditInit #area_name_sze, #32, #0, #6, #29, #area_name_def
    ctlCreate #(6*8), #(29*16), #(32*8), #16, #area_name_callback
	sta area_name_id

	ctlCreate #(40*8), #(29*16), #(6*8), #16, #area_load_callback
    ctlCreate #(48*8), #(29*16), #(6*8), #16, #area_save_callback

	mathBinToBcd_8 area_selected
	textBcd_8 #26, #4, #3, #$95

;	jsr area_set_palette_entry
	jsr area_set_highlight
    rts
    .endproc
;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_AREA_ASM_:
.include "../inc/screen.inc"
.export area_
area_:

area_win_id:		.byte 0
area_name_id:		.byte 0

area_name_sze:		.res 37 ; 32 chars (char + color) max plus 4 byte overhead
area_name_def:		.byte 0
area_background_fn:	.byte "screen.scr",0
area_str_file:		.byte "File:",0
area_str_load:		.byte " Load ",0
area_str_save:		.byte " Save ",0


.export area_name_callback 
.proc area_name_callback
	if_case_else #CTL_STATE_OVER
		textStringEdit #area_name_sze ,#$b7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textStringEdit #area_name_sze ,#$cb
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


.export area_name_mouse_left 
.proc area_name_mouse_left
	ctlEditBegin #area_name_sze
	rts
	.endproc


.export area_load_callback 
.proc area_load_callback
	if_case_else #CTL_STATE_OVER
		textString #40, #29 ,#area_str_load ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #40, #29 ,#area_str_load ,#$cb
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
	@filename		= fat32_ptr

	szEditGetAddr #area_name_sze, @filename	
	metaLoadScreen VRAM_textmap, @filename

;	; TODO Checks like this (String cannot be zero length.) need to be in the bios
;	szEditGetAddr #area_name_sze, @filename	
;	szLength @filename
;	beq @return
;
;	; Open VERA_data0 to point to palette location.
;	memSet_IMM_24 VRAM_textmap, ZP24_R0 
;	inc ZP24_R0+1
;	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
;	fileLoad @filename, #vera_data0, #0, #$80
;
;	@return:
	rts
	.endproc


.export area_load_mouse_left 
.proc area_load_mouse_left
	stz mouse_btns
	jsr area_load_file
	rts
	.endproc


.export area_save_callback 
.proc area_save_callback
	if_case_else #CTL_STATE_OVER
		textString #48, #29 ,#area_str_save ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #48, #29 ,#area_str_save ,#$cb
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
	@filename		= fat32_ptr

	szEditGetAddr #area_name_sze, @filename	
	metaSaveScreen VRAM_textmap, @filename, #$1c00

;	@filename		= zp_ind
;
;	; TODO Checks like this (String cannot be zero length.) need to be in the bios
;	szEditGetAddr #area_name_sze, @filename	
;	szLength @filename
;	beq @return
;
;	; Open VERA_data0 to point to palette location.
;	memSet_IMM_24 VRAM_textmap, ZP24_R0 
;	inc ZP24_R0+1
;	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
;	fileSave @filename, #vera_data0, #$1c00, #$80
;
;	@return:
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
	if_case_else #CTL_STATE_PRESSED
		jsr area_win_pressed
		rts

:	if_case_else #CTL_KEY_INPUT
		lda ctl_focus
		cmp area_win_id
		bne :+
		jsr edit_process
:		rts
	.endproc


.export area_left_arrow
.proc area_left_arrow
	lda edit_cursor_x
	beq @return

	dec edit_cursor_x
	jsr edit_set_vram_cursor

	@return:
	rts
	.endproc


.export area_right_arrow
.proc area_right_arrow
	lda edit_cursor_x
	cmp #80
	beq @return

	inc edit_cursor_x
	jsr edit_set_vram_cursor

	@return:
	rts
	.endproc


.export area_up_arrow
.proc area_up_arrow
	lda edit_cursor_y
	cmp #1
	beq @return

	dec edit_cursor_y
	jsr edit_set_vram_cursor

	@return:
	rts
	.endproc


.export area_down_arrow
.proc area_down_arrow
	lda edit_cursor_y
	cmp #28
	beq @return

	inc edit_cursor_y
	jsr edit_set_vram_cursor

	@return:
	rts
	.endproc


.proc area_win_pressed
	lda mouse_btns
	if_case_else #CTL_MOUSE_LEFT
		jsr area_win_mouse_left
		rts

:	if_case_else #CTL_MOUSE_RIGHT
		jsr area_win_mouse_right
:		rts
	.endproc


.export area_win_mouse_left
.proc area_win_mouse_left
	bra @start

		@pos_x:			.word 0
		@pos_y:			.word 0
	@start:
;	stz mouse_btns
	lda area_win_id
	sta ctl_focus
	
	; Modulus down the mouse coords to the upper left corner
	; of the character it's over. This also reduces it from
	; a word to a byte.
	memSet_16_16 mouse_x, @pos_x
	mathShiftDown_16 #3, @pos_x 
	memSet_16_16 mouse_y, @pos_y
	mathShiftDown_16 #4, @pos_y 
	lda @pos_x
	sta edit_cursor_x

	lda @pos_y
	sta edit_cursor_y

	stz edit_block_x
	stz edit_block_y

	jsr edit_set_vram_cursor
	jsr edit_clear_vram_block
	
	rts
	.endproc


.export area_win_mouse_right
.proc area_win_mouse_right
	bra @start

		@pos_x:			.word 0
		@pos_y:			.word 0
	@start:
;	stz mouse_btns
	; Modulus down the mouse coords to the upper left corner
	; of the character it's over. This also reduces it from
	; a word to a byte.
	memSet_16_16 mouse_x, @pos_x
	mathShiftDown_16 #3, @pos_x 
	memSet_16_16 mouse_y, @pos_y
	mathShiftDown_16 #4, @pos_y 
	lda @pos_x
	sta edit_block_x

	lda @pos_y
	sta edit_block_y

	jsr edit_set_vram_block

	rts
	.endproc


.export area_disable
.proc area_disable
	lda area_win_id
	beq @return

	jsr ctl_delete

	@return:
	rts
	.endproc


.export area_enable
.proc area_enable
	ctlCreate #0, #16, #640, #448, #area_win_callback
	sta area_win_id
	rts
	.endproc


.export area_init
.proc area_init
	textString #0, #29 ,#area_str_file ,#$b5
 	szEditInit #area_name_sze, #32, #0, #6, #29, #area_name_def
    ctlCreate #(6*8), #(29*16), #(32*8), #16, #area_name_callback
	sta area_name_id

	ctlCreate #(40*8), #(29*16), #(6*8), #16, #area_load_callback
    ctlCreate #(48*8), #(29*16), #(6*8), #16, #area_save_callback

	jsr area_enable

	metaLoadScreen VRAM_textmap, #area_background_fn
	rts
	.endproc

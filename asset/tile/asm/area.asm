;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_AREA_ASM_:
.include "../inc/main.inc"

.export area_
.export area_win_id
.export area_base_sze
.export area_base_def
.export area_cur_color
.export area_back_color
.export area_edit_toggle
.export area_cur_tile
.export area_clipboard
.export area_base
.export area_wide
.export area_high
.export area_raw_x
.export area_raw_y
.export area_index
.export area_tile_x
.export area_tile_y
.export area_row
.export area_col
.export area_loaded


.export area_cur_format
.export area_cur_map
.export area_format_8_8
.export area_format_8_16
.export area_format_16_8
.export area_format_16_16
.export area_map_8_8
.export area_map_8_16
.export area_map_16_8
.export area_map_16_16

.segment "DATA"

area_:
area_win_id:		.byte 0
area_base_id:		.byte 0
area_base_sze:		.res 9 ; 4 chars (char + color) max plus 4 byte overhead
area_cur_color:		.byte 0 ;def: 1
area_back_color:	.byte 0
area_base:			.word 0
area_wide:			.byte 0
area_high:			.byte 0
area_edit_toggle:	.byte 0
area_cur_tile:		.word 0
area_clipboard:		.word 0
area_raw_x:			.byte 0
area_raw_y:			.byte 0
area_index:			.word 0
area_tile_x:		.byte 0
area_tile_y:		.byte 0
area_row:			.byte 0
area_col:			.byte 0	
area_loaded:		.byte 0

area_cur_format:	.word 0 ;def: #area_format_8_8
area_cur_map:		.word 0 ;def; #area_map_8_8

.segment "CODE"

area_background_fn:   .byte "tile.scr",0
area_base_def:		.byte "0000",0
area_str_base:		.byte "Base",0
area_str_tile:		.byte "Tile index:     X:    Y:   ",0

; Format is a map of the border sprites in linear order across and down
; the window based on the size and orientation of the tiles.
area_format_8_8:
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

area_format_8_16:
	.byte $05,$05,$05,$05,$05,$05,$05,$05,$25,$25,$25,$25,$25,$25,$25,$25
	.byte $05,$05,$05,$05,$05,$05,$05,$05,$25,$25,$25,$25,$25,$25,$25,$25
	.byte $05,$05,$05,$05,$05,$05,$05,$05,$25,$25,$25,$25,$25,$25,$25,$25

area_format_16_8:
	.byte $06,$16,$06,$16,$06,$16,$06,$16,$06,$16,$06,$16,$06,$16,$06,$16
	.byte $06,$16,$06,$16,$06,$16,$06,$16,$06,$16,$06,$16,$06,$16,$06,$16
	.byte $06,$16,$06,$16,$06,$16,$06,$16,$06,$16,$06,$16,$06,$16,$06,$16

area_format_16_16:
	.byte $04,$14,$04,$14,$04,$14,$04,$14,$24,$34,$24,$34,$24,$34,$24,$34
	.byte $04,$14,$04,$14,$04,$14,$04,$14,$24,$34,$24,$34,$24,$34,$24,$34
	.byte $04,$14,$04,$14,$04,$14,$04,$14,$24,$34,$24,$34,$24,$34,$24,$34

; Map is an index into the format for an individual tile. The indexes in
; the map reference the border sprites and their location for an
; individual tile. Map_8_8 is a unity reference to format_8_8, the others
; are not so simple, and need to be mathematically scaled to point to the 
; index list. For example, the 8_16 map is 8 pixels wide and 16 pixels high.
; so the index of the tile is multiplied by two, then the two bytes are    
; referenced at that location in the map. The first is the top border and
; the next is the bottom border of the tile.
area_map_8_8:
	.byte 00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15
	.byte 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	.byte 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47

area_map_8_16:
	.byte 00,08,01,09,02,10,03,11,04,12,05,13,06,14,07,15
	.byte 16,24,17,25,18,26,19,27,20,28,21,29,22,30,23,31
	.byte 32,40,33,41,34,42,35,43,36,44,37,45,38,46,39,47

area_map_16_8:
	.byte 00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15
	.byte 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	.byte 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47

area_map_16_16:
	.byte 00,01,08,09,02,03,10,11,04,05,12,13,06,07,14,15
	.byte 16,17,24,25,18,19,26,27,20,21,28,29,22,23,30,31
	.byte 32,33,40,41,34,35,42,43,36,37,44,45,38,39,46,47



area_format_offset:	.word 0
area_border_x:		.word 0
area_border_y:		.word 0


;export area_set_raw_from_tile
;.export area_init_borders
;.export area_init_border_map
;.export area_init

.export area_win_callback 
.proc area_win_callback
	if_case_else #CTL_STATE_NORMAL
		jsr area_win_over
		rts

:	if_case_else #CTL_STATE_OVER
		jsr area_win_over
		rts

:	if_case_else #CTL_STATE_PRESSED
		jsr area_win_pressed
		rts

:	; Default:
		rts
	.endproc


.export area_get_tile_wx 
.proc area_get_tile_wx
	lda area_raw_x
	sta area_tile_x
	stz area_col
	@loop_x:
		sec
		inc area_col
		sbc data_width
		bmi @done_x
		sta area_tile_x
		bra @loop_x

	@done_x:
	clc
	dec area_col
	adc data_width
	sta area_tile_x
	rts
	.endproc


.export area_get_tile_hy 
.proc area_get_tile_hy
	lda area_raw_y
	sta area_tile_y
	stz area_row
	@loop_y:
		sec
		inc area_row
		sbc data_height
		bmi @done_y
		sta area_tile_y
		bra @loop_y

	@done_y:
	clc
	dec area_row
	adc data_height
	sta area_tile_y
	rts
	.endproc


.export area_get_col_by_index 
.proc area_get_col_by_index
	rts
	.endproc


.export area_set_wide 
.proc area_set_wide
	lda data_width
	if_case_else #8
		lda #8	; Number of tiles wide when width = 8.
		sta area_wide
		rts

	:if_case_else #16
		lda #4	; Number of tiles high when height = 16.
		sta area_wide
	:	rts
	.endproc


.export area_set_high 
.proc area_set_high
	lda data_height
	if_case_else #8
		lda #8	; Number of tiles high when height = 8.
		sta area_high
		rts

	:if_case_else #16
		lda #3	; Number of tiles high when height = 16.
		sta area_high
	:	rts
	.endproc


.export area_get_tile_ixy 
.proc area_get_tile_ixy
	; Based on raw_x and width, get area_row and tile_x 
	jsr area_get_tile_wx

	; Based on raw_y and height, get area_col and tile_y 
	jsr area_get_tile_hy

	@multiply:
	mathMultiply_8_8 area_wide, area_row, area_index

	clc
	lda area_col
	adc area_index
	sta area_index
	
	math_ADD_16_16 area_base, area_index
	rts
	.endproc


.export area_get_raw_ixy 
.proc area_get_raw_ixy
	bra @start

		@x:		.word 0
		@y:		.word 0
	@start:	
	memSet_16_16 mouse_x, @x
	math_SUB_IMM_16 104, @x
	mathShiftDown_16 #3, @x
	lda @x
	sta area_raw_x

	memSet_16_16 mouse_y, @y
	math_SUB_IMM_16 64, @y
	mathShiftDown_16 #3, @y
	lda @y
	sta area_raw_y
	rts
	.endproc


; TODO This is stupid... use a real division routine.
.export divide_A_X 
.proc divide_A_X
	bra @start

		@dividend:	.byte 0
		@divisor:	.byte 0
		@result:	.byte 0
	@start:
	sta @dividend
	stx @divisor
	stz @result

	@loop:
		sec
		inc @result
		sbc @divisor
		bmi @done
		sta @dividend
		bra @loop

	@done:
	clc
	dec @result
	adc @divisor
	tax ; Remainder
	lda @result 
	rts
	.endproc


.export area_set_raw_from_tile 
.proc area_set_raw_from_tile
	lda area_index
	ldx area_wide
	jsr divide_A_X
	txa
	mathShiftUp_A data_shift_width
	clc
	adc area_tile_x
	sta area_raw_x

	lda area_index
	ldx area_wide
	jsr divide_A_X
;	txa
	mathShiftUp_A data_shift_height
	clc
	adc area_tile_y
	sta area_raw_y
	rts
	.endproc


.export area_show_frame_ixy 
.proc area_show_frame_ixy
	jsr area_get_raw_ixy
	jsr area_get_tile_ixy

	textString #34, #3 ,#area_str_tile ,#$91

	mathBinToBcd_16 area_index
	textBcd_16 #45, #3, #4, #$95

	mathBinToBcd_8 area_tile_x
	textBcd_8 #52, #3, #2, #$95

	mathBinToBcd_8 area_tile_y
	textBcd_8 #58, #3, #2, #$95
	rts
	.endproc


.export area_win_over 
.proc area_win_over
	jsr area_show_frame_ixy

	lda area_edit_toggle
	beq @return

	;Need to reset the old one first.
	lda area_cur_tile+1
	bmi :+
	lda #1
	jsr area_set_cur_tile

: 	memSet_16_16 area_index, area_cur_tile  
	stz area_edit_toggle
	lda #0
	jsr area_set_cur_tile

	@return:
	rts
	.endproc


.export area_win_set_color
.proc area_win_set_color
	lda mouse_btns
	if_case_else #CTL_MOUSE_LEFT
		; TODO Set actual pixel index into A
		lda area_cur_color
		jsr palette_edit_16
		jsr edit_set_pixel
		lda area_cur_color
		jsr palette_save_16
		jsr data_save_pixel
		rts

:	if_case_else #CTL_MOUSE_RIGHT
		; TODO Set actual pixel index into A
		lda #0;area_back_color
		jsr palette_edit_0
		jsr edit_set_pixel
		lda area_back_color
		jsr data_save_pixel
	rts
	.endproc


.export area_win_pressed 
.proc area_win_pressed
	jsr area_show_frame_ixy
	
	; Check to see if this is the current frame
	if_16_eq_16 area_cur_tile, area_index
		jsr area_win_set_color
		rts
	:

	inc area_edit_toggle
	rts
	.endproc


.export area_set_cur_tile
.proc area_set_cur_tile
	bra @start

		@pal_index:		.byte 0
		@tile_index:	.word 0
		@map_index:		.byte 0
		@sprite_index:	.byte 0
	@start:
	sta @pal_index

	lda area_cur_tile+1
	bmi @return

	memSet_16_16 area_cur_tile, @tile_index
	math_SUB_16_16 area_base, @tile_index

	; Shift left by 0,1,2 based on which format
	mathShiftUp_8 data_shift_tiles, @tile_index

	; @tile_index LSB contains the 0-47 index of the current tile.
	ldy @tile_index
	memSet_16_16 area_cur_map, zp_ind 
	ldx data_num_borders
	@loop:
		lda (zp_ind),y
		sta @map_index
		lda @map_index
		clc
		adc #8
		sta @sprite_index
		sprite_set_palette @sprite_index, #2, @pal_index	
		iny
		dex
		bne @loop

	@return:
	rts
	.endproc


.export area_reset_cur_tile
.proc area_reset_cur_tile
	lda area_cur_tile+1
	bmi @return

	lda #1
	jsr area_set_cur_tile

	stz area_cur_tile
	lda #$80
	sta area_cur_tile+1

	@return:
	rts
	.endproc	


.export area_page_up 
.proc area_page_up
	jsr area_reset_cur_tile

	; If the base is already 0, do nothing.
	if_16_eq_IMM area_base, 0 
		rts
	:
	math_SUB_8_16 data_num_tiles, area_base

	lda area_base+1
	bpl @up_more
	; If negative, zero area_base. 
	stz area_base
	stz area_base+1

	@up_more:

	mathBinToBcd_16 area_base
	szEditSetBcd_16 #area_base_sze, #4
	textStringEdit #area_base_sze ,#$b1

	jsr data_load_tiles 
	rts
	.endproc


.export area_page_down_more 
.proc area_page_down_more
	math_ADD_8_16 data_num_tiles, area_base

	mathBinToBcd_16 area_base
	szEditSetBcd_16 #area_base_sze, #4
	textStringEdit #area_base_sze ,#$b1

	jsr data_load_tiles 
	rts
	.endproc


.export area_page_down_limit 
.proc area_page_down_limit
	memSet_16_16 data_num_frames, area_base 
	math_SUB_8_16 data_num_tiles, area_base

	mathBinToBcd_16 area_base
	szEditSetBcd_16 #area_base_sze, #4
	textStringEdit #area_base_sze ,#$b1

	jsr data_load_tiles 
	rts
	.endproc


.export area_page_down 
.proc area_page_down
	bra @start

		@new_base: .word 0
	@start:
	jsr area_reset_cur_tile

	; If tiles > frames, do nothing.
	if_8_gt_16 data_num_tiles, data_num_frames  
		rts
	:

	; If tiles = frames, do nothing.
	if_8_eq_16 data_num_tiles, data_num_frames  
		rts
	:

	; Set area_base to next position
	memSet_16_16 area_base, @new_base
	math_ADD_8_16 data_num_tiles, @new_base

	; if base + (num_tiles+2) < num_frames, show next
	if_16_lt_16 @new_base, data_num_frames
		
		jsr area_page_down_more
		rts
	:
	memSet_16_16 area_base, @new_base
	math_ADD_8_16 data_num_tiles, @new_base

	; if base + num_tiles > num_frames, show limit
	if_16_gt_16 @new_base, data_num_frames
		jsr area_page_down_limit
	:
	rts
	.endproc


.export area_base_key_enter 
.proc area_base_key_enter
	jsr	area_reset_cur_tile

	szEditGetAddr #area_base_sze, zp_ind
	szConvToBcd_16 zp_ind
	mathBcd16ToBin_16 area_base

	jsr data_load_tiles 
	rts
	.endproc


.export area_base_mouse_release 
.proc area_base_mouse_release
	ctlEditBegin #area_base_sze
	rts
	.endproc


.export area_base_callback 
.proc area_base_callback
	if_case_else #CTL_STATE_OVER
		textStringEdit #area_base_sze ,#$b7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textStringEdit #area_base_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_NORMAL
		textStringEdit #area_base_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr area_base_mouse_release
		rts

:	if_case_else #CTL_KEY_INPUT
		lda ctl_focus
		cmp area_base_id
		bne :+
		jsr ctl_edit_process
		rts

:	if_case_else #CTL_KEY_ENTER
		jsr area_base_key_enter
:		rts
	.endproc


.export area_background 
.proc area_background
	memSet_IMM_24 VRAM_textmap, ZP24_R0
	inc ZP24_R0+1
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr 0, Stride 1	
	fileLoad #area_background_fn, #vera_data0, #0, #$80
	rts
	.endproc


.export area_init_border_clear 
.proc area_init_border_clear
	memSet_IMM_24 VRAM_borders, ZP24_R0
	math_ADD_16_24 area_format_offset, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 64

	ldy #8	; 8 loops of 256 = 2K total.
	ldx #0
	@page_loop:
		@byte_loop:
			lda #$00
			sta vera_data0
			inx
			bne @byte_loop
		dey
		bne @page_loop	
	rts
	.endproc


.export area_init_border_top 
.proc area_init_border_top
	memSet_IMM_24 VRAM_borders, ZP24_R0
	math_ADD_16_24 area_format_offset, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	ldx #32
	@top_byte_loop:
		lda #$77
		sta vera_data0
		dex
		bne @top_byte_loop
	rts
	.endproc


.export area_init_border_bot 
.proc area_init_border_bot
	memSet_IMM_24 VRAM_borders, ZP24_R0
	math_ADD_16_24 area_format_offset, ZP24_R0
	math_ADD_IMM_24 2016, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	ldx #32
	@bot_byte_loop:
		lda #$77
		sta vera_data0
		dex
		bne @bot_byte_loop
	rts
	.endproc


.export area_init_border_left
.proc area_init_border_left
	memSet_IMM_24 VRAM_borders, ZP24_R0
	math_ADD_16_24 area_format_offset, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $60	; Addr0, stride 64
	ldx #64
	@left_byte_loop:
		lda #$70
		sta vera_data0
		dex
		bne @left_byte_loop
	rts
	.endproc


.export area_init_border_right 
.proc area_init_border_right
	memSet_IMM_24 VRAM_borders, ZP24_R0
	math_ADD_16_24 area_format_offset, ZP24_R0
	math_ADD_IMM_24 31, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $60	; Addr0, stride 64
	ldx #64
	@right_byte_loop:
		lda #$07
		sta vera_data0
		dex
		bne @right_byte_loop
	rts
	.endproc


.export area_init_borders 
.proc area_init_borders
	bra @start

		@index:	.byte 0
	@start:
	stz area_format_offset
	stz area_format_offset+1

	stz @index
	@loop:
		; Blank all 8 possible sprites first.
		jsr area_init_border_clear

		lda @index
		if_case_else #1
			jsr area_init_border_left
			jsr area_init_border_right
			jsr area_init_border_top
			jsr area_init_border_bot
			bra @end_case

:		if_case_else #2
			jsr area_init_border_top
			bra @end_case

:		if_case_else #3
			jsr area_init_border_left
			bra @end_case

:		if_case_else #4
			jsr area_init_border_left
			jsr area_init_border_top
			bra @end_case

:		if_case_else #5
			jsr area_init_border_left
			jsr area_init_border_right
			jsr area_init_border_top
			bra @end_case

:		if_case_else #6
			jsr area_init_border_left
			jsr area_init_border_top
			jsr area_init_border_bot
@end_case:
:		math_ADD_IMM_24 2048, area_format_offset
		inc @index
		lda @index
		cmp #8
		bne @loop

	rts
	.endproc


.export area_init_border_map_offset 
.proc area_init_border_map_offset
	bra @start

		@x:			.word 0
		@y:			.word 0
		@format:	.word 0
		@offset:	.word 0
	@start:
	phy
	memSet_16_16 area_cur_format, zp_ind

	memSet_16_16 area_border_x, @x
	math_SUB_IMM_16 104, @x
	mathShiftDown_16 #6, @x

	memSet_16_16 area_border_y, @y
	math_SUB_IMM_16 64, @y
	mathShiftDown_16 #6, @y

	mathShiftUp_8 #3, @y
	clc
	lda @y
	adc @x
	tay
	lda (zp_ind),y
	sta @format

	and #$0f ; Strip off flips
	sta @offset
	stz @offset+1
	mathShiftUp_16 #11, @offset

	lda @format
	mathShiftDown_8 #4, @format

	memSet_IMM_24 VRAM_borders, ZP24_R1	; Sprite 1
	math_ADD_16_24 @offset, ZP24_R1
	lda @format
	ply
	rts
	.endproc


.export area_init_border_sprites 
.proc area_init_border_sprites
	bra @start

		@index:	.byte 0
		@max:	.byte 0
	@start:
	lda #8
	sta @index
	lda #48
	sta @max
	@init_loop:
		sprite_init @index, #0, #3, #3, #1	; Border 0
		inc @index
		dec @max
		bne @init_loop
	rts
	.endproc


.export area_init_border_map 
.proc area_init_border_map
	bra @start

		@index:	.byte 0
		@flip:	.byte 0
	@start:
	lda #8
	sta @index
	ldy #6
	mem_SET_IMM_16 64, area_border_y
	@set_loop_y:
		ldx #8
		mem_SET_IMM_16 104, area_border_x
		@set_loop_x:
			jsr area_init_border_map_offset
			sta @flip
			sprite_set @index, #2, area_border_x, area_border_y
			sprite_flip @index, @flip
			inc @index
			math_ADD_IMM_16 64, area_border_x
			dex
			bne @set_loop_x

		math_ADD_IMM_16 64, area_border_y
		dey
		bne @set_loop_y 
		rts
	.endproc


.export area_data_init 
.proc area_data_init
	lda #1
	sta area_cur_color
	memSet_16_16 #area_format_8_8, area_cur_format 
	memSet_16_16 #area_map_8_8, area_cur_map 

	szEditInit #area_base_sze, #4, #4, #29, #3, #area_base_def
	rts
	.endproc	


.export area_init 
.proc area_init
 	jsr area_background
	jsr area_init_border_sprites
	jsr area_init_borders

	ctlCreate #(29*8), #(3*16), #(4*8), #16, #area_base_callback
	sta area_base_id

	ctlCreate #104, #64, #512, #384, #area_win_callback
	sta area_win_id
    rts
    .endproc
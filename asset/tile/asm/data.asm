;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_DATA_ASM_:
.include "../inc/main.inc"

.export data_
.export data_bpp
.export data_width
.export data_height
.export data_num_frames
.export data_tile_size

.export data_num_tiles
.export data_shift_tiles
.export data_num_borders

.export data_shift_width
.export data_shift_height
.export data_load_offset

;.export data_index
;.export data_tile_x
;.export data_tile_y

.segment "DATA"

data_:
; File header data:
data_preamble:		.word 00 ;def; 01 ; Identifying preamble 
; Base data, must be within the range specifies.
data_bpp:			.byte 0 ;def; 4; 1,2,4,8
data_width:			.byte 0 ;def; 8 ; 8,16
data_height:		.byte 0 ;def; 8 ; 8,16
data_num_frames:	.word 0 ;def; 1 ; 1 to 1024
data_extra:			.res 9 ; Pad out to 16 bytes.

; Derived data produced from the base data when it changes.
data_index:			.word 0
data_shift_bpp:		.byte 0 ; Shift ammount to correct tile size for bpp.
data_shift_width:	.byte 0 ; Shift ammount to correct tile size for width.
data_shift_height:	.byte 0 ; Shift ammount to correct tile size for height.
data_num_tiles:		.byte 0 ; Number of tiles displayed (12, 24, or 48)
data_shift_tiles:	.byte 0 ; Shift amount for area_cur_tile
data_num_borders:	.byte 0 ; Number of border sprites in one tile.
data_tile_size:		.word 0 ; Size of tile in bytes
data_tile_addr:		.word 0 ; Address of tile currently being used.
data_filesize:		.res 3 ; Size of tile data loaded into VRAM.
data_pixel_shift:	.byte 0 ; Pixel shift used bor multi-pixel byte mods.
data_load_offset:	.word 0 ; Vera offset for loading tile.

;UI data
data_name_id:		.byte 0
data_name_sze:		.res 37 ; 32 chars (char + color) max plus 4 byte overhead
data_name_def:		.byte 0
data_frames_id:		.byte 0
data_frames_sze:	.res 9 ; 4 chars (char + color) max plus 4 byte overhead

.segment "CODE"

data_frames_def:	.byte "0001",0
;data_str_name:		.res 33
;data_str_name_len:	.byte 0
data_str_file:		.byte "File:",0
data_str_load:		.byte " Load ",0
data_str_save:		.byte " Save ",0

data_str_bpp:		.byte "  Bpp   ",0
data_str_width:		.byte " Width  ",0
data_str_height:	.byte " Height ",0
data_str_frames:	.byte " Frames ",0
;data_str_reset:		.byte " Reset ",0


.export data_name_mouse_left 
.proc data_name_mouse_left
	ctlEditBegin #data_name_sze
;	stz mouse_btns
	rts
	.endproc


.export data_name_callback 
.proc data_name_callback
	if_case_else #CTL_STATE_OVER
		textStringEdit #data_name_sze ,#$b7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textStringEdit #data_name_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_NORMAL
		textStringEdit #data_name_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr data_name_mouse_left
		rts

:	if_case_else #CTL_KEY_INPUT
		lda ctl_focus
		cmp data_name_id
		bne :+
		jsr ctl_edit_process
:		rts
	.endproc


.export data_load_file 
.proc data_load_file
	@filename		= zp_ind

	bra @start
		@context:	.byte 0
	@start:
	; Get the file name from the editor.
	szEditGetAddr #data_name_sze, @filename	
	szLength @filename
	beq @return

	fileOpen @filename
	sta @context
	bcc @error

	; Read data header from file to memory.
	memSet_16_16 #$0010, fat32_size
	fileRead #data_preamble, #$00
	bcc @error

	; Read tile data from file to VRAM
	memSet_IMM_24 VRAM_areadata, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	jsr file_get_remaining
	fileRead #vera_data0, #$80
	bcc @error

	@error:
	; Close the file and free the context.
	lda @context
	jsr file_close

	@return:
	rts
	.endproc


.export data_load_mouse_left 
.proc data_load_mouse_left
	stz mouse_btns

	jsr data_load_file

	mathBinToBcd_8 data_bpp
	textBcd_8 #7, #16, #1, #$95
	mathBinToBcd_8 data_width
	textBcd_8 #6, #19, #2, #$95
	mathBinToBcd_8 data_height
	textBcd_8 #6, #22, #2, #$95

	mathBinToBcd_16 data_num_frames
	szEditSetBcd_16 #data_frames_sze, #4
	textStringEdit #data_frames_sze ,#$b1

	jsr data_reset

	jsr palette_draw
	jsr data_load_tiles
	lda #1
	sta area_loaded

	@return:
	rts
	.endproc


.export data_load_callback 
.proc data_load_callback
	if_case_else #CTL_STATE_OVER
		textString #40, #29 ,#data_str_load ,#$c7
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #40, #29 ,#data_str_load ,#$c1
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #40, #29 ,#data_str_load ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr data_load_mouse_left
:		rts
	.endproc


.export data_save_file 
.proc data_save_file
	@filename		= zp_ind

	bra @start
		@context:	.byte 0
	@start:
	; Get the file name from the editor.
	szEditGetAddr #data_name_sze, @filename	
	szLength @filename
	beq @return

	fileCreate @filename
	sta @context
	bcc @error

	; Read data header from file to memory.
	memSet_16_16 #$0010, fat32_size
	fileWrite #data_preamble, #$00
	bcc @error

	; Read tile data from file to VRAM
	memSet_IMM_24 VRAM_areadata, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	memSet_16_16 data_filesize, fat32_size
	fileWrite #vera_data0, #$80
	bcc @error

	@error:
	; Close the file and free the context.
	lda @context
	jsr file_close

	@return:
	rts
	.endproc


.export data_save_mouse_left 
.proc data_save_mouse_left
	stz mouse_btns

	jsr	area_reset_cur_tile

	jsr data_save_file
	
	@return:
	rts
	.endproc


.export data_save_callback 
.proc data_save_callback
	if_case_else #CTL_STATE_OVER
		textString #48, #29 ,#data_str_save ,#$c7
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #48, #29 ,#data_str_save ,#$c1
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #48, #29 ,#data_str_save ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr data_save_mouse_left
:		rts
	.endproc


.export data_bpp_mouse 
.proc data_bpp_mouse
	lda data_bpp
	if_case_else #1
		lda #2
		bra @end_case

:	if_case_else #2
		lda #4
		bra @end_case

:	if_case_else #4
		lda #8
		bra @end_case

:	if_case_else #8
		lda #1
		bra @end_case

	@end_case:
		sta data_bpp
:		mathBinToBcd_8 data_bpp
		textBcd_8 #7, #16, #1, #$95
		jsr data_reset
		rts
	.endproc


.export data_bpp_callback
.proc data_bpp_callback
	if_case_else #CTL_STATE_OVER
		textString #3, #15 ,#data_str_bpp ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #3, #15 ,#data_str_bpp ,#$b7
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #3, #15 ,#data_str_bpp ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
;		textString #3, #15 ,#data_str_bpp ,#$c1
		jsr data_bpp_mouse
		jsr palette_set_step
		jsr palette_draw
:		rts
	.endproc


.export data_width_mouse 
.proc data_width_mouse
	lda data_width
	if_case_else #8
		lda #16
		bra @end_case

:	if_case_else #16
		lda #8
		bra @end_case

	@end_case:
		sta data_width
:		mathBinToBcd_8 data_width
		textBcd_8 #6, #19, #2, #$95
		jsr data_reset
		rts
	.endproc


.export data_width_callback 
.proc data_width_callback
	if_case_else #CTL_STATE_OVER
		textString #3, #18 ,#data_str_width ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #3, #18 ,#data_str_width ,#$b7
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #3, #18 ,#data_str_width ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
;		textString #3, #18 ,data_str_width ,#$c1
		jsr data_width_mouse
:		rts
	.endproc


.export data_height_mouse 
.proc data_height_mouse
	lda data_height
	if_case_else #8
		lda #16
		bra @end_case

:	if_case_else #16
		lda #8
		bra @end_case

	@end_case:
		sta data_height
:		mathBinToBcd_8 data_height
		textBcd_8 #6, #22, #2, #$95
		jsr data_reset
		rts
	.endproc


.export data_height_callback 
.proc data_height_callback
	if_case_else #CTL_STATE_OVER
		textString #3, #21 ,#data_str_height ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #3, #21 ,#data_str_height ,#$b7
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #3, #21 ,#data_str_height ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
;		textString #3, #21 ,data_str_height ,#$c1
		jsr data_height_mouse
:		rts
	.endproc


.export data_frames_key_enter 
.proc data_frames_key_enter

	szEditGetAddr #data_frames_sze, zp_ind
	szConvToBcd_16 zp_ind
	mathBcd16ToBin_16 data_num_frames
	jsr data_reset
	rts
	.endproc


.export data_frames_mouse_release 
.proc data_frames_mouse_release
	ctlEditBegin #data_frames_sze
	rts
	.endproc


.export data_frames_callback 
.proc data_frames_callback
	if_case_else #CTL_STATE_OVER
		textStringEdit #data_frames_sze ,#$b7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textStringEdit #data_frames_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_NORMAL
		textStringEdit #data_frames_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr data_frames_mouse_release
		rts

:	if_case_else #CTL_KEY_INPUT
		lda ctl_focus
		cmp data_frames_id
		bne :+
		jsr ctl_edit_process
		rts

:	if_case_else #CTL_KEY_ENTER
		jsr data_frames_key_enter
:		rts
	.endproc


.export data_set_filesize 
.proc data_set_filesize
	mathMultiply_16_16 data_tile_size, data_num_frames, data_filesize 
	rts
	.endproc


.export data_set_tile_size 
.proc data_set_tile_size
	; Compute tile_size
	memSet_8_16 data_width, data_tile_size
	mathShiftUp_16 data_shift_height, data_tile_size

	; Correct tile_size for pixel density.
	mathShiftDown_16 data_shift_bpp, data_tile_size
	rts
	.endproc


.export data_set_shift_bpp 
.proc data_set_shift_bpp
	lda data_bpp
	if_case_else #1
		lda #3
		sta data_shift_bpp
		rts

:	if_case_else #2
		lda #2
		sta data_shift_bpp
		rts

:	if_case_else #4
		lda #1
		sta data_shift_bpp
		rts

:	; Default
		stz data_shift_bpp
	rts		
.endproc


.export data_set_shift_height 
.proc data_set_shift_height
	lda data_height
	if_case_else #8
		lda #3
		sta data_shift_height
		rts

	: ; Default	(16 is the only other height value.)
	lda #4
	sta data_shift_height
	rts
	.endproc


.export data_set_shift_width 
.proc data_set_shift_width
	lda data_width
	if_case_else #8
		lda #3
		sta data_shift_width
		rts

	: ; Default	(16 is the only other height value.)
	lda #4
	sta data_shift_width
	rts
	.endproc


.export data_reset_w8 
.proc data_reset_w8
	lda data_height
	if_case_else #8
		memSet_16_16 #area_format_8_8, area_cur_format
		memSet_16_16 #area_map_8_8, area_cur_map
		jsr area_init_border_map
		lda #48
		sta data_num_tiles
		lda #0
		sta data_shift_tiles
		lda #1
		sta data_num_borders
		rts

:	if_case_else #16
		memSet_16_16 #area_format_8_16, area_cur_format
		memSet_16_16 #area_map_8_16, area_cur_map
		jsr area_init_border_map
		lda #24
		sta data_num_tiles
		lda #1
		sta data_shift_tiles
		lda #2
		sta data_num_borders
:		rts
	.endproc


.export data_reset_w16 
.proc data_reset_w16
	lda data_height
	if_case_else #8
		memSet_16_16 #area_format_16_8, area_cur_format
		memSet_16_16 #area_map_16_8, area_cur_map
		jsr area_init_border_map
		lda #24
		sta data_num_tiles
		lda #1
		sta data_shift_tiles
		lda #2
		sta data_num_borders
		rts

:	if_case_else #16
		memSet_16_16 #area_format_16_16, area_cur_format
		memSet_16_16 #area_map_16_16, area_cur_map
		jsr area_init_border_map
		lda #12
		sta data_num_tiles
		lda #2
		sta data_shift_tiles
		lda #4
		sta data_num_borders
:		rts
	.endproc


.export data_set_format 
.proc data_set_format
	lda data_width
	if_case_else #8
		jsr data_reset_w8
		rts

:	jsr data_reset_w16
	rts
	.endproc


.export data_reset 
.proc data_reset
	;TODO This is forced to be zp_ind2 because szCopy hard codes it.
	@sze_data		= zp_ind2

	; Set the base value
	mathBinToBcd_16 area_base
	szEditSetBcd_16 #area_base_sze, #4
	textStringEdit #area_base_sze ,#$b1

	jsr area_reset_cur_tile

	; Set the format of the edit area by setting the border map.
	jsr data_set_format

	; Determine the bit shift for bpp.
	jsr data_set_shift_bpp

	; Determine the bit shift for width.
	jsr data_set_shift_width

	; Determine the bit shift for height.
	jsr data_set_shift_height

	; Compute tile_size.
	jsr data_set_tile_size

	; Compute filesize (data only, minus header.)
	jsr data_set_filesize

	; Set area's tiles wide
	jsr area_set_wide

	; Set area's tiles high
	jsr area_set_high

	; Set palette's step threshold
	jsr palette_set_step

	sprite_set #2, #0, #0, #0

	rts
	.endproc


.export data_save_pixel_4bpp 
.proc data_save_pixel_4bpp
	bra @start

		@pixel:		.byte 0
	@start:
	sta @pixel

	; Write the pixel.
	lda area_tile_x
	and #$01
	beq @even

	; Odd byte goes in the low nibble.
	lda vera_data0
	and #$f0
	sta vera_data0

	lda @pixel 
	ora vera_data0
	sta vera_data0
	rts

	; Evenbyte goes in the high nibble.
	@even:
	lda vera_data0
	and #$0f
	sta vera_data0

	lda @pixel 
	clc
	asl
	asl
	asl
	asl
	ora vera_data0
	sta vera_data0
	rts
	.endproc


.export data_save_bit_2bpp 
.proc data_save_bit_2bpp
	bra @start

		@mask:		.byte 0
		@pixel:		.byte 0
	@start:
	sta @pixel

	; Make a mask of the bits to change with the change bit as 0.
	lda #$c0 ;01
;	sta @mask
	mathShiftDown_A data_pixel_shift 
;	lda @mask
	eor #$ff
	sta @mask

	; Strip off the change bit from the data.
	and vera_data0
	sta vera_data0

	; Add the pixel into the data at the change bit.
	clc
	lda @pixel
	ror	; Bit 0 into C
	ror
	ror
	mathShiftDown_A data_pixel_shift 

;	math_SHIFT_UP_8 data_pixel_shift, @pixel 
;	lda @pixel
	ora vera_data0
	sta vera_data0
	rts
	.endproc


.export data_save_pixel_2bpp 
.proc data_save_pixel_2bpp
	bra @start

		@mask:		.byte 0
		@pixel:		.byte 0
	@start:
	sta @pixel
	; Byte to modify is in vera_data0.

	; Get the offset into the byte based on tile_x
	lda area_tile_x
	clc
	and #$03	; Strip off the upper 6 bits. (range is 0,1,2,3)
	asl
	sta data_pixel_shift

	lda @pixel
	jsr data_save_bit_2bpp
	rts
	.endproc


.export data_save_bit_1bpp 
.proc data_save_bit_1bpp
	bra @start

		@mask:		.byte 0
		@pixel:		.byte 0
	@start:
	sta @pixel

	; Make a mask of the bits to change with the change bit as 0.
	lda #$80 ;01
;	sta @mask
	mathShiftDown_A data_pixel_shift 
;	lda @mask
	eor #$ff
	sta @mask

	; Strip off the change bit from the data.
	and vera_data0
	sta vera_data0

	; Add the pixel into the data at the change bit.
	clc
	lda @pixel
	ror	; Bit 0 into C
	ror
	mathShiftDown_A data_pixel_shift 

;	math_SHIFT_UP_8 data_pixel_shift, @pixel 
;	lda @pixel
	ora vera_data0
	sta vera_data0
	rts
	.endproc


.export data_save_pixel_1bpp 
.proc data_save_pixel_1bpp
	bra @start

		@mask:		.byte 0
		@pixel:		.byte 0
	@start:
	sta @pixel
	; Byte to modify is in vera_data0.

	; Get the offset into the byte based on tile_x
	lda area_tile_x
	and #$07	; Strip off the upper 5 bits. (range is 0,1,2,3,4,5,6,7)
	sta data_pixel_shift

	lda @pixel
	jsr data_save_bit_1bpp
	rts
	.endproc


.export data_save_vera_byte 
.proc data_save_vera_byte
	bra @start

		@offset:	.word 0
	@start:
	; Get the current tile's vram offset for file data.
	memSet_IMM_24 VRAM_areadata, ZP24_R0
	mathMultiply_16_16 area_index, data_tile_size, zp_result 
	math_ADD_16_16 zp_result, ZP24_R0

	; Compute the offset into the tile based on the width and bpp shifts.
	memSet_8_16 area_tile_y, @offset
	mathShiftUp_16 data_shift_width, @offset
	math_ADD_8_16 area_tile_x, @offset 
	mathShiftDown_16 data_shift_bpp, @offset
	math_ADD_16_24 @offset, ZP24_R0
	rts
	.endproc


.export data_save_pixel 
.proc data_save_pixel
	bra @start

		@pixel:		.byte 0
	@start:
	sta @pixel

	; Set the vera address for the byte to edit.
	jsr data_save_vera_byte
	mem_SET_VRAM_ADDR ZP24_R0, 0, $00	; Addr0, stride 0

	; Write the pixel.
	lda data_bpp
	if_case_else #8
		lda @pixel
		sta vera_data0
		rts

:	if_case_else #4
		lda @pixel
		jsr data_save_pixel_4bpp
		rts

:	if_case_else #2
		lda @pixel
		jsr data_save_pixel_2bpp
		rts

:	if_case_else #1
		lda @pixel
		jsr data_save_pixel_1bpp
:		rts
	.endproc


.export data_load_pixels_4bpp 
.proc data_load_pixels_4bpp
	; A holds the raw vera byte with the pixels.
	bra @start

		@vera_data:	.byte 0
		@pixel:		.byte 0
	@start:
	sta @vera_data

	; Odd pixel first.
	jsr area_set_raw_from_tile
	lda @vera_data
	and #$f0
	clc
	ror
	ror
	ror
	ror
	jsr palette_edit_16
	jsr edit_set_pixel
	inc area_tile_x

	; Even pixel last.
	jsr area_set_raw_from_tile
	lda @vera_data
	and #$0f
	jsr palette_edit_16
	jsr edit_set_pixel
	inc area_tile_x
	rts
	.endproc


.export data_load_pixels_2bpp 
.proc data_load_pixels_2bpp
	; A holds the raw vera byte with the pixels.
	bra @start

		@index:		.byte 0
		@mask:		.byte 0
		@vera_data:	.byte 0
		@pixel:		.byte 0
	@start:
	sta @vera_data
	lda #4
	sta @index
	lda #$c0
	sta @mask
	@loop:
		lda @vera_data
		and @mask
;		beq @zero_pixel
;		lda #1
;		@zero_pixel:

		mathShiftDown_A #6
		sta @pixel
		jsr area_set_raw_from_tile
		inc area_tile_x
		lda @pixel
		jsr palette_edit_16
		jsr edit_set_pixel
		clc
		rol @vera_data
		rol @vera_data
		dec @index
		lda @index
		bne @loop
	rts

	; Dummy out this mode by stepping to the next byte.
;	inc area_tile_x
;	inc area_tile_x
;	inc area_tile_x
;	inc area_tile_x
;	rts
	.endproc


.export data_load_pixels_1bpp 
.proc data_load_pixels_1bpp
	; A holds the raw vera byte with the pixels.
	bra @start

		@index:		.byte 0
		@mask:		.byte 0
		@vera_data:	.byte 0
		@pixel:		.byte 0
	@start:
	sta @vera_data
	lda #8
	sta @index
	lda #$80
	sta @mask
	@loop:
		lda @vera_data
		and @mask
		beq @zero_pixel
		lda #1
		@zero_pixel:
		sta @pixel
		jsr area_set_raw_from_tile
		inc area_tile_x
		lda @pixel
		jsr palette_edit_16
		jsr edit_set_pixel
		clc
		rol @vera_data
		dec @index
		lda @index
		bne @loop
	rts
	.endproc


.export data_load_vera_byte
.proc data_load_vera_byte
	; Get the current tile's vram offset for file data.
	memSet_IMM_24 VRAM_areadata, ZP24_R0

	memSet_16_16 area_index, zp_oper1
	math_ADD_16_16 area_base, zp_oper1
	memSet_16_16 data_tile_size, zp_oper2
	jsr math_mult_16_16 
	math_ADD_16_16 zp_result, ZP24_R0

	; Compute the offset into the tile based on the width and bpp shifts.
	math_ADD_16_24 data_load_offset, ZP24_R0
	rts
	.endproc


.export data_load_pixels 
.proc data_load_pixels
	; Set the vera address for the byte to edit.
	jsr data_load_vera_byte
	mem_SET_VRAM_ADDR ZP24_R0, 0, $00	; Addr0, stride 0

	; Load the vera byte based on pixels in it.
	lda data_bpp ; 1 pixel per byte.
	if_case_else #8
		jsr area_set_raw_from_tile
		lda vera_data0
	;	jsr palette_trans_16
		jsr edit_set_pixel
		inc area_tile_x
		rts

:	if_case_else #4 ; 2 pixels per byte.
		lda vera_data0
		jsr data_load_pixels_4bpp
		rts

:	if_case_else #2 ; 4 pixels per byte.
		lda vera_data0
		jsr data_load_pixels_2bpp
		rts

:	if_case_else #1	; 8 pixels per byte.
		lda vera_data0
		jsr data_load_pixels_1bpp
:		rts
	.endproc


.export data_load_tile
.proc data_load_tile
	stz data_load_offset
	stz data_load_offset+1

	stz area_tile_x
	stz area_tile_y
	@loop_y:
		@loop_x:
			jsr data_load_pixels
			inc data_load_offset
			lda area_tile_x
			cmp data_width
			bne @loop_x

		stz area_tile_x
		inc area_tile_y
		lda area_tile_y
		cmp data_height
		bne @loop_y
		rts
	.endproc


.export data_load_tiles
.proc data_load_tiles
	stz area_index
	stz area_index+1

	@loop:
		; Loop through all the on screen tiles (Up to 48.)
		jsr data_load_tile
		math_INC_16 area_index 
		lda area_index
		cmp data_num_tiles
		bne @loop ; One tile test.

	rts
	.endproc


.export data_delete_tile
.proc data_delete_tile
	bra @start

		@index:		.word 0
	@start:
	memSet_16_16 area_cur_tile, area_index

	memSet_IMM_24 VRAM_areadata, ZP24_R0
	mathMultiply_16_16 area_index, data_tile_size, zp_result 
	math_ADD_16_16 zp_result, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	memSet_16_16 data_tile_size, @index 
	@loop:
		stz vera_data0
		math_DEC_16 @index
		lda @index
		bne @loop
		lda @index+1
		bne @loop

;	math_SUB_16_16 area_base, area_index
;	jsr data_load_tile
	rts
	.endproc


.export data_copy_tile
.proc data_copy_tile
	memSet_16_16 area_cur_tile, area_clipboard
	rts
	.endproc


.export data_paste_tile
.proc data_paste_tile
	bra @start

		@index:		.word 0
	@start:
	; Source tile
	memSet_IMM_24 VRAM_areadata, ZP24_R0
	mathMultiply_16_16 area_clipboard, data_tile_size, zp_result 
	math_ADD_16_16 zp_result, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	; Destination tile.
	memSet_IMM_24 VRAM_areadata, ZP24_R1
	mathMultiply_16_16 area_cur_tile, data_tile_size, zp_result 
	math_ADD_16_16 zp_result, ZP24_R1
	mem_SET_VRAM_ADDR ZP24_R1, 1, $10	; Addr1, stride 1

	memSet_16_16 data_tile_size, @index 
	@loop:
		lda vera_data0
		sta vera_data1
		math_DEC_16 @index
		lda @index
		bne @loop
		lda @index+1
		bne @loop

	memSet_16_16 area_cur_tile, area_index 
	math_SUB_16_16 area_base, area_index
	jsr data_load_tile

	rts
	.endproc


.export data_left_arrow
.proc data_left_arrow
	lda area_cur_tile+1
	bmi @return

	if_16_eq_16 area_cur_tile, area_base
		rts

:	lda #1
	jsr area_set_cur_tile
	math_DEC_16 area_cur_tile
	lda #0
	jsr area_set_cur_tile

	@return:
	rts
	.endproc


.export data_right_arrow
.proc data_right_arrow
	bra @start

		@max_tile:		.word 0
	@start:
	lda area_cur_tile+1
	bmi @return

	memSet_16_16 area_base, @max_tile
	math_ADD_8_16 data_num_tiles, @max_tile
	math_DEC_16 @max_tile
	if_16_eq_16 area_cur_tile, @max_tile
		rts

:	lda #1
	jsr area_set_cur_tile
	math_INC_16 area_cur_tile
	lda #0
	jsr area_set_cur_tile

	@return:
	rts
	.endproc


.export data_up_arrow
.proc data_up_arrow
	bra @start

		@max_tile:		.word 0
	@start:
	lda area_cur_tile+1
	bmi @return

	memSet_16_16 area_base, @max_tile
	math_ADD_8_16 area_wide, @max_tile
	if_16_lt_16 area_cur_tile, @max_tile
		rts

:	lda #1
	jsr area_set_cur_tile
	math_SUB_8_16 area_wide, area_cur_tile
	lda #0
	jsr area_set_cur_tile

	@return:
	rts
	.endproc


.export data_down_arrow
.proc data_down_arrow
	bra @start

		@max_tile:		.word 0
	@start:
	lda area_cur_tile+1
	bmi @return

	memSet_16_16 area_base, @max_tile
	math_ADD_8_16 data_num_tiles, @max_tile
	math_SUB_8_16 area_wide, @max_tile
	if_16_gt_16 area_cur_tile, @max_tile
		rts

:	lda #1
	jsr area_set_cur_tile
	math_ADD_8_16 area_wide, area_cur_tile
	lda #0
	jsr area_set_cur_tile

	@return:
	rts
	.endproc


.export data_init_clear_tiles
.proc data_init_clear_tiles
	memSet_IMM_24 VRAM_areadata, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	ldy #0
	ldx #0
	@loop_y:
		@loop_x:
		stz vera_data0
		dex
		bne @loop_x
	
	dey
	bne @loop_y	
	rts
	.endproc


.export data_data_init
.proc data_data_init
	memSet_16_16 #01, data_preamble
	lda #4
	sta data_bpp
	lda #8
	sta data_width
	lda #8
	sta data_height
	memSet_16_16 #01, data_num_frames

	szEditInit #data_name_sze, #32, #0, #6, #29, #data_name_def
	szEditInit #data_frames_sze, #4, #4, #4, #25, #data_frames_def
	rts
	.endproc


.export data_init
.proc data_init
	textString #0, #29, #data_str_file, #$b5

	ctlCreate #(6*8), #(29*16), #(32*8), #16, #data_name_callback
	sta data_name_id

	ctlCreate #(4*8), #(25*16), #(4*8), #16, #data_frames_callback
	sta data_frames_id

	ctlCreate #(40*8), #(29*16), #(6*8), #16, #data_load_callback
	ctlCreate #(48*8), #(29*16), #(6*8), #16, #data_save_callback

	ctlCreate #(3*8), #(15*16), #64, #16, #data_bpp_callback
	ctlCreate #(3*8), #(18*16), #64, #16, #data_width_callback
	ctlCreate #(3*8), #(21*16), #64, #16, #data_height_callback

	mathBinToBcd_8 data_bpp
	textBcd_8 #7, #16, #1, #$95
	mathBinToBcd_8 data_width
	textBcd_8 #6, #19, #2, #$95
	mathBinToBcd_8 data_height
	textBcd_8 #6, #22, #2, #$95

	jsr data_reset
	rts
	.endproc


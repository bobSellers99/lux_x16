;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_PALETTE_ASM_:
.include "../inc/main.inc"

.export palette_page
.export palette_step
.export palette_page_sze

.segment "DATA"

palette_win_id:			.byte 0
palette_page:			.word 0
palette_step:			.byte 0

palette_page_id:		.byte 0
palette_page_sze:		.res 7

.segment "CODE"

palette_page_def:		.byte "00",0

palette_str_page_up:	.byte " Up ",0
palette_str_page_down:	.byte " Dn ",0


.export palette_page_callback 
.proc palette_page_callback
	if_case_else #CTL_STATE_OVER
		textStringEdit #palette_page_sze ,#$b7
		rts

	if_case_else #CTL_STATE_PRESSED
		textStringEdit #palette_page_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_NORMAL
		textStringEdit #palette_page_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_RELEASE
		ctlEditBegin #palette_page_sze
		rts

:	if_case_else #CTL_KEY_INPUT
		lda ctl_focus
		cmp palette_page_id
		bne :+
		jsr ctl_edit_process
		rts

:	if_case_else #CTL_KEY_ENTER
		szEditGetAddr #palette_page_sze, zp_ind
		szConvToBcd_16 zp_ind
		mathBcdToBin_A
		sta palette_page

		jsr palette_draw
		jsr data_load_tiles
:		rts
	.endproc


.export palette_page_up_release 
.proc palette_page_up_release
		lda palette_page
		beq @return
		
		dec palette_page
		jsr palette_draw
		sprite_set #2, #0, #0, #0

		mathBinToBcd_8 palette_page
		szEditSetBcd_8 #palette_page_sze, #2
		textStringEdit #palette_page_sze, #$95

		lda data_bpp
		cmp #8
		beq @return
		jsr data_load_tiles

		@return:
		rts
	.endproc


.export palette_page_up_callback 
.proc palette_page_up_callback
	if_case_else #CTL_STATE_OVER
		textString #8, #6 ,#palette_str_page_up ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #8, #6 ,#palette_str_page_up ,#$c1
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #8, #6 ,#palette_str_page_up ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr palette_page_up_release
:		rts
	.endproc


.export palette_page_down_release 
.proc palette_page_down_release
		lda palette_page
		cmp #15
		beq @return

		inc palette_page
		jsr palette_draw
		sprite_set #2, #0, #0, #0

		mathBinToBcd_8 palette_page
		szEditSetBcd_8 #palette_page_sze, #2
		textStringEdit #palette_page_sze, #$95

		lda data_bpp
		cmp #8
		beq @return
		jsr data_load_tiles

		@return:
		rts
	.endproc


.export palette_page_down_callback 
.proc palette_page_down_callback
	if_case_else #CTL_STATE_OVER
		textString #8, #13 ,#palette_str_page_down ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #8, #13 ,#palette_str_page_down ,#$c1
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #8, #13 ,#palette_str_page_down ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr palette_page_down_release
:		rts

	.endproc


.export palette_win_over 
.proc palette_win_over
	rts
	.endproc


.export palette_win_get_entry
.proc palette_win_get_entry
	; Outputs selected color in A
	bra @start
		@color:	.byte 0
		@x:     .word 0
		@y:     .word 0
	@start:
	memSet_16_16 mouse_x, @x
	math_SUB_IMM_16 24, @x
	lda @x
	mathShiftDown_A #4
	mathShiftUp_A #3
	sta @x

	memSet_16_16 mouse_y, @y
	math_SUB_IMM_16 96, @y
	lda @y
	mathShiftDown_A #4
	sta @y
	clc
	adc @x
	sta @color

	cmp palette_step
	bmi @return

	; If the new color is out of range, revert back to the old one.
	lda area_cur_color
	rts

	@return:
	memSet_IMM_24 VRAM_mouse, ZP24_R1	; Sprite 8
	math_ADD_IMM_24 1024, ZP24_R1

;	stz @x+1
;	stz @y+1
	mathShiftUp_8 #1, @x
	math_ADD_IMM_16 24, @x
	mathShiftUp_8 #4, @y
	math_ADD_IMM_16 96, @y

	sprite_set #2, #3, @x, @y
	lda @color
	rts
	.endproc


.export palette_win_pressed 
.proc palette_win_pressed

	jsr palette_win_get_entry
	sta area_cur_color

	jsr palette_set_cur
	.endproc


.export palette_win_callback 
.proc palette_win_callback
	if_case_else #CTL_STATE_OVER
		jsr palette_win_over
		rts

:	if_case_else #CTL_STATE_PRESSED
		jsr palette_win_pressed
		rts

:	; Default:
		rts
	.endproc


.export palette_set_cur
.proc palette_set_cur
	bra @start

		@color:		.byte 0
	@start:
	lda area_cur_color
	sta @color
	lda palette_page
	clc
	asl
	asl
	asl
	asl
	ora @color
	sta @color

	memSet_IMM_24 VRAM_tilemap, ZP24_R0
	math_ADD_IMM_24 $806, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	lda @color
	ldx #3
	stx vera_data0 
	sta vera_data0 
	ldx #7
	stx vera_data0 
	sta vera_data0 
	ldx #7
	stx vera_data0 
	sta vera_data0 
	ldx #4
	stx vera_data0 
	sta vera_data0 
	math_ADD_IMM_24 $100, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	lda @color
	ldx #5
	stx vera_data0 
	sta vera_data0 
	ldx #8
	stx vera_data0 
	sta vera_data0 
	ldx #8
	stx vera_data0 
	sta vera_data0 
	ldx #6
	stx vera_data0 
	sta vera_data0 
	rts
	.endproc


.export palette_set_step
.proc palette_set_step
	; Set the step point
	if_8_eq_8 data_bpp, #1
		lda #2
		sta palette_step
		rts

:	if_8_eq_8 data_bpp, #2	
		lda #4
		sta palette_step
		rts

:	if_8_eq_8 data_bpp, #4	
		lda #16
		sta palette_step
		rts

:	if_8_eq_8 data_bpp, #8	
		lda #16
		sta palette_step
:		rts
	.endproc



.export palette_draw_pixel
.proc palette_draw_pixel
	bra @start

		@pixel:			.byte 0
	@start:
	; Inputs pixel color in A
	; Inputs mask code in X
	sta @pixel
	and #$0f	; Mask off palette page.
	cmp palette_step
	bpl @disabled

	stx vera_data0	; Pixel mask. 
	lda @pixel		; Pixel color.
	sta vera_data0
	rts

	@disabled:
	stx vera_data0	; Pixel mask. 
	lda #$0b		; Pixel color.
	sta vera_data0
	rts
	.endproc


.export palette_draw_col
.proc palette_draw_col
	bra @start

		@pixel:     .byte 0
		@offset:	.word 0
	@start:
	sta @pixel

	; Compute the offest and add it to the addr.
	ldy #8
	@loop:
		mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
		ldx #03
		lda @pixel
		jsr palette_draw_pixel

		ldx #04
		lda @pixel
		jsr palette_draw_pixel

		math_ADD_IMM_24 $100, ZP24_R0
		mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

		ldx #05
		lda @pixel
		jsr palette_draw_pixel

		ldx #06
		lda @pixel
		jsr palette_draw_pixel

		inc @pixel

		math_ADD_IMM_24 $100, ZP24_R0
		dey
		beq @return
		jmp @loop
	@return:
	rts
	.endproc


.export palette_draw
.proc palette_draw
	memSet_IMM_24 VRAM_tilemap, ZP24_R0
	math_ADD_IMM_24 $0c06, ZP24_R0
	lda palette_page
	mathShiftUp_A #4
	jsr palette_draw_col

	memSet_IMM_24 VRAM_tilemap, ZP24_R0
	math_ADD_IMM_24 $0c0a, ZP24_R0
	lda palette_page
	mathShiftUp_A #4
	clc
	adc #8
	jsr palette_draw_col
	rts
	.endproc


.export palette_edit_16
.proc palette_edit_16
	; A holds the color to translate.
	bra @start

		@color:		.byte 0
	@start:
	sta @color

	cmp #0
	beq @return

;	lda data_bpp	; Tranlate if in 8 bpp mode.
;	cmp #8
;	beq @translate

;	lda @color
;	rts

;	@translate:
	lda palette_page
	clc
	asl
	asl
	asl
	asl
	ora @color

	@return:
	rts
	.endproc


.export palette_save_16
.proc palette_save_16
	; A holds the color to translate.
	bra @start

		@color:		.byte 0
	@start:
	sta @color
;	rts
;	cmp #0
;	beq @return

	lda data_bpp	; Tranlate if in 8 bpp mode.
	cmp #8
	beq @translate

	lda @color
	rts

	@translate:
	lda palette_page
	clc
	asl
	asl
	asl
	asl
	ora @color

;	@return:
	rts
	.endproc


.export palette_edit_0
.proc palette_edit_0
	; A holds the color to translate.
	; Which will always be zero in this case.
	bra @start

		@color:		.byte 0
	@start:
	lda #0
	rts
	.endproc


.export palette_init
.proc palette_init
	jsr palette_set_cur

	jsr palette_draw

	szEditInit #palette_page_sze, #2, #2, #9, #10, #palette_page_def
	ctlCreate #(9*8), #(10*16), #(2*8), #16, #palette_page_callback
	sta palette_page_id

	ctlCreate #24, #96, #32, #128, #palette_win_callback
	sta palette_win_id

	ctlCreate #(8*8), #(6*16), #(4*8), #16, #palette_page_up_callback
	ctlCreate #(8*8), #(13*16), #(4*8), #16, #palette_page_down_callback
	rts
	.endproc
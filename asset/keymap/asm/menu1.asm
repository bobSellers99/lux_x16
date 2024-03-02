;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_MENU1_ASM_:
.include "../inc/sprite.inc"

.export menu1_
menu1_:
menu1_id:		.byte 0 
menu1a_id:		.byte 0 
menu1b_id:		.byte 0 
menu1c_id:		.byte 0 
menu1d_id:		.byte 0 
menu1e_id:		.byte 0 
menu1:			.byte " Asset ",0
;menu_1_entries:	.byte 4
;menu_1_list:	.word menu_1_1, menu_1_2, menu_1_3, menu_1_4, 0 
menu1a:		.byte " Home    ",0
menu1b:		.byte " Palette ",0
menu1c:		.byte " Keymap  ",0
menu1d:		.byte " Tile    ",0
menu1e:		.byte " Screen  ",0

menu1a_fn:		.byte "/bin/asset/asset",0
menu1b_fn:		.byte "/bin/asset/palette",0
menu1c_fn:		.byte "/bin/asset/keymap",0
menu1d_fn:		.byte "/bin/asset/tile",0
menu1e_fn:		.byte "/bin/asset/screen",0

menu1_block_addr:	.res 3
menu1_block:		.res 90


.export menu1_callback 
.proc menu1_callback
	if_case_else #CTL_STATE_OVER
		textString #1, #0 ,#menu1 ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #1, #0 ,#menu1 ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #1, #0 ,#menu1 ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr menu1_mouse_left
:		rts
	.endproc


.export menu1_mouse_left 
.proc menu1_mouse_left
	lda menu1a_id
	beq @create

	jsr menu1_delete
	rts

	@create:
	jsr menu1_create
	rts
	.endproc


.export	menu1_create
.proc menu1_create
	jsr menu1_block_save

	ctlCreate #(1*8), #(1*16), #72, #16, #menu1a_callback
	sta menu1a_id 

	ctlCreate #(1*8), #(2*16), #72, #16, #menu1b_callback
	sta menu1b_id 

	ctlCreate #(1*8), #(3*16), #72, #16, #menu1c_callback
	sta menu1c_id 

	ctlCreate #(1*8), #(4*16), #72, #16, #menu1d_callback
	sta menu1d_id 

	ctlCreate #(1*8), #(5*16), #72, #16, #menu1e_callback
	sta menu1e_id 
	rts
	.endproc


.export	menu1_delete
.proc menu1_delete
	lda menu1a_id
	jsr ctl_delete
	stz menu1a_id

	lda menu1b_id
	jsr ctl_delete
	stz menu1b_id

	lda menu1c_id
	jsr ctl_delete
	stz menu1c_id

	lda menu1d_id
	jsr ctl_delete
	stz menu1d_id

	lda menu1e_id
	jsr ctl_delete
	stz menu1e_id

	textBlank #1, #1 ,#9 ,#$01
	textBlank #1, #2 ,#9 ,#$01
	textBlank #1, #3 ,#9 ,#$01
	textBlank #1, #4 ,#9 ,#$01
	textBlank #1, #5 ,#9 ,#$01

	jsr menu1_block_recover
	rts
	.endproc


.export menu1a_callback
.proc menu1a_callback
	if_case_else #CTL_STATE_OVER
		textString #1, #1 ,#menu1a ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #1, #1 ,#menu1a ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #1, #1 ,#menu1a ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		memSet_16_16 #menu1a_fn, fat32_ptr
		memSet_16_16 #$0300, fat32_param32
		memSet_8_16 #0, fat32_offset

		lda #2
		sta main_run
:		rts
	.endproc


.export menu1b_callback
.proc menu1b_callback
	if_case_else #CTL_STATE_OVER
		textString #1, #2 ,#menu1b ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #1, #2 ,#menu1b ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #1, #2 ,#menu1b ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		memSet_16_16 #menu1b_fn, fat32_ptr
		memSet_16_16 #$0300, fat32_param32
		memSet_8_16 #0, fat32_offset

		lda #2
		sta main_run
:		rts
	.endproc


.export menu1c_callback
.proc menu1c_callback
	if_case_else #CTL_STATE_PRESSED
		textString #1, #3 ,#menu1c ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #1, #3 ,#menu1c ,#$bc
:		rts
	.endproc


.export menu1d_callback
.proc menu1d_callback
	if_case_else #CTL_STATE_OVER
		textString #1, #4 ,#menu1d ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #1, #4 ,#menu1d ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #1, #4 ,#menu1d ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		memSet_16_16 #menu1d_fn, fat32_ptr
		memSet_16_16 #$0300, fat32_param32
		memSet_8_16 #0, fat32_offset

		lda #2
		sta main_run
:		rts
	.endproc


.export menu1e_callback
.proc menu1e_callback
	if_case_else #CTL_STATE_OVER
		textString #1, #5 ,#menu1e ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #1, #5 ,#menu1e ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #1, #5 ,#menu1e ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		memSet_16_16 #menu1e_fn, fat32_ptr
		memSet_16_16 #$0300, fat32_param32
		memSet_8_16 #0, fat32_offset

		lda #2
		sta main_run
:		rts
	.endproc


.export menu1_save_string
.proc menu1_save_string
	bra @start

		@line:			.byte 0
		@index:			.byte 0
	@start:
	; A holds which line to save.
	; X,Y hold set with point to save from.
	sta @line
	memSet_IMM_24 VRAM_textmap, menu1_block_addr
	txa
	clc
	asl
	adc menu1_block_addr
	sta menu1_block_addr		; Add x component.
	tya
	clc
	adc menu1_block_addr+1
	sta menu1_block_addr+1		; Add y component.
	mem_SET_VRAM_ADDR menu1_block_addr, 0, $10	; Addr0, stride 1

	memSet_16_16 #menu1_block, zp_ind
	stz @index
;	ldy #0
	@loop_index:
		lda @line
		beq @end_loop_index
		clc
		lda @index
		adc #9
		sta @index
		dec @line
		bra @loop_index

	@end_loop_index:
	clc
	lda @index
	asl
	sta @index
	tay
	ldx #9 
	@loop_text:
		lda vera_data0
		sta (zp_ind),y
		iny
		lda vera_data0
		sta (zp_ind),y
		iny
		dex
		bne @loop_text

	rts
	.endproc


.export menu1_block_save
.proc menu1_block_save
	bra @start

		@line:	.byte 0
		@x:		.byte 0
		@y:		.byte 0
	@start:
	stz @line
	lda #1
	sta @x
	sta @y
	@loop:
		lda @line
		ldx @x
		ldy @y
		jsr menu1_save_string
		inc @line
		inc @y
		lda @y
		cmp #6
		bne @loop

	rts
	.endproc


.export menu1_recover_string
.proc menu1_recover_string
	bra @start

		@line:			.byte 0
		@index:			.byte 0
	@start:
	; A holds which line to save.
	; X,Y hold set with point to save from.
	sta @line
	memSet_IMM_24 VRAM_textmap, menu1_block_addr
	txa
	clc
	asl
	adc menu1_block_addr
	sta menu1_block_addr		; Add x component.
	tya
	clc
	adc menu1_block_addr+1
	sta menu1_block_addr+1		; Add y component.
	mem_SET_VRAM_ADDR menu1_block_addr, 0, $10	; Addr0, stride 1

	memSet_16_16 #menu1_block, zp_ind
	stz @index
;	ldy #0
	@loop_index:
		lda @line
		beq @end_loop_index
		clc
		lda @index
		adc #9
		sta @index
		dec @line
		bra @loop_index

	@end_loop_index:
	clc
	lda @index
	asl
	sta @index
	tay
	ldx #9 
	@loop_text:
		lda (zp_ind),y
		sta vera_data0
		iny
		lda (zp_ind),y
		sta vera_data0
		iny
		dex
		bne @loop_text

	rts
	.endproc


.export menu1_block_recover
.proc menu1_block_recover
	bra @start

		@line:	.byte 0
		@x:		.byte 0
		@y:		.byte 0
	@start:
	stz @line
	lda #1
	sta @x
	sta @y
	@loop:
		lda @line
		ldx @x
		ldy @y
		jsr menu1_recover_string
		inc @line
		inc @y
		lda @y
		cmp #6
		bne @loop

	rts
	.endproc


.export menu1_init
.proc menu1_init
	ctlCreate #(1*8), #(0*16), #56, #16, #menu1_callback
	sta menu1_id 
	rts
	.endproc
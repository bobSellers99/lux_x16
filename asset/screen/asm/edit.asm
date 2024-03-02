;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_EDIT_ASM_:
.include "../inc/screen.inc"
.export edit_
edit_:


.export edit_cur_char
.export edit_color
.export edit_cursor_x
.export edit_cursor_y
.export edit_block_x
.export edit_block_y

edit_cur_char:		.byte 0
edit_blink_state:	.byte 0
edit_blink_init:	.byte 0
edit_blink_time:	.byte 0
edit_color:			.byte $91	
edit_cursor_x:		.byte 0	
edit_cursor_y:		.byte 1
edit_block_x:		.byte 0	
edit_block_y:		.byte 1
edit_vram_offset:	.word 0
edit_vram_cursor:	.res 3
edit_vram_block:	.res 3
edit_vram_temp:		.res 3


.export edit_blink_cursor
.proc edit_blink_cursor
	inc edit_blink_time
	lda edit_blink_time
	cmp edit_blink_init
	bpl @switch_state
	
	@done:
	rts

	@switch_state:
	lda edit_blink_state
	jsr edit_display_vram_cursor
	rts
	.endproc


.export edit_set_vram_offset
.proc edit_set_vram_offset
	lda edit_cursor_y
	sta edit_vram_offset+1
	lda edit_cursor_x
	clc
	asl
	sta edit_vram_offset
	rts
	.endproc


.export edit_set_vram_cursor
.proc edit_set_vram_cursor
	jsr edit_set_vram_offset

	lda #CURSOR_ON 
	jsr edit_display_vram_cursor

	; Set into VRAM address.
	memSet_IMM_24 VRAM_textmap, edit_vram_cursor
	math_ADD_16_24 edit_vram_offset, edit_vram_cursor

	mem_SET_VRAM_ADDR edit_vram_cursor, 0, $10 ; Addr0, stride 1
	rts
	.endproc


.export edit_display_vram_cursor
.proc edit_display_vram_cursor
	bra @start

		@pos_x:			.word 0
		@pos_y:			.word 0
	@start:
	sta edit_blink_state

	; Set cursor position.
	lda edit_cursor_x
	sta @pos_x
	stz @pos_x+1
	mathShiftUp_16 #3, @pos_x

	lda edit_cursor_x
	cmp #80
	bne :+
	math_SUB_IMM_16 2, @pos_x

:	lda edit_cursor_y
	sta @pos_y
	stz @pos_y+1
	mathShiftUp_16 #4, @pos_y

	; Set blink state
	stz edit_blink_time
	lda edit_blink_state
	beq @cursor_off

	; After the cursor is displayed, the blink state is set up
	; for the NEXT pass through.
	; Set cursor on.
	memSet_IMM_24 VRAM_mouse, ZP24_R1
	math_ADD_IMM_24 128, ZP24_R1
	sprite_set #1, #3, @pos_x, @pos_y
	stz edit_blink_state
	rts

	; Set cursor off.
	@cursor_off:
	jsr edit_clear_vram_cursor
	rts
	.endproc


.export edit_clear_vram_cursor
.proc edit_clear_vram_cursor
	bra @start

		@pos_x:			.word 0
		@pos_y:			.word 0
	@start:
	; Set cursor.
	memSet_IMM_24 VRAM_mouse, ZP24_R1
	math_ADD_IMM_24 128, ZP24_R1
	sprite_set #1, #0, @pos_x, @pos_y
	lda #1
	sta edit_blink_state
	rts
	.endproc


.export edit_set_vram_block
.proc edit_set_vram_block
	jsr edit_set_vram_offset

	lda #CURSOR_ON 
	jsr edit_display_vram_block

	; Set into VRAM address.
	memSet_IMM_24 VRAM_textmap, edit_vram_block
	math_ADD_16_24 edit_vram_offset, edit_vram_block

	mem_SET_VRAM_ADDR edit_vram_block, 1, $10 ; Addr1, stride 1
	rts
	.endproc


.export edit_display_vram_block
.proc edit_display_vram_block
	bra @start

		@pos_x:			.word 0
		@pos_y:			.word 0
	@start:
	; Set cursor position.
	lda edit_block_x
	sta @pos_x
	stz @pos_x+1
	mathShiftUp_16 #3, @pos_x
	math_ADD_IMM_16 6, @pos_x
	lda edit_block_y
	sta @pos_y
	stz @pos_y+1
	mathShiftUp_16 #4, @pos_y

	; Set block on.
	memSet_IMM_24 VRAM_mouse, ZP24_R1
	math_ADD_IMM_24 128, ZP24_R1
	sprite_set #2, #3, @pos_x, @pos_y
	rts
	.endproc


.export edit_clear_vram_block
.proc edit_clear_vram_block
	bra @start

		@pos_x:			.word 0
		@pos_y:			.word 0
	@start:
	; Set block off.
	memSet_IMM_24 VRAM_mouse, ZP24_R1
	math_ADD_IMM_24 128, ZP24_R1
	sprite_set #2, #0, @pos_x, @pos_y
	rts
	.endproc


.export edit_set_vram_temp
.proc edit_set_vram_temp
	bra @start

		@orig_cur_x:	.byte 0
		@new_cur_x:		.byte 0
	@start:
	sta @new_cur_x
	lda edit_cursor_x
	sta @orig_cur_x
	lda @new_cur_x
	sta edit_cursor_x
	jsr edit_set_vram_offset

	; Set into VRAM address plus 3 bytes.
	memSet_IMM_24 VRAM_textmap, edit_vram_temp
	math_ADD_16_24 edit_vram_offset, edit_vram_temp
	math_ADD_IMM_24 3, edit_vram_temp

	mem_SET_VRAM_ADDR edit_vram_temp, 0, $18 ; Addr1, stride 1

	lda @orig_cur_x
	sta edit_cursor_x
	rts
	.endproc


.export edit_consume_right
.proc edit_consume_right
	bra @start

		@index:		.byte 0
		@char:		.byte 0
		@color:		.byte 0
	@start:
	lda edit_cursor_x
	sta @index

	@loop:
		lda @index
		jsr edit_set_vram_temp

		; Get the char/color pair from 2 bytes ahead of the cursor.
		; Note that the vera address is decrementing.
		lda vera_data0
		sta @color
		lda vera_data0
		sta @char

		; Set that pair to the cursor location. 
		lda @color
		sta vera_data0
		lda @char
		sta vera_data0
		beq @done

		inc @index
		bra @loop

	@done:
	rts
	.endproc


.export edit_insert
.proc edit_insert
	lda edit_cursor_x
	cmp #80
	beq @return

	jsr edit_set_vram_cursor
	lda edit_cur_char
	sta vera_data0
	lda edit_color
	sta vera_data0

	inc edit_cursor_x
	lda #CURSOR_ON
	jsr edit_display_vram_cursor

	@return:
	rts
	.endproc


.export edit_delete
.proc edit_delete
	jsr edit_consume_right
	rts
	.endproc


.export edit_backspace
.proc edit_backspace
	jsr area_left_arrow
	jsr edit_consume_right
	rts
	.endproc


.export edit_home
.proc edit_home
	stz edit_cursor_x
	lda #CURSOR_ON
	jsr edit_display_vram_cursor
	rts
	.endproc


.export edit_end
.proc edit_end
	lda #79
	sta edit_cursor_x
	lda #CURSOR_ON
	jsr edit_display_vram_cursor
	rts
	.endproc


.export edit_escape
.proc edit_escape
	jsr edit_clear_vram_cursor
	stz ctl_focus
	rts
	.endproc


.export edit_return
.proc edit_return
	stz edit_cursor_x
	lda edit_cursor_y
	cmp #28
	beq :+
	inc edit_cursor_y 

:	lda #CURSOR_ON
	jsr edit_display_vram_cursor
	rts
	.endproc


.export edit_text_color
.proc edit_text_color
	bra @start

		@temp:	.byte 0
	@start:

	lda edit_color	; back:text
	and #$0f	; Strip back color.
	inc
	and #$0f	; Strip carry if text was 15.
	sta @temp
	lda edit_color
	and #$f0
	ora @temp
	sta edit_color

	jsr edit_set_color 
	rts
	.endproc


.export edit_back_color
.proc edit_back_color
	bra @start

		@temp:	.byte 0
	@start:
	lda edit_color	; back:text
	and #$f0	; Strip text color.
	clc
	adc #$10
	sta @temp
	lda edit_color
	and #$0f
	ora @temp
	sta edit_color

	jsr edit_set_color 
	rts
	.endproc


.export edit_set_color
.proc edit_set_color
	bra @start

		@loc_x1:	.byte 0
		@loc_x2:	.byte 0
		@loc_y:		.byte 0
		@length:	.byte 0
		@height:	.byte 0
		@vram_addr:	.res 3
	@start:
	lda #1	; if block not set, length is one char, the one at the cursor.
	sta @length
	lda edit_block_x
	beq @start_loop
	sec
	sbc edit_cursor_x
	sta @length
	inc @length
	
	@start_loop:
	memSet_24_24 edit_vram_cursor, @vram_addr
	mem_SET_VRAM_ADDR @vram_addr, 0, $10 ; Addr0, stride 1
	@loop:
		lda @length
		beq @line_done
		lda vera_data0 ; Skip character data
		lda edit_color
		sta vera_data0
		dec @length
		bra @loop

	@line_done:
	mem_SET_VRAM_ADDR edit_vram_cursor, 0, $10 ; Addr0, stride 1
	@return:
	rts
	.endproc


.export edit_left_arrow
.proc edit_left_arrow
	lda edit_cursor_x
	beq @return

	dec edit_cursor_x
	jsr edit_set_vram_cursor

	@return:
	rts
	.endproc


.export edit_right_arrow
.proc edit_right_arrow
	lda edit_cursor_x
	cmp #80
	beq @return

	inc edit_cursor_x
	jsr edit_set_vram_cursor

	@return:
	rts
	.endproc


.export edit_up_arrow
.proc edit_up_arrow
	lda edit_cursor_y
	cmp #1
	beq @return

	dec edit_cursor_y
	jsr edit_set_vram_cursor

	@return:
	rts
	.endproc


.export edit_down_arrow
.proc edit_down_arrow
	lda edit_cursor_y
	cmp #28
	beq @return

	inc edit_cursor_y
	jsr edit_set_vram_cursor

	@return:
	rts
	.endproc


.export edit_process
.proc edit_process
	jsr edit_blink_cursor
	lda kyb_ascii
	bne @process
	rts ; Nothing to do. No ascii char pending.

	@process:
	sta edit_cur_char
	stz kyb_ascii
	cmp #$7f
	beq @delete
	cmp #$08
	beq @backspace
	cmp #$84
	beq @home
	cmp #$85
	beq @end
	cmp #$1b
	beq @escape
	cmp #$0d
	beq @return
	cmp #$91 ; F2
	beq @text_color
	cmp #$90 ; F1
	beq @back_color

	cmp #$80
	beq @left_arrow
	cmp #$81
	beq @right_arrow
	cmp #$82
	beq @up_arrow
	cmp #$83
	beq @down_arrow

	; Rule set for allowed characters.
;	cmp #$20	; Don't allow less than space.
;	bmi @exit
;	cmp #$7f	; Allow up the the ~ character.
	bra @insert

;	cmp #$a0	; Don't allow less $a0.
;	bmi @exit
;	cmp #$ff	; Allow up the the $ff.
;	bmi @insert
	rts

	@insert:
	; Choose between insert and overwrite mode here.
	jsr edit_insert			; insert mode
;	jsr ctl_edit_overwrite		; overwrite mode
	@exit:
	rts

	@delete:
	jsr edit_delete
	rts

	@backspace:
	jsr edit_backspace
	rts

	@home:
	jsr edit_home
	rts

	@end:
	jsr edit_end
	rts

	@escape:
	jsr edit_escape
	rts

	@return:
	jsr edit_return
	rts

	@text_color:
	jsr edit_text_color
	rts

	@back_color:
	jsr edit_back_color
	rts

	@left_arrow:
	jsr edit_left_arrow
	rts

	@right_arrow:
	jsr edit_right_arrow
	rts

	@up_arrow:
	jsr edit_up_arrow
	rts

	@down_arrow:
	jsr edit_down_arrow
	rts
	.endproc


.export edit_init
.proc edit_init
	stz edit_blink_state
	lda #30
	sta edit_blink_init
	rts
	.endproc
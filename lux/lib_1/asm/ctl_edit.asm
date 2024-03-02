;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.export _CTL_EDIT_ASM_
_CTL_EDIT_ASM_:

.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/defines.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/math.inc"
.include "../../../lib/inc/sprite.inc"
.include "../../../lib/inc/sz.inc"
.include "../../../lib/inc/text.inc"
.include "../../../lib/inc/ctl.inc"
.include "../../../lib/inc/ctl.edit.inc"

.export ctl_edit_
ctl_edit_:

; TODO This is hokey. Need a way for the default sprite data to get to the library.
VRAM_mouse			= $1f400

ctl_edit_sze:			.word 0 
ctl_edit_blink_init:	.byte 0
ctl_edit_blink_state:	.byte 0
ctl_edit_blink_time:	.byte 0
ctl_edit_cursor_x:		.byte 0
ctl_edit_cursor_y:		.byte 0
ctl_edit_cursor:		.byte 0
ctl_edit_cur_char:		.byte 0


.export ctl_edit_blink_cursor
.proc ctl_edit_blink_cursor
	inc ctl_edit_blink_time
	lda ctl_edit_blink_time
	cmp ctl_edit_blink_init
	bpl @switch_state
	rts

	@switch_state:
	lda ctl_edit_blink_state
	jsr ctl_edit_display_cursor
	rts
	.endproc


.export ctl_edit_display_cursor
.proc ctl_edit_display_cursor
	bra @start
	
		@word_x:		.word 0
		@word_y:		.word 0
	@start:
	sta ctl_edit_blink_state

	; Set cursor position.
	lda ctl_edit_cursor_x
	sta @word_x
	stz @word_x+1
	mathShiftUp_16 #3, @word_x

	lda ctl_edit_cursor_y
	sta @word_y
	stz @word_y+1
	mathShiftUp_16 #4, @word_y

	; Set blink state
	stz ctl_edit_blink_time
	lda ctl_edit_blink_state
	beq @cursor_off

	; After the cursor is displayed, the blink state is set up
	; for the NEXT pass through.
	; Set cursor on.
	memSet_IMM_24 VRAM_mouse, ZP24_R1
	math_ADD_IMM_24 128, ZP24_R1
	sprite_set #1, #3, @word_x, @word_y
	stz ctl_edit_blink_state
	rts

	; Set cursor off.
	@cursor_off:
	memSet_IMM_24 VRAM_mouse, ZP24_R1
	math_ADD_IMM_24 128, ZP24_R1
	sprite_set #1, #0, @word_x, @word_y
	lda #1
	sta ctl_edit_blink_state
	rts
	.endproc


.export ctl_edit_inc_cursor 
.proc ctl_edit_inc_cursor
	szEditGetParam ctl_edit_sze, #SZ_EDIT_MAX
	dec
	cmp ctl_edit_cursor
	beq @return

	szEditGetParam ctl_edit_sze, #SZ_EDIT_LEN
	cmp ctl_edit_cursor
	beq @return

	inc ctl_edit_cursor
	inc ctl_edit_cursor_x
	jsr ctl_edit_display_cursor
	@return:
	rts
	.endproc

.export ctl_edit_dec_cursor 
.proc ctl_edit_dec_cursor
	lda ctl_edit_cursor
	beq @return

	dec ctl_edit_cursor
	dec ctl_edit_cursor_x
	jsr ctl_edit_display_cursor
	@return:
	rts
	.endproc


.export ctl_edit_shift_right 
.proc ctl_edit_shift_right
	@sze_addr		= zp_ind

	bra @start
		@index:		.byte 0
		@stop_at:	.byte 0

	@start:
	szEditGetParam ctl_edit_sze, #SZ_EDIT_LEN
	dec
	sta @index
	szEditGetAddr ctl_edit_sze, @sze_addr

	lda ctl_edit_cursor
	sta @stop_at

	@loop:
	ldy @index
	lda (@sze_addr),y
	iny
	sta (@sze_addr),y
	dey
	cpy @stop_at
	beq @return
	dec @index
	bra @loop

	@return:
	rts
	.endproc


.export ctl_edit_shift_left 
.proc ctl_edit_shift_left
	@sze_addr		= zp_ind

	bra @start
		@index:		.byte 0
		@stop_at:	.byte 0

	@start:
	szEditGetAddr ctl_edit_sze, @sze_addr
	szEditGetParam ctl_edit_sze, #SZ_EDIT_LEN
	sta @stop_at

	lda ctl_edit_cursor
	sta @index

	@loop:
	ldy @index
	iny
	lda (@sze_addr),y
	dey
	sta (@sze_addr),y
	cpy @stop_at
	beq @return
	inc @index
	bra @loop

	@return:
	rts
	.endproc


.export ctl_edit_replace_char 
.proc ctl_edit_replace_char
	@sze_addr		= zp_ind

	; Position the addr to the char byte of the cursor position.
	szEditGetAddr ctl_edit_sze, @sze_addr 
	lda ctl_edit_cur_char
	ldy ctl_edit_cursor
	sta (@sze_addr),y
	
	textStringEdit ctl_edit_sze, #$b1
	rts
	.endproc


.export ctl_edit_insert
.proc ctl_edit_insert
	bra @start
		@maxlen:	.byte 0
		@len:		.byte 0

	@start:
	szEditGetParam ctl_edit_sze, #SZ_EDIT_MAX, @maxlen
	szEditGetParam ctl_edit_sze, #SZ_EDIT_LEN, @len

	; If at max chars, redirect to overwrite mode.
	lda @maxlen
	cmp @len
	bne :+
	jsr ctl_edit_overwrite
	rts

	:	
	; Inc length if it is less than maxlen.
	lda @maxlen
	cmp @len
	beq @continue
	szEditIncParam ctl_edit_sze, #SZ_EDIT_LEN

	@continue:
	jsr ctl_edit_shift_right
	jsr ctl_edit_replace_char
	jsr ctl_edit_inc_cursor

	@return:
	rts
	.endproc


.export ctl_edit_overwrite 
.proc ctl_edit_overwrite
	jsr ctl_edit_replace_char

	; If cursor is not at max, increment the cursor.
	szEditGetParam ctl_edit_sze, #SZ_EDIT_MAX
	cmp ctl_edit_cursor
	beq @return
	jsr ctl_edit_inc_cursor

	@return:
	rts
	.endproc


.export ctl_edit_delete 
.proc ctl_edit_delete
	@sze_addr		= zp_ind
	
	bra @start
		@char_x:	.byte 0
		@char_y:	.byte 0

	@start:
	szEditGetParam ctl_edit_sze, #SZ_EDIT_LEN
	cmp ctl_edit_cursor
	bne :+
	rts

	:
	; Position the addr to the char byte of the cursor position.
	szEditGetAddr ctl_edit_sze, @sze_addr 
	szEditDecParam ctl_edit_sze, #SZ_EDIT_LEN
	jsr ctl_edit_shift_left

	; This is a wierd bird where the char after the editable string needs
	; to be deleted, so we're getting the x,y coords and using regular
	; textString and textBlank to do that.
	szEditGetParam ctl_edit_sze, #SZ_EDIT_X, @char_x
	szEditGetParam ctl_edit_sze, #SZ_EDIT_Y, @char_y
	textString @char_x, @char_y, @sze_addr, #$b1
	; textString returns the number of chars it wrote in A.
	clc
	adc @char_x
	sta @char_x
	textBlank @char_x, @char_y, #1, #$b1
	rts
	.endproc


.export ctl_edit_backspace 
.proc ctl_edit_backspace
	lda ctl_edit_cursor
	beq @return

	jsr ctl_edit_dec_cursor
	jsr ctl_edit_delete

	@return:
	rts
	.endproc


.export ctl_edit_release_editor 
.proc ctl_edit_release_editor
	@sze_addr		= zp_ind

	bra @start
		@char_x:	.byte 0
		@char_y:	.byte 0

	@start:
	lda ctl_focus
	beq @return

	sprite_set #01, #00, $02, $02

	textStringEdit ctl_edit_sze, #$b1

	mem_ZERO_16 ctl_edit_sze
	stz ctl_focus
	stz ctl_edit_cursor

	@return:
	rts
	.endproc


.export ctl_edit_escape 
.proc ctl_edit_escape
	lda #CTL_KEY_ESCAPE
	ctlJumpAbsInd ctl_addr, #ctl::callback, #CTL_KEY_ESCAPE
	jsr ctl_edit_release_editor
	rts
	.endproc


.export ctl_edit_return 
.proc ctl_edit_return
	lda #CTL_KEY_ENTER
	ctlJumpAbsInd ctl_addr, #ctl::callback, #CTL_KEY_ENTER
	jsr ctl_edit_release_editor
	rts
	.endproc


.export ctl_edit_process 
.proc ctl_edit_process
	jsr ctl_edit_blink_cursor

	lda kyb_ascii
	sta ctl_edit_cur_char
	stz kyb_ascii
	cmp #$7f
	beq @delete
	cmp #$08
	beq @backspace
	cmp #$1b
	beq @escape
	cmp #$0d
	beq @return
	cmp #$80
	beq @left_arrow
	cmp #$81
	beq @right_arrow

	cmp #$20	; Allow the chars space to ~
	bmi @exit
	cmp #$7f
	bmi @insert

	rts
	@insert:
	; Choose between insert and overwrite mode here.
	jsr ctl_edit_insert			; insert mode
;	jsr ctl_edit_overwrite		; overwrite mode
	@exit:
	rts

	@delete:
	jsr ctl_edit_delete
	rts

	@backspace:
	jsr ctl_edit_backspace
	rts

	@escape:
	jsr ctl_edit_escape
	rts

	@return:
	jsr ctl_edit_return
	rts

	@left_arrow:
	jsr ctl_edit_dec_cursor
	rts

	@right_arrow:
	jsr ctl_edit_inc_cursor
	rts
	.endproc


.export ctl_edit_init_cursor
.proc ctl_edit_init_cursor
	@sze_addr		= zp_ind

	bra @start
;		@string_data:	.word 0

		@temp_word:		.word 0
		@string_x:		.byte 0
		@new_cursor:	.byte 0

	@start:
	stz ctl_edit_blink_state
	lda #30
	sta ctl_edit_blink_init

	szEditGetAddr ctl_edit_sze, @sze_addr

	memSet_16_16 mouse_x, @temp_word
	mathShiftDown_16 #3, @temp_word

	szEditGetParam ctl_edit_sze, #SZ_EDIT_X, @string_x
	sec
	lda @temp_word
	sbc @string_x	 
	bmi @zero_cursor
	sta @new_cursor
	bra @set_limit

	@zero_cursor:
	stz @new_cursor

	@set_limit:
	; Limit the cursor to the current length.
	szEditGetParam ctl_edit_sze, #SZ_EDIT_LEN
	cmp @new_cursor
	bmi @limit_cursor
	lda @new_cursor
	sta ctl_edit_cursor 
	bra @continue

	@limit_cursor:
	szEditGetParam ctl_edit_sze, #SZ_EDIT_LEN
	sta ctl_edit_cursor 

	@continue:
	; Initialize the cursor x,y values.
	szEditGetParam ctl_edit_sze, #SZ_EDIT_X
	clc
	adc ctl_edit_cursor
	sta ctl_edit_cursor_x

	szEditGetParam ctl_edit_sze, #SZ_EDIT_Y
	sta ctl_edit_cursor_y

	jsr ctl_edit_display_cursor
	rts
	.endproc


.export ctl_edit_begin 
.proc ctl_edit_begin
		@sze_addr		= zp_ind

	bra @start
		@index:			.byte 0	

	@start:
	memSet_16_16 @sze_addr, ctl_edit_sze	

	; If this same control is already active, don't click it again.
	ldy #ctl::index
	lda (ctl_loop),y
	sta @index

	cmp ctl_focus
	bne @switch_control
	; But do re-init the cursor to move it to the mouse.
	jsr ctl_edit_init_cursor

	@switch_control:
	; Set this new control to be the focus.
	lda @index
	sta ctl_focus

	; Turn on the cursor.
	jsr ctl_edit_init_cursor
	rts
	.endproc
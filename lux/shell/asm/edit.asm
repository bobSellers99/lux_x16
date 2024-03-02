;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_EDIT_ASM_:
.include "../inc/shell.inc"
.export edit_
edit_:

edit_start_x:		.byte 0
edit_start_y:		.byte 0
edit_last_y:		.byte 0
;edit_cmd_start:		.byte 0
.export edit_cur_char
edit_cur_char:		.byte 0
.export edit_cursor
edit_cursor:		.byte 0
edit_insert_mode:	.byte 0	
edit_cursor_x:		.word 0	
edit_cursor_y:		.word 0	
.export edit_len
edit_len:			.byte 0
edit_len_increased:	.byte 0
edit_maxlen:		.byte 0
edit_blink_state:	.byte 0
edit_blink_init:	.byte 0
edit_blink_time:	.byte 0


.export edit_update
edit_update:
	bra @start

		@cur_x:		.word 0	;TODO refactor these first 4 vars out.
		@cur_y:		.byte 0
		@len_x:		.word 0
		@len_y:		.byte 0
		@blank_num:	.byte 0
	@start:
;	text_command_line edit_start_x, edit_start_y ,lux_cmd_str ,#$b1

; If the "edit_len" var increases, AND the end of the string lands on a new line,
; then the screen needs to be scrolled and the y vars updated.

	; Scroll check
	lda edit_len_increased
	beq @skip_scroll_check
	stz edit_len_increased

	; Check to see if the end_y point has increased
	memSet_8_16 edit_len, @len_x
	math_ADD_8_16 edit_start_x, @len_x
	lda edit_start_y
	sta @cur_y
	dec @cur_y ; Start the line count one too low.
		@loop:
		sec
		inc @cur_y
		math_SUB_8_16 #80, @len_x
		lda @len_x
		beq @done
		bcs @loop
	bra @skip_scroll_check
	
	@done:
	inc term_char_y

	lda term_char_y
	cmp #29
	bne @loop

	jsr text_scroll
	dec edit_start_y

	@skip_scroll_check:
; This first section of the code updates the cursor pos, so it needs to go 
; in the top of the loop during the vertical blank.
	memSet_8_16 edit_cursor, @cur_x
	math_ADD_8_16 edit_start_x, @cur_x
	lda edit_start_y
	sta @cur_y
	dec @cur_y ; Start the line count one too low.
		@count_lines:
		inc @cur_y
		lda @cur_x
		math_SUB_8_16 #80, @cur_x
		lda @cur_x+1
		bpl @count_lines
	math_ADD_8_16 #80, @cur_x

	; Update cursor sprite.
	memSet_8_16 @cur_x, edit_cursor_x
	mathShiftUp_16 #3, edit_cursor_x
	memSet_8_16 @cur_y, edit_cursor_y
	mathShiftUp_16 #4, edit_cursor_y

	memSet_IMM_24 (VRAM_mouse+128), ZP24_R1
	sprite_set #1, #3, edit_cursor_x, edit_cursor_y
	stz edit_blink_time

; See note above about vertical sync.


	; Blank to the end of the line.
	memSet_8_16 edit_len, @len_x
	math_ADD_8_16 edit_start_x, @len_x
	lda edit_start_y
	sta @len_y
	dec @len_y ; Start the line count one too low.
		@get_modulus_80:
		inc @len_y
		lda @len_x
		math_SUB_8_16 #80, @len_x
		lda @len_x+1
		bpl @get_modulus_80
	math_ADD_8_16 #80, @len_x

	lda @len_y
	sta edit_last_y

	lda #80
	sta @blank_num
	sec
	sbc @len_x
	sta @blank_num

	textCommandLine edit_start_x, edit_start_y ,#lux_cmd_str ,#$b1
	textBlank @len_x, @len_y, @blank_num, #$01

	@return:
	rts


.export edit_blink_cursor
edit_blink_cursor:
	inc edit_blink_time
	lda edit_blink_time
	cmp edit_blink_init
	bpl @switch_state
	rts
	
	@switch_state:
	stz edit_blink_time
	lda edit_blink_state
	beq @cursor_off

	; Set cursor on.
	stz edit_blink_state
	memSet_IMM_24 (VRAM_mouse+128), ZP24_R1
	sprite_set #1, #3, edit_cursor_x, edit_cursor_y
	rts

	; Set cursor off.
	@cursor_off:
	lda #1
	sta edit_blink_state
	memSet_IMM_24 (VRAM_mouse+128), ZP24_R1
	sprite_set #1, #0, edit_cursor_x, edit_cursor_y
	rts


.export edit_insert
edit_insert:
	lda edit_cursor
	cmp edit_maxlen
	beq @return

	ldx edit_cursor
	lda edit_cur_char
	sta lux_cmd_str,x
	inc edit_cursor
	inc edit_len
	inc edit_len_increased ; Sets it to 1 or higher, this is the flag to check scrolling.
	jsr edit_update
	
	@return:
	rts


.export edit_delete
edit_delete:
	rts


.export edit_backspace
edit_backspace:
	lda edit_cursor
	beq @return

	; If at end of line...
	dec edit_cursor
	ldx edit_cursor
	lda #0
	sta lux_cmd_str,x
	dec edit_len

	jsr edit_update
	@return:
	rts


.export edit_escape
edit_escape:
	rts


.export edit_return
edit_return:
	lda edit_last_y

	jsr history_add
	jsr term_parse_command
	jsr term_init_cmd

;	jsr edit_clear_cmd
	rts


.export edit_dec_cursor
edit_dec_cursor:
	lda edit_cursor
	beq @return
	dec edit_cursor

	jsr edit_update
	@return:
	rts


.export edit_inc_cursor
edit_inc_cursor:
	ldx edit_cursor
	lda lux_cmd_str,x
	beq @return
	cmp #$0a ; Linefeed
	beq @return

	inc edit_cursor

	jsr edit_update
	@return:
	rts


.export edit_process
edit_process:
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
	cmp #$1b
	beq @escape
	cmp #$0d
	beq @return
	cmp #$80
	beq @left_arrow
	cmp #$81
	beq @right_arrow
	cmp #$82
	beq @up_arrow
	cmp #$83
	beq @down_arrow

	; Rule set for allowed characters.
	cmp #$20	; Don't allow less than space.
	bmi @exit
	cmp #$7f	; Allow up the the ~ character.
	bmi @insert
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

	@escape:
	jsr edit_escape
	rts

	@return:
	jsr edit_return
	rts

	@left_arrow:
	jsr edit_dec_cursor
	rts

	@right_arrow:
	jsr edit_inc_cursor
	rts

	@up_arrow:
	jsr history_up_arrow
	rts

	@down_arrow:
	jsr history_down_arrow
	rts


.export edit_clear_cmd
edit_clear_cmd:
	ldx #0
	@clear:
		lda #0
		sta lux_cmd_str,x
		inx
		bne @clear
	rts


.export edit_set_bg_color
edit_set_bg_color:
	bra @start

		@length:	.byte 0
	@start:	
	@set_bk_color:
		lda #80
		sec
		sbc edit_start_x
		sta @length
		textSetColor edit_start_x, edit_start_y, @length, #$0d
		stz edit_start_x
		inc edit_start_y
		lda edit_last_y
		cmp edit_start_y
		bmi @return
		bra @set_bk_color
	
	@return:
	rts


.export edit_init
edit_init:
	@start:	
	jsr edit_clear_cmd

	lda term_char_x
	sta edit_start_x
	lda term_char_y
	sta edit_start_y

	stz edit_cursor
	stz edit_len
	lda #254
	sta edit_maxlen
	stz edit_blink_state
	lda #30
	sta edit_blink_init
	stz edit_blink_time
	jsr edit_update
	rts
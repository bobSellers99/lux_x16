;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_TERM_ASM_:
.include "../inc/shell.inc"

.export term_
term_:

sys_user_loop = $c45e

.export term_char_x
.export term_char_y
.export term_cmd_word

term_char_x:		.byte 0
term_char_y:		.byte 0
term_color:			.byte 0
term_printing:		.byte 0
term_path_def:		.byte "/ ",0
term_path_init_cmd:	.byte "cd .",0

term_cmd_word:		.res 32
term_not_found_str:	.byte "Command not found",0
luc_shell_fn:		.byte "/bin/lux/lux",0


.export term_parse_exe_from_bin
.proc term_parse_exe_from_bin
	; Save history
	jsr history_save
	jsr history_reset

	; load file at $3000
	fileLoad #find_search_str, #$3000, #0, #0
;	file_load_ram find_search_str, $3000, 0, 0

	; execute file
	jsr $3000

	; In case printing was turned on during the program's run,
	; force it to be off.
	stz term_printing
	rts
	.endproc


.export term_parse_exe_local
.proc term_parse_exe_local
	; Save history
	jsr history_save
	jsr history_reset

	; Change directory 
	mem_SET_IMM_16 find_search_str, fat32_ptr
	jsr file_chdir

	; Set up params for file load.
	mem_SET_IMM_16 term_cmd_word, fat32_ptr
	mem_SET_IMM_16 $0300, fat32_param32
	mem_SET_IMM_16 0, fat32_offset
;	mem_SET_IMM_16 0, R12

	lda #2
	sta main_run
	rts
	.endproc


.export term_parse_command 
.proc term_parse_command
	jsr edit_set_bg_color
	szGetParam #lux_cmd_str, #term_cmd_word, #0, #' '
	bne @non_zero_length
	jsr term_new_cmd_line
	jsr term_init_cmd
	rts

	@non_zero_length:

	; find command in /bin.
	jsr find_bin
	bcs @found_in_bin

	; find in command directory in /bin.
	jsr find_bin_dir
	bcs @found_in_local

	; find command locally.
	jsr find_local
	bcs @found_in_local

	; No command found, display "Command not found"
	jsr term_new_blank_line
	textBlank term_char_x, term_char_y, #80, #$04
	textString term_char_x, term_char_y, #term_not_found_str, #$04
	jsr term_new_cmd_line
	jsr term_init_cmd
	rts

	@found_in_bin:
	jsr term_parse_exe_from_bin
	jsr term_new_cmd_line
	jsr term_init_cmd
	rts

	@found_in_local:
	jsr term_parse_exe_local
	rts
	.endproc


.export term_new_blank_line 
term_new_blank_line:
	stz term_char_x
	inc term_char_y
	; If line == 29, scroll lines 1 to 28 up. Then reset line to 28
	lda term_char_y
	cmp #29
	bne @return
	jsr text_scroll
	
	@return:
	rts


.export term_new_cmd_line 
term_new_cmd_line:
	stz term_char_x
	inc term_char_y
	; If line == 29, scroll lines 1 to 28 up. Then reset line to 28
	lda term_char_y
	cmp #29
	bne @return
	jsr text_scroll
	
	@return:
	textString term_char_x, term_char_y, #lux_path_str, #$05
	szLength #lux_path_str
	sta term_char_x
	jsr edit_init
	rts
	

.export term_init_cmd
term_init_cmd:
	textString term_char_x, term_char_y, #lux_path_str, #$05
	szLength #lux_path_str
	sta term_char_x
	jsr edit_init
	rts


.export term_start_printing
.proc term_start_printing
	; If currently printing, do nothing.
	lda term_printing
	bne @return

	; Otherwise, Turn printing on and drop down a line.
	lda #1
	sta term_printing
	jsr term_new_blank_line
	textBlank term_char_x, term_char_y, #80, #$04

	@return:
	rts
	.endproc


.export term_print_char
term_print_char:
	bra @start

		@new_char:	.byte 0
	@start:
	sta @new_char
	
	jsr term_start_printing

	lda @new_char
	; Special characters.
	cmp #$0d
	beq @new_line

	; All other characters.
	bra @add_char

	@new_line:
	jsr term_new_blank_line
	textBlank term_char_x, term_char_y, #80, #$04
	rts

	@add_char:
	lda @new_char
	textChar term_char_x, term_char_y ,@new_char ,term_color
	inc term_char_x
	rts


.export term_set_color
term_set_color:
	sta term_color
	rts


.export term_set_path_str
term_set_path_str:
	ldx #0
	lda #$40
	clc
	adc lux_drive_id
	sta lux_path_str,x
	inx
	lda #':'
	sta lux_path_str,x
	inx
	lda #0
	sta lux_path_str,x
	szCat #term_path_def, #lux_path_str
	rts


.export text_scroll
	text_scroll:
	; Set up VERA address for the block to copy.
	memSet_IMM_24 VRAM_textmap, ZP24_R0
	math_ADD_IMM_24 512, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	; Set up VERA address for the block to copy to.
	memSet_IMM_24 VRAM_textmap, ZP24_R0
	math_ADD_IMM_24 256, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 1, $10	; Addr1, stride 1

	; Copy 27 lines with 256 bytes per line.
	ldy #27
	ldx #0
		@copy_loop:
		lda vera_data0
		sta vera_data1
		dex
		bne @copy_loop
		ldx #0
		dey
		bne @copy_loop

	; Set up VERA address for the last line clear.
	memSet_IMM_24 VRAM_textmap, ZP24_R0
	math_ADD_IMM_24 (256*28), ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 1, $10	; Addr1, stride 2

	; Clear last line
	ldx #80
		@clear_loop:
		lda #$20
		sta vera_data1
		lda #$f1
		sta vera_data1
		dex
		bne @clear_loop

	lda #28
	sta term_char_y
	stz term_char_x
	rts


.export term_cd
.proc term_cd
	szCopy #term_path_init_cmd, #lux_cmd_str
	szGetParam #lux_cmd_str, #term_cmd_word, #0, #' '
	jsr find_bin
	bcc @return
	jsr term_parse_exe_from_bin
;	jsr term_set_path_str
	jsr term_new_cmd_line
	jsr term_init_cmd
	@return:
	rts
	.endproc

;clock_weekday_list:	.byte "Unk",0,"Sun",0,"Mon",0,"Tue",0,"Wed",0,"Thu",0,"Fri",0,"Sat",0
;clock_month_list:	.byte "Unk",0,"Jan",0,"Feb",0,"Mar",0,"Apr",0,"May",0,"Jun",0
;					.byte "Jul",0,"Aug",0,"Sep",0,"Oct",0,"Nov",0,"Dec",0
;
;.export term_clock
;.proc term_clock
;	bra @start
;
;		@index:		.byte 0
;		@print:		.byte 0
;	@start:
;	lda sys_ticks
;	beq @do_clock
;	rts
;
;	@do_clock:
;	mathBinToBcd_8 fat32_time_hours
;	textBcd_8 #73, #0, #2, #$b1	
;	textChar #75, #0, #':', #$b1	
;
;	mathBinToBcd_8 fat32_time_minutes
;	textBcd_8 #76, #0, #2, #$b1	
;
;	lda fat32_time_weekday
;	clc
;	asl
;	asl
;	tax
;	lda clock_weekday_list,x
;	sta @print
;	textChar #60, #0, @print, #$b1	
;	inx
;	lda clock_weekday_list,x
;	sta @print
;	textChar #61, #0, @print, #$b1	
;	inx
;	lda clock_weekday_list,x
;	sta @print
;	textChar #62, #0, @print, #$b1	
;	textChar #63, #0, #',', #$b1	
;
;	lda fat32_time_month
;	clc
;	asl
;	asl
;	tax
;	lda clock_month_list,x
;	sta @print
;	textChar #65, #0, @print, #$b1	
;	inx
;	lda clock_month_list,x
;	sta @print
;	textChar #66, #0, @print, #$b1	
;	inx
;	lda clock_month_list,x
;	sta @print
;	textChar #67, #0, @print, #$b1	
;
;	mathBinToBcd_8 fat32_time_day
;	textBcd_8 #69, #0, #2, #$b1	
;	textChar #71, #0, #',', #$b1	
;	rts
;	.endproc


.export term_init
term_init:
	lda #$01
	sta term_color

	szCopy #term_path_init_cmd, #lux_cmd_str
	szGetParam #lux_cmd_str, #term_cmd_word, #0, #' '
	jsr find_bin
	bcc @return
	jsr term_parse_exe_from_bin
	jsr term_new_cmd_line
	jsr term_init_cmd

	@return:
	rts	


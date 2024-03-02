;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.export _TEXT_ASM_ 
_TEXT_ASM_:

.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/vera_regs.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/math.inc"

text_vram_map:		.res 3
text_vram_addr:		.res 3


;.export text_set_vram_addr 
.proc text_set_vram_addr
    @char_x         = r0L
    @char_y         = r0H
    @offset         = r0    ; r0L and r0H combine to form the offset.
 
    lda @char_x
	clc
	asl
	sta @char_x
	memSet_24_24 text_vram_map, text_vram_addr
	math_ADD_16_24 @offset, text_vram_addr
	mem_SET_VRAM_ADDR text_vram_addr, 0, $10	; Addr0, stride 1
	rts
	.endproc


;.export text_hex_to_char
.proc text_hex_to_char
    @character	= r1L
    @color		= r1H

	jsr text_set_vram_addr
	lda @character
	cmp #$a
	bpl @char_is_alpha
	ora #$30
	bra @char_is_num

	@char_is_alpha:
	clc
	adc #$57

	@char_is_num:
	sta vera_data0
	lda @color
	sta vera_data0
	rts
	.endproc


;.export text_bcd_lo_digit 
.proc text_bcd_lo_digit
	@color			= r1H

	and #$0f
	ora #$30
	sta vera_data0
	lda @color
	sta vera_data0
	rts
	.endproc


;.export text_bcd_hi_digit 
.proc text_bcd_hi_digit
	@color			= r1H

	lsr
	lsr
	lsr
	lsr
	ora #$30
	sta vera_data0
	lda @color
	sta vera_data0
	rts
	.endproc


;### Start of exported library calls.


.export text_char
.proc text_char
    @character	= r1L
    @color		= r1H

	jsr text_set_vram_addr
	lda @character
	sta vera_data0
	lda @color
	sta vera_data0
	rts
	.endproc


.export text_hex_8
.proc text_hex_8
    @char_x			= r0L
    @character		= r1L

	@saved_char		= r2H

	lda @character
	sta @saved_char
	lsr
	lsr
	lsr
	lsr
	sta @character
	jsr text_hex_to_char

	lda @saved_char
	and #$0f
	sta @character	
	inc @char_x
	jsr text_hex_to_char
	rts
	.endproc


.export text_string
.proc text_string
    @text_addr		= zp_ind
	@color			= r1H

	jsr text_set_vram_addr
	ldy #0
	@loop:
		lda (@text_addr),y
		beq @return
		sta vera_data0
		lda @color
		sta vera_data0
		iny
		bra @loop

	@return:
	tya
	rts
	.endproc


.export text_blank
.proc text_blank
	@num_chars		= r1L
    @color			= r1H

	jsr text_set_vram_addr

	ldx @num_chars
	@loop:
		lda #$20
		sta vera_data0
		lda @color
		sta vera_data0
		dex
		bne @loop
	rts
	.endproc


.export text_set_color
.proc text_set_color
	@num_chars		= r1L
    @color			= r1H

	jsr text_set_vram_addr
	ldx @num_chars
	@loop:
		lda vera_data0
		lda @color
		sta vera_data0
		dex
		bne @loop
	rts
	.endproc


; Prints a multi line string.
.export text_command_line 
.proc text_command_line
	@char_x			= r3L
	@char_y			= r3H
	@xy_offset		= r0
	@text_addr		= zp_ind
	
	@color			= r1H
	@end_of_line	= r2L

	jsr text_set_vram_addr

	lda #80
	sec
	sbc @char_x
	sta @end_of_line
	ldy #0

	@loop:
		lda (@text_addr),y
		beq @return
	;	jsr text_convert_to_petscii
		sta vera_data0
		lda @color
		sta vera_data0
		iny
		cpy @end_of_line
		beq @newline
		bra @loop

	@newline:
	lda @end_of_line
	clc
	adc #80
	sta @end_of_line

	stz @char_x
	inc @char_y
	lda @char_x
	sta @xy_offset
	lda @char_y
	sta @xy_offset+1
	jsr text_set_vram_addr
	bra @loop

	@return:
	rts
	.endproc


.export text_bcd_8
.proc text_bcd_8
		@num_chars		= r1L
		@bcd_input		= zp_result

	jsr text_set_vram_addr

	@text_digit_3:
	lda @num_chars
	cmp #3
	bmi @text_digit_2
	lda @bcd_input+1
	jsr text_bcd_lo_digit

	@text_digit_2:
	lda @num_chars
	cmp #2
	bmi @text_digit_1
	lda @bcd_input
	jsr text_bcd_hi_digit

	@text_digit_1:
	lda @bcd_input
	jsr text_bcd_lo_digit
	rts
	.endproc


.export text_bcd_16
.proc text_bcd_16
		@num_chars		= r1L
		@bcd_input		= zp_result

	jsr text_set_vram_addr

	lda @num_chars
	cmp #5
	bmi @text_digit_4
	lda @bcd_input+2
	jsr text_bcd_lo_digit

	@text_digit_4:
	lda @num_chars
	cmp #4
	bmi @text_digit_3
	lda @bcd_input+1
	jsr text_bcd_hi_digit

	@text_digit_3:
	lda @num_chars
	cmp #3
	bmi @text_digit_2
	lda @bcd_input+1
	jsr text_bcd_lo_digit

	@text_digit_2:
	lda @num_chars
	cmp #2
	bmi @text_digit_1
	lda @bcd_input
	jsr text_bcd_hi_digit

	@text_digit_1:
	lda @bcd_input
	jsr text_bcd_lo_digit
	rts
	.endproc


.export text_init
.proc text_init
	memSet_24_24 ZP24_R0, text_vram_map
	rts
	.endproc	


.export text_string_edit
.proc text_string_edit
    @text_addr		= zp_ind
    @char_x         = r0L
    @char_y         = r0H
	@color			= r1H

	ldy #2
	lda (zp_ind),y
	sta @char_x
	iny
	lda (zp_ind),y
	sta @char_y

	; Point zp_ind to the text string and display it.
	clc
    math_ADD_8_16 #4, zp_ind
	jsr text_string
	rts
	.endproc	

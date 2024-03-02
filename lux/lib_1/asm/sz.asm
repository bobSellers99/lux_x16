;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.export _SZ_ASM_
_SZ_ASM_:

.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/math.inc"
.include "../../../lib/inc/sz.inc"

hex:		.byte '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'


.export char_to_bin 
.proc char_to_bin
	; A holds the incoming ascii hex char.
	cmp #$60;#$3A
	bpl @a_to_f

	cmp #$40;#$3A
	bpl @A_to_F

	sec
	sbc #$30
	rts

	@a_to_f:
	sec
	sbc #$57 
	; A returns the converted binary 0 to 15.
	rts

	@A_to_F:
	sec
	sbc #$37 
	; A returns the converted binary 0 to 15.
	rts
	.endproc


.export sz_length 
.proc sz_length
	ldy #0
	@loop:
		lda (zp_ind),y
		beq @return
		iny
		bne @loop

	; Returns length of string in A.
	@return:
	tya
	rts
	.endproc


.export sz_copy 
.proc sz_copy
	@source			= zp_ind	
	@dest			= zp_ind2	

	phy
	ldy #0
	@loop:
		lda (@source),y
		beq @return
		sta (@dest),y
		iny
		bne @loop

	@return:
	sta (@dest),y
	tya
	ply
	rts
	.endproc


.export sz_cat 
.proc sz_cat
	@to_add			= zp_ind
	@dest			= zp_ind2

	@to_add_index	= r0L
	@dest_index		= r0H
	phy

	; Find the end of the destination string.
	ldy #0
	@len_loop:
		lda (@dest),y
		beq @done_len
		iny
		bne @len_loop

	@done_len:
	sty @dest_index
	stz @to_add_index
	; Add the t0_add string to the end of the destination string.
	@add_loop:
		ldy @to_add_index
		lda (@to_add),y
		beq @return
		ldy @dest_index
		sta (@dest),y
		inc @to_add_index
		inc @dest_index
		bra @add_loop

	@return:
	lda #0
	ldy @dest_index
	sta (@dest),y
	tya
	ply
	rts
	.endproc


; TODO Add limit to dest string.
.export sz_get_param 
.proc sz_get_param
	@source			= zp_ind
	@dest			= zp_ind2
	@index			= r0L
	@token			= r0H

	@cur_char		= r1L
	@cur_index		= r1H
	@source_index	= r2L
	@dest_index		= r2H

	stz @cur_index
	stz @source_index
	stz @dest_index
	ldy #0

	; Get next token.
	@loop:
		ldy @source_index
		inc @source_index
		lda (@source),y
		sta @cur_char
		beq @done
		cmp @token
		beq @next_token
		lda @index
		cmp @cur_index
		beq @add_char
		bra @loop

		@add_char:
		ldy @dest_index
		inc @dest_index
		lda @dest_index
		cmp #31
		beq @done
		lda @cur_char
		sta (@dest),y
		bra @loop

	@next_token:
	inc @cur_index
	bra @loop

	@done:
	ldy @dest_index
	sta (@dest),y
	tya ; Return num chars copied. 
	rts
	.endproc


.export sz_get_num_params 
.proc sz_get_num_params
	@source			= zp_ind
	@token			= r0L

	@count			= r0H

	stz @count
	ldy #0

	; Count tokens.
	@loop:
		lda (@source),y
		iny
		beq @done
		cmp @token
		beq @next_token
		bra @loop

	@next_token:
	inc @count
	bra @loop

	@done:
	lda @count
	rts
	.endproc


.export sz_conv_to_bcd_8 
.proc sz_conv_to_bcd_8
	@source			= zp_ind

	@bcd_out		= zp_result

	stz zp_result

	jsr sz_length
	tay
	
	; No digits at all? return with 0 in the output.
	cpy #0
	beq @return
	
	; Ones digit, first character from end.
	dey
	lda (@source),y
	jsr sz_char_to_bin
	sta @bcd_out
	cpy #0
	beq @return

	; Tens digit, second character from end.
	dey
	lda (@source),y
	jsr sz_char_to_bin
	asl
	asl
	asl
	asl
	ora @bcd_out
	sta @bcd_out
	cpy #0
	beq @return

	@return:
	lda @bcd_out
	rts
	.endproc


.export sz_conv_to_bcd_16 
.proc sz_conv_to_bcd_16
	@source			= zp_ind

	@bcd_out		= zp_result

	jsr sz_length
	tay

	; Do the first 2 digits
	jsr sz_conv_to_bcd_8

	stz @bcd_out+1
	
	; 2 digits or less? Nothing to do.
;	cpy #3
;	bmi @return
	
	; Hundreds digit, third character from end
	ldy #1
	lda (@source),y
	jsr sz_char_to_bin
	sta @bcd_out+1
	cpy #0
	beq @return

	; Thousands digit, fourth character from end
	dey
	lda (@source),y
	jsr sz_char_to_bin
	asl
	asl
	asl
	asl
	ora @bcd_out+1
	sta @bcd_out+1
	cpy #0
	beq @return

	@return:
	lda @bcd_out+1
	rts
	.endproc


.export sz_conv_to_bcd_24 
.proc sz_conv_to_bcd_24
	@source			= zp_ind

	@bcd_out		= zp_result

	jsr sz_length
	tay

	; Do the first 4 digits
	jsr sz_conv_to_bcd_8
	jsr sz_conv_to_bcd_16

	stz zp_result+2
	
	; 4 digits or less? Nothing to do.
	cpy #5
	bmi @return
	
	; Ten thousands digit, fifth character from end
	ldy #4
	lda (@source),y
	jsr sz_char_to_bin
	sta @bcd_out+2
	cpy #0
	beq @return

	; Hundred thousands digit, sixth character from end
	dey
	lda (@source),y
	jsr sz_char_to_bin
	asl
	asl
	asl
	asl
	ora @bcd_out+2
	sta @bcd_out+2
	cpy #0
	beq @return

	@return:
	lda @bcd_out+2
	rts
	.endproc


.export sz_edit_init 
.proc sz_edit_init
	@source			= zp_ind
	@max			= r0L
	@len			= r0H
	@char_x			= r1L
	@char_y			= r1H
	@default		= zp_ind2

	@index_source	= r2L
	@index_dest		= r2H

	ldy #0
	lda @max
	sta (zp_ind),y
	iny
	lda @len
	sta (zp_ind),y
	iny
	lda @char_x
	sta (zp_ind),y
	iny
	lda @char_y
	sta (zp_ind),y
	iny

	stz @index_source
	sty @index_dest
	@loop:
		ldy @index_source
		lda (zp_ind2),y
		beq @loop_done
		ldy @index_dest
		sta (zp_ind),y
		inc @index_source
		inc @index_dest
		bra @loop

	@loop_done:
	rts
	.endproc


.export sz_char_to_bin 
.proc sz_char_to_bin
	jsr char_to_bin
	rts
	.endproc


.export set_bcd
.proc set_bcd

	@source			= zp_ind
	@hex			= zp_ind2
	@index			= r0H
	@offset			= r1L
	@bcd_in			= r2

	ldy @offset
	lda (@bcd_in),y
	and #$0f
	tay
	lda (@hex),y
	ldy @index
	sta (@source),y
	dec @index

	ldy @offset
	lda (@bcd_in),y
	lsr
	lsr
	lsr
	lsr
	tay
	lda (@hex),y
	ldy @index
	sta (@source),y
	dec @index

	rts
	.endproc


.export sz_edit_set_bcd_8 
.proc sz_edit_set_bcd_8
	@source			= zp_ind

	@hex			= zp_ind2
	@num_chars		= r0L
	@index			= r0H
	@offset			= r1L
	@bcd_in			= r2

	memSet_16_16 #hex, @hex
	memSet_16_16 #zp_result, @bcd_in
	stz @offset
	ldy #SZ_EDIT_MAX
	lda (@source),y
	sta @index
	ldy #SZ_EDIT_LEN
	sta (@source),y

	dec @index

	; Index source to the beginning of the string.
	math_ADD_8_16 #SZ_EDIT_TEXT, @source

	jsr set_bcd
	rts
	.endproc


.export sz_edit_set_bcd_16 
.proc sz_edit_set_bcd_16

	@offset			= r1L

	jsr sz_edit_set_bcd_8

	inc @offset
	jsr set_bcd
	rts
	.endproc



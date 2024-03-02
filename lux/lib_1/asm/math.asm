;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.export _MATH_ASM_
_MATH_ASM_:

.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/math.inc"


.export math_shift_down_A
.proc math_shift_down_A
	cpx #0
	beq :++	; Do nothing if 0 bits
	:
	clc
	ror
	dex
	bne :-
	:
	rts
	.endproc


.export math_shift_down_16
.proc math_shift_down_16
	@val16			= zp_oper1

	cpx #0
	beq :++	; Do nothing if 0 bits
	:
	clc
	lda @val16+1
	ror
	sta @val16+1
	lda @val16
	ror
	sta @val16
	dex
	bne :-
	:
	rts
	.endproc


.export math_shift_down_24
.proc math_shift_down_24
	@val24			= zp_oper1

	cpx #0
	beq :++	; Do nothing if 0 bits
	:
	clc
	lda @val24+2
	ror
	sta @val24+2
	lda @val24+1
	ror
	sta @val24+1
	lda @val24
	ror
	sta @val24
	dex
	bne :-
	:
	rts
	.endproc


.export math_shift_up_A
.proc math_shift_up_A
	cpx #0
	beq :++	; Do nothing if 0 bits
	:
	clc
	asl
	dex
	bne :-
	:
	rts
	.endproc


.export math_shift_up_16
.proc math_shift_up_16
	@val16			= zp_oper1

	cpx #0
	beq :++	; Do nothing if 0 bits
	:
	clc
	lda @val16
	asl
	sta @val16
	lda @val16+1
	rol
	sta @val16+1
	dex
	bne :-
	:
	rts
	.endproc


.export math_mult_8_8
.proc math_mult_8_8
	@operand_1 		= zp_oper1
	@operand_2 		= zp_oper2
	@result 		= zp_result

	; Init and muly-by-0 block
	stz @result
	stz @result+1
	lda @operand_1
	beq @return
	lda @operand_2
	beq @return

	phy
	lda @operand_1
	sta @result
	ldy #8
	lda #0

	; If the next bit is 1, then add and shift, otherwise
	; just shift. 
	@adder:
	lda @result
	and #1
	beq @shifter
	clc
	lda @result+1
	adc @operand_2
	sta @result+1

	@shifter:
	clc
	ror @result+1
	ror @result
	dey
	bne @adder
	ply

	@return:
	rts
	.endproc


.export math_mult_16_16
.proc math_mult_16_16
	@operand_1 		= zp_oper1
	@operand_2 		= zp_oper2
	@result 		= zp_result

	; Init: clear result, and mult-by-0 block
	stz @result
	stz @result+1
	stz @result+2
	stz @result+3

	lda @operand_1
	ora @operand_1+1
	beq return
	lda @operand_2
	ora @operand_2+1
	beq return

	phy
	; Load first operand into second half of shift train.
	lda @operand_1
	sta @result
	lda @operand_1+1
	sta @result+1

	ldy #16
	lda #0

	; If the next bit is 1, then add and shift, otherwise
	; just shift. 
	@adder:
	lda @result
	and #1
	beq @shifter
	clc
	lda @result+2
	adc @operand_2
	sta @result+2
	lda @result+3
	adc @operand_2+1
	sta @result+3

	@shifter:
	lsr @result+3
	ror @result+2
	ror @result+1 
	ror @result

	dey
	bne @adder
	ply

	return:
	rts
	.endproc


.export math_bcd_8_to_bin_8 
.proc math_bcd_8_to_bin_8

	@output				= zp_result

	phx
	tax				; Save original 2 digit BCD
	and #$f0
	; The tens digit is in A, but it's shifted left 4 bits, so in binary
	; terms, it's multiplied by 16. We want it multiplied by 10, which
	; is (tens * 8) + (tens * 2).
	lsr
	; First, we shift it right by 1, making it multiplied by 8, then store
	; it in @temp_sum.
	sta @output
	lsr
	lsr
	; Then we shift it 2 more times right, so it's multiplied by 2, then 
	; add that to the temporary sum.
	clc
	adc @output
	sta @output
	txa
	; Finally, we get the ones digit from X and add it to @temp_sum.
	and #$0f
	clc
	adc @output
	plx
	rts
	.endproc


.export math_bcd_16_to_bin_16 
.proc math_bcd_16_to_bin_16
	@input			= zp_result

	@ones			= r0L
	@hundreds		= r0H

	; Compute first stages.
	lda @input
	jsr math_bcd_8_to_bin_8
	sta @ones

	lda @input+1
	jsr math_bcd_8_to_bin_8
	sta @hundreds

	; Clear result and init with ones.
	stz zp_result
	stz zp_result+1
	lda @ones
	sta zp_temp32
	stz zp_temp32+1

	; Multiple in hundreds
	memSet_8_16 @hundreds, zp_oper1
	memSet_8_16 #100, zp_oper2
	jsr math_mult_8_8
	math_ADD_16_16 zp_result, zp_temp32

	memSet_16_16 zp_temp32, zp_result
	rts
	.endproc


.export math_bcd_24_to_bin_16 
.proc math_bcd_24_to_bin_16
	@input			= zp_result

	@ones			= r0L
	@hundreds		= r0H
	@tenKs			= r1L

	; Compute first stages.
	lda @input
	jsr math_bcd_8_to_bin_8
	sta @ones

	lda @input+1
	jsr math_bcd_8_to_bin_8
	sta @hundreds

	lda @input+2
	jsr math_bcd_8_to_bin_8
	sta @tenKs

	; Clear result and init with ones.
	stz zp_result
	stz zp_result+1
	lda @ones
	sta zp_temp32
	stz zp_temp32+1

	; Multiple in hundreds
	memSet_8_16 @hundreds, zp_oper1
	memSet_8_16 #100, zp_oper2
	jsr math_mult_8_8
	math_ADD_16_16 zp_result, zp_temp32

	; Multiple in tenKs
	memSet_8_16 @tenKs, zp_oper1
	memSet_16_16 #10000, zp_oper2
	jsr math_mult_16_16
	math_ADD_16_16 zp_result, zp_temp32

	memSet_16_16 zp_temp32, zp_result
	rts
	.endproc


.export math_bcd_32_to_bin_24 
.proc math_bcd_32_to_bin_24
	rts
	.endproc


.export math_bcd_48_to_bin_32 
.proc math_bcd_48_to_bin_32
	rts
	.endproc


.export math_bin_to_bcd_8
.proc math_bin_to_bcd_8

	@input		= zp_oper1
	@output		= zp_result

	phx
	sta @input
	sed		; set BCD mode.
	; Ensure the result is clear.
	stz @output
	stz @output+1
	
	ldx #8	; The number of source bits

	; The converter starts at the most significant bit and rotates down from
	; there. Once the first set bit is found, the output is doubled and 1 is
	; added to it for each set bit. Here's why it works: All it matters is how
	; many TIMES you double the output, not the true value of the bit. 
	@convert_bit:
		asl @input	; Shift out one bit

		lda @output	; And add into result
		adc @output
		sta @output

		lda @output+1	; propagating any carry
		adc @output+1
		sta @output+1

		dex		; And repeat for next bit
		bne @convert_bit

	cld		; Back to binary.
	plx
	lda @output
	rts
	.endproc


.export math_bin_to_bcd_16
.proc math_bin_to_bcd_16
	@input		= zp_oper1

	@output		= zp_result

	sed		; set BCD mode.
	; Ensure the result is clear.
	stz @output
	stz @output+1
	stz @output+2
	
	ldx #16	; The number of source bits

	; The converter starts at the most significant bit and rotates down from
	; there. Once the first set bit is found, the output is doubled and 1 is
	; added to it for each set bit. Here's why it works: All it matters is how
	; many TIMES you double the output, not the true value of the bit. 
	@convert_bit:
		asl @input	; Shift out one bit
		rol @input+1

		lda @output	; And add into result
		adc @output
		sta @output

		lda @output+1	; propagating any carry
		adc @output+1
		sta @output+1

		lda @output+2	; ... thru whole result
		adc @output+2
		sta @output+2

		dex		; And repeat for next bit
		bne @convert_bit

	cld		; Back to binary.
	rts
	.endproc


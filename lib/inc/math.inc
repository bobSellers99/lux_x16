;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

.macro math_ADD_16_16 operand, result
	clc
	lda result
	adc operand
	sta result
	lda result+1
	adc operand+1
	sta result+1
	.endmacro

.ifndef _MATH_ASM_

math_shift_down_A		= $9d80
math_shift_down_16		= $9d83
math_shift_down_24		= $9d86
math_shift_up_A			= $9d89
math_shift_up_16		= $9d8c
math_mult_8_8			= $9d8f
math_mult_16_16			= $9d92
math_bcd_8_to_bin_8		= $9d95
math_bcd_16_to_bin_16	= $9d98
math_bcd_24_to_bin_16	= $9d9b
math_bcd_32_to_bin_24	= $9d9e
math_bcd_48_to_bin_32	= $9da1
math_bin_to_bcd_8		= $9da4
math_bin_to_bcd_16		= $9da7


.macro math_IND_IDX_INC source_addr, index
	mem_GET_IND_IDX_A source_addr, index
	inc
	mem_SET_A_IND_IDX source_addr, index
	.endmacro


.macro math_INC_16 addr16
	inc addr16
	bne :+
	inc addr16+1
	:
	.endmacro


.macro math_INC_24 addr24
	inc addr24
	bne :+
	inc addr24+1
	bne :+
	inc addr24+2
	:
	.endmacro


.macro math_IND_IDX_DEC source_addr, index
	mem_GET_IND_IDX_A source_addr, index
	dec
	mem_SET_A_IND_IDX source_addr, index
	.endmacro


.macro math_DEC_16 loc
	sec
	lda loc
	sbc #$01
	sta loc
	lda loc+1
	sbc #$00
	sta loc+1
	.endmacro


.macro math_DEC_24 addr_24
	sec
	lda addr_24
	sbc #$01
	sta addr_24
	lda addr_24+1
	sbc #$00
	sta addr_24+1
	lda addr_24+2
	sbc #$00
	sta addr_24+2
	.endmacro


.macro math_ADD_IMM_16 operand, result
	clc
	lda result
	adc #<operand
	sta result
	lda result+1
	adc #>operand
	sta result+1
	.endmacro


.macro math_ADD_A_16 result
	clc
	adc result
	sta result
	lda result+1
	adc #0
	sta result+1
	.endmacro


.macro math_ADD_8_16 operand, result
	clc
	lda result
	adc operand
	sta result
	lda result+1
	adc #0
	sta result+1
	.endmacro


.macro math_ADD_IMM_24 operand, result
	clc
	lda result
	adc #<operand
	sta result

	lda result+1
	adc #>operand
	sta	result+1

	lda result+2
	adc #^operand
	sta	result+2
	.endmacro


.macro math_ADD_A_24 result
	clc
	adc result
	sta result

	lda result+1
	adc #0
	sta	result+1

	lda result+2
	adc #0
	sta	result+2
	.endmacro


.macro math_ADD_8_24 operand, result
	clc
	lda result
	adc operand
	sta result

	lda result+1
	adc #0
	sta	result+1

	lda result+2
	adc #0
	sta	result+2
	.endmacro


.macro math_ADD_16_24 operand, result
	clc
	lda result
	adc operand
	sta result

	lda result+1
	adc operand+1
	sta	result+1

	lda result+2
	adc #0
	sta	result+2
	.endmacro


.macro math_ADD_24_24 operand, result
	clc
	lda result
	adc operand
	sta result

	lda result+1
	adc operand+1
	sta result+1

	lda result+2
	adc operand+2
	sta result+2
	.endmacro


.macro math_SUB_IMM_16 minuend, result
	sec
	lda result
	sbc #<minuend
	sta result
	lda result+1
	sbc #>minuend
	sta result+1
	.endmacro


.macro math_SUB_8_16 minuend, result
	sec
	lda result
	sbc minuend
	sta result
	lda result+1
	sbc #0
	sta result+1
	.endmacro

.macro math_SUB_8_24 minuend, result
	sec
	lda result
	sbc minuend
	sta result
	lda result+1
	sbc #0
	sta result+1
	lda result+2
	sbc #0
	sta result+2

	.endmacro


.macro math_SUB_16_16 minuend, result
	sec
	lda result
	sbc minuend
	sta result
	lda result+1
	sbc minuend+1
	sta result+1
	.endmacro


.macro mathShiftDown_A num_bits
	phx
	ldx num_bits
	jsr math_shift_down_A 
	plx
	.endmacro


.macro mathShiftDown_8 num_bits, addr
	phx
	lda addr
	ldx num_bits
	jsr math_shift_down_A 
	sta addr
	plx
	.endmacro


.macro mathShiftDown_16 num_bits, addr16
	phx
	memSet_16_16 addr16, zp_oper1 
	ldx num_bits
	jsr math_shift_down_16 
	memSet_16_16 zp_oper1, addr16
	plx
	.endmacro


.macro mathShiftDown_24 num_bits, addr24
	phx
	memSet_24_24 addr24, zp_oper1 
	ldx num_bits
	jsr math_shift_down_24 
	memSet_24_24 zp_oper1, addr24	;zp_oper1
	plx
	.endmacro


.macro mathShiftUp_A num_bits
	phx
	ldx num_bits
	jsr math_shift_up_A 
	plx
	.endmacro


.macro mathShiftUp_8 num_bits, addr
	phx
	lda addr
	ldx num_bits
	jsr math_shift_up_A 
	sta addr
	plx
	.endmacro


.macro mathShiftUp_16 num_bits, addr16
	phx
	memSet_16_16 addr16, zp_oper1  
	ldx num_bits
	jsr math_shift_up_16 
	memSet_16_16 zp_oper1, addr16
	plx
	.endmacro


.macro if_A_eq_8 value2
	cmp value2
	bne :+
	.endmacro


.macro if_8_eq_8 value1, value2
	lda value1
	cmp value2
	bne :+
	.endmacro


.macro if_16_eq_IMM value1, value2
	lda value1+1
	cmp #>value2
	bne :+
	lda value1
	cmp #<value2
;	:
	bne :+
	.endmacro


.macro if_8_eq_16 value1, value2
	lda #0
	cmp value2+1
	bne :+
	lda value1
	cmp value2
;	:
	bne :+
	.endmacro


.macro if_8_gt_16 value1, value2
	lda #0
	cmp value2+1
	bne :+
	lda value1
	cmp value2
;	:
	bcc :+
	.endmacro


.macro if_8_lt_16 value1, value2
	lda #0
	cmp value2+1
	bcc :+
	lda value1
	cmp value2
	bcc :+
	bra :++
	:
	.endmacro


.macro if_16_eq_16 value1, value2
	lda value1+1
	cmp value2+1
	bne :+
	lda value1
	cmp value2
	bne :+
	.endmacro


.macro if_16_lt_16 value1, value2
	lda value1+1
	cmp value2+1
	bcc :+
	lda value1
	cmp value2
	bcc :+
	bra :++
	:
	.endmacro


.macro if_16_gt_16 value1, value2
	lda value1+1
	cmp value2+1
	bne :+
	lda value1
	cmp value2
	:
	bmi :+
	.endmacro


.macro mathMultiply_A_8 oper2, result
	sta zp_oper1
	lda oper2
	sta zp_oper2
	jsr math_mult_8_8 
	memSet_16_16 zp_result, result 
	.endmacro


.macro mathMultiply_A_X result
	sta zp_oper1
	stx zp_oper2
	jsr math_mult_8_8 
	memSet_16_16 zp_result, result 
	.endmacro


.macro mathMultiply_8_8 oper1, oper2, result
	lda oper1
	sta zp_oper1
	lda oper2
	sta zp_oper2
	jsr math_mult_8_8 
	memSet_16_16 zp_result, result 
	.endmacro


.macro mathMultiply_16_16 oper1, oper2, result
	memSet_16_16 oper1, zp_oper1
	memSet_16_16 oper2, zp_oper2
	jsr math_mult_16_16 
	memSet_32_32 zp_result, result	;r2;r3 
	.endmacro


.macro mathBcdToBin_A
	jsr math_bcd_8_to_bin_8
	.endmacro


.macro mathBcd16ToBin_16 dest
	jsr math_bcd_16_to_bin_16
	.ifnblank dest
		memSet_16_16 zp_result, dest
	.endif
	.endmacro


.macro mathBcd24ToBin_16 dest
	jsr math_bcd_24_to_bin_16
	.ifnblank dest
		memSet_16_16 zp_result, dest
	.endif
	.endmacro


.macro mathBinToBcd_8 input
	lda input
	sta zp_oper1
	stz zp_oper1+1
	jsr math_bin_to_bcd_8
	; Returns output value in zp_result
	.endmacro 


.macro mathBinToBcd_16	input
	memSet_16_16 input, zp_oper1
	jsr math_bin_to_bcd_16
	; Returns output value in zp_result
	.endmacro 

.endif	

;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.macro mem_ZERO_16 dest
	stz dest
	stz dest+1
	.endmacro


.macro mem_ZERO_24 dest
	stz dest
	stz dest+1
	stz dest+3
	.endmacro


.macro mem_ZERO_32 dest
	stz dest
	stz dest+1
	stz dest+2
	stz dest+3
	.endmacro


.macro mem_SET_A_16 dest
	sta dest
	stz dest+1
	.endmacro


.macro mem_SET_IMM_16 value, dest
	lda #<value
	sta dest
	lda #>value
	sta dest+1
	.endmacro


.macro mem_SET_IMM_24 value, dest
	lda #<value
	sta dest
	lda #>value
	sta dest+1
	lda #^value
	sta dest+2
	.endmacro


.macro mem_SET_8_16 source, dest
	lda source
	sta dest
	stz dest+1
	.endmacro


.macro mem_SET_16_16 source, dest
	lda source
	sta dest
	lda source+1
	sta dest+1
	.endmacro


.macro mem_SET_24_24 source, dest
	lda source
	sta dest
	lda source+1
	sta dest+1
	lda source+2
	sta dest+2
	.endmacro


.macro mem_SET_8_HI source, dest
	lda source
	lsr
	lsr
	lsr
	lsr
	sta dest
	.endmacro


.macro mem_SET_A_IND dest_addr
	pha	; A is needed at the end, must use the stack to preserve it.
	mem_SET_16_16 dest_addr, ZP_IND
	pla
	sta (ZP_IND)
	.endmacro


.macro mem_SET_A_IND_IDX dest_addr, index
	pha	; A is needed at the end, must use the stack to preserve it.
	mem_SET_16_16 dest_addr, ZP_IND
	ldy index
	pla
	sta (ZP_IND),y
	.endmacro


.macro mem_SET_A_IMM_IND_IDX dest_addr, index
	pha	; A is needed at the end, must use the stack to preserve it.
	mem_SET_IMM_16 dest_addr, ZP_IND
	ldy index
	pla
	sta (ZP_IND),y
	.endmacro


.macro mem_SET_8_IND source, dest_addr, index
	mem_SET_16_16 dest_addr, ZP_IND
	ldy index
	lda source
	sta (ZP_IND),y
	.endmacro


;.macro mem_SET_IMM_8_IND source, dest_addr, index
;	mem_SET_IMM_16 dest_addr, ZP_IND
;	ldy index
;	lda source
;	sta (ZP_IND),y
;	.endmacro


.macro	mem_SET_8_INDABS source_addr, dest_addr
	mem_SET_16_16 dest_addr, ZP_IND
	lda source_addr
	sta (ZP_IND)
	.endmacro


.macro mem_SET_IND_8 source_addr, index, dest
	mem_SET_16_16 source_addr, ZP_IND
	ldy index
	lda (ZP_IND),y
	sta dest
	.endmacro

; TODO shound be "mem_SET_16_IND_IDX" Probably others to fix as well.
.macro mem_SET_16_IND source, dest_addr, index
	mem_SET_16_16 dest_addr, ZP_IND
	ldy index
	lda source
	sta (ZP_IND),y
	iny
	lda source+1
	sta (ZP_IND),y
	.endmacro


.macro mem_SET_IND_16 source_addr, index, dest
	mem_SET_16_16 source_addr, ZP_IND
	ldy index
	lda (ZP_IND),y
	sta dest
	iny
	lda (ZP_IND),y
	sta dest+1
	.endmacro


.macro mem_GET_IND_A source_addr
	mem_SET_16_16 source_addr, ZP_IND
	lda (ZP_IND)
	.endmacro


.macro mem_GET_IND_IDX_A source_addr, index
	mem_SET_16_16 source_addr, ZP_IND
	ldy index
	lda (ZP_IND),y
	.endmacro


.macro mem_GET_IND_8 source_addr, index, dest_addr
	mem_SET_16_16 source_addr, ZP_IND
	ldy index
	lda (ZP_IND),y
	sta dest_addr
	.endmacro

; Should be mem_GET_IMM_IND_IDX_A
.macro mem_GET_IMM_IND_A source_addr, index
	mem_SET_IMM_16 source_addr, ZP_IND
	ldy index
	lda (ZP_IND),y
	.endmacro


.macro mem_GET_IMM_IND_16 source_addr, index, dest_addr
	mem_SET_IMM_16 source_addr, ZP_IND
	clc
	lda index
	asl
	tay
	lda (ZP_IND),y
	sta dest_addr
	iny
	lda (ZP_IND),y
	sta dest_addr+1
	.endmacro


.macro JSRFAR far_addr, bank
    jsr jsrfar
    .addr far_addr
    .byte bank
.endmacro


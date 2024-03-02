;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.pc02

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


; memConv is used to convert the memSet 16 bit vars to a common
; format so they can be used in #immediate or address mode.
; Do it this way, then figure out how to use 1 macro.
.macro memConv_16 source
	.if (.match (.left (1, {source}), #))
   	    lda #<(.right (.tcount ({source})-1, {source}))
   	    sta zp_memtemp
   	    lda #>(.right (.tcount ({source})-1, {source}))
   	    sta zp_memtemp+1
   	.else
   	    lda source
   	    sta zp_memtemp
   	    lda source+1
   	    sta zp_memtemp+1
	.endif		
	.endmacro	


.macro memSet_16_16 source, dest

	.if (.match (.left (1, {source}), #))
		lda #<(.right (.tcount ({source})-1, {source}))
		sta dest
		lda #>(.right (.tcount ({source})-1, {source}))
		sta dest+1
	.else
		lda source
		sta dest
		lda source+1
		sta dest+1
	.endif		
	.endmacro	


.macro mem_SET_IMM_16 value, dest
	lda #<value
	sta dest
	lda #>value
	sta dest+1
	.endmacro


.macro memSet_IMM_24 value, dest
	lda #<value
	sta dest
	lda #>value
	sta dest+1
	lda #^value
	sta dest+2
	.endmacro


.macro memSet_8_16 source, dest
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


.macro mem_SET_8_24 source, dest
	lda source
	sta dest
	stz dest+1
	stz dest+2
	.endmacro



.macro mem_SET_16_24 source, dest
	lda source
	sta dest
	lda source+1
	sta dest+1
	stz dest+2
	.endmacro


.macro memSet_24_24 source, dest
	lda source
	sta dest
	lda source+1
	sta dest+1
	lda source+2
	sta dest+2
	.endmacro


.macro memSet_32_32 source, dest
	lda source
	sta dest
	lda source+1
	sta dest+1
	lda source+2
	sta dest+2
	lda source+3
	sta dest+3
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
	mem_SET_16_16 dest_addr, zp_ind
	pla
	sta (zp_ind)
	.endmacro


.macro mem_SET_A_IND_IDX dest_addr, index
	pha	; A is needed at the end, must use the stack to preserve it.
	mem_SET_16_16 dest_addr, zp_ind
	ldy index
	pla
	sta (zp_ind),y
	.endmacro


.macro mem_SET_A_IMM_IND_IDX dest_addr, index
	pha	; A is needed at the end, must use the stack to preserve it.
	mem_SET_IMM_16 dest_addr, zp_ind
	ldy index
	pla
	sta (zp_ind),y
	.endmacro


.macro mem_SET_8_IND source, dest_addr, index
	mem_SET_16_16 dest_addr, zp_ind
	ldy index
	lda source
	sta (zp_ind),y
	.endmacro


;.macro mem_SET_IMM_8_IND source, dest_addr, index
;	mem_SET_IMM_16 dest_addr, zp_ind
;	ldy index
;	lda source
;	sta (zp_ind),y
;	.endmacro


.macro	mem_SET_8_INDABS source_addr, dest_addr
	mem_SET_16_16 dest_addr, zp_ind
	lda source_addr
	sta (zp_ind)
	.endmacro


.macro mem_SET_IND_8 source_addr, index, dest
	mem_SET_16_16 source_addr, zp_ind
	ldy index
	lda (zp_ind),y
	sta dest
	.endmacro

; TODO shound be "mem_SET_16_IND_IDX" Probably others to fix as well.
.macro mem_SET_16_IND source, dest_addr, index
	mem_SET_16_16 dest_addr, zp_ind
	ldy index
	lda source
	sta (zp_ind),y
	iny
	lda source+1
	sta (zp_ind),y
	.endmacro


.macro mem_SET_IND_16 source_addr, index, dest
	mem_SET_16_16 source_addr, zp_ind
	ldy index
	lda (zp_ind),y
	sta dest
	iny
	lda (zp_ind),y
	sta dest+1
	.endmacro


.macro mem_GET_IND_A source_addr
	mem_SET_16_16 source_addr, zp_ind
	lda (zp_ind)
	.endmacro


.macro mem_GET_IND_IDX_A source_addr, index
	mem_SET_16_16 source_addr, zp_ind
	ldy index
	lda (zp_ind),y
	.endmacro


.macro mem_GET_IND_8 source_addr, index, dest_addr
	mem_SET_16_16 source_addr, zp_ind
	ldy index
	lda (zp_ind),y
	sta dest_addr
	.endmacro

; Should be mem_GET_IMM_IND_IDX_A
.macro mem_GET_IMM_IND_A source_addr, index
	mem_SET_IMM_16 source_addr, zp_ind
	ldy index
	lda (zp_ind),y
	.endmacro


.macro mem_GET_IMM_IND_16 source_addr, index, dest_addr
	mem_SET_IMM_16 source_addr, zp_ind
	clc
	lda index
	asl
	tay
	lda (zp_ind),y
	sta dest_addr
	iny
	lda (zp_ind),y
	sta dest_addr+1
	.endmacro


.macro JSRFAR far_addr, bank
    jsr jsrfar
    .addr far_addr
    .byte bank
.endmacro


.macro mem_SET_VRAM_ADDR zp24, addr0_or_addr1, stride
	lda #addr0_or_addr1
	sta vera_ctrl
	lda zp24
	sta vera_addr_low
	lda zp24+1
	sta vera_addr_high
	lda zp24+2
	ora #stride
	sta vera_addr_bank
	.endmacro

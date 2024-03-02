;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.ifndef _VERA_ASM_

.import vera_init_sprite
.import vera_init_string
.import vera_init_text
.import vera_init_tile
.import vera_blank
.import vera_init


.macro vera_SET_STRIDE stride
	lda VERA_addr_bank
	and #$01
	ora stride 
	sta VERA_addr_bank
	.endmacro


.macro vera_SET_OFFSET offset
	lda #^offset
	sta VERA_addr_bank
	lda #>offset
	sta VERA_addr_high
	lda #<offset
	sta VERA_addr_low
	.endmacro


.macro vera_SET_OFFSET_24 loc
	lda loc+2
	sta VERA_addr_bank
	lda loc+1
	sta VERA_addr_high
	lda loc
	sta VERA_addr_low
	.endmacro


.macro vera_ADD_OFFSET_16 zp_offset
	clc
	lda $30
	adc zp_offset
	sta $30
	lda $31
	adc zp_offset+1
	sta $31
	lda $32
	adc #$0
	sta $32
	.endmacro

.endif	
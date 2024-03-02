;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.ifndef _VERA_ASM_

;.import vera_set_addr
;.import vera_text_offset_to_xy

.import vera_init_sprite
.import vera_init_string
.import vera_init_text
.import vera_init_mapbase
.import vera_init_tilebase
.import vera_blank
.import vera_init


;.macro vera_TEXT_OFFSET_TO_XY loc_x, loc_y
;	lda loc_x
;	sta vera_text_offset_to_xy+2
;	lda loc_y
;	sta vera_text_offset_to_xy+3
;	jsr vera_text_offset_to_xy
;	.endmacro


;.macro vera_SET_ADDR vera_base_addr, offset, which_addr, stride
;	mem_SET_24_24 vera_base_addr, vera_set_addr+2
;	mem_SET_16_16 offset, vera_set_addr+5
;	lda which_addr
;	sta vera_set_addr+7
;	lda stride
;	sta vera_set_addr+8
;	jsr vera_set_addr
;	.endmacro


;.macro vera_SET_VRAM_ADDR zp24, addr0_or_addr1, stride
;	lda #addr0_or_addr1
;	sta vera_ctrl
;	lda zp24
;	sta vera_addr_low
;	lda zp24+1
;	sta vera_addr_high
;	lda zp24+2
;	ora #stride
;	sta vera_addr_bank
;	.endmacro


.macro vera_SET_STRIDE stride
	lda vera_addr_bank
	and #$01
	ora stride 
	sta vera_addr_bank
	.endmacro


.macro vera_SET_OFFSET offset
	lda #^offset
	sta vera_addr_bank
	lda #>offset
	sta vera_addr_high
	lda #<offset
	sta vera_addr_low
	.endmacro


.macro vera_SET_OFFSET_24 loc
	lda loc+2
	sta vera_addr_bank
	lda loc+1
	sta vera_addr_high
	lda loc
	sta vera_addr_low
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
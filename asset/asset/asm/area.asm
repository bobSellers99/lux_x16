;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_AREA_ASM_:
.include "../inc/asset.inc"

.export area_
area_:

area_help_fn:   .byte "asset.scr",0

.export area_init
.proc area_init
	metaLoadScreen VRAM_textmap, #area_help_fn

;	memSet_IMM_24 VRAM_textmap, ZP24_R0
;	inc ZP24_R0+1
;	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr 0, Stride 1	
;	fileLoad #area_help_fn, #vera_data0, #0, #$80
	rts
    .endproc



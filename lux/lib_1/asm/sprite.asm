;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02
.export _SPRITE_ASM_
_SPRITE_ASM_:

.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/vera_regs.inc"
.include "../../../lib/inc/defines.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/math.inc"

sprite_map			= $1fc00

sprite_id:			.word 0

.export sprite_set_palette
.proc sprite_set_palette
	@id				= r0L
	@z_order		= r0H
	@pal_page		= r1L

	; Address of the sprite map entry.
	memSet_IMM_24 sprite_map, ZP24_R0
	memSet_8_16 @id, sprite_id
	mathShiftUp_16 #3, sprite_id
	math_ADD_16_24 sprite_id, ZP24_R0
	math_ADD_IMM_24 6, ZP24_R0		; Index to last byte.
	mem_SET_VRAM_ADDR ZP24_R0, 0, $00

	mathShiftUp_8 #2, @z_order
	lda vera_data0	; (CCCCZZVH) Collision mask,Z depth,V flip,H flip
	and #$f3
	ora @z_order		
	sta vera_data0	; (CCCCZZVH) Collision mask,Z depth,V flip,H flip

	math_INC_24 ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $00

	lda vera_data0	; (HHWWPPPP) Height,Width,Palette offset
	and #$f0
	ora @pal_page
	sta vera_data0	; (HHWWPPPP) Height,Width,Palette offset
	rts
	.endproc


.export sprite_set
.proc sprite_set
	@id				= r0L
	@z_order		= r0H
	@x				= r1
	@y				= r2
	@addr_temp		= r3L

	; Address of the sprite map entry.
	memSet_IMM_24 sprite_map, ZP24_R0
	memSet_8_16 @id, sprite_id
	mathShiftUp_16 #3, sprite_id
	math_ADD_16_24 sprite_id, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10

	; TODO Another way to do this would be to use a 128 element look up
	; with the data initial data already set up and the changable data
	; ready to insert on the fly.
	 
	mathShiftDown_24 #5, ZP24_R1
	lda ZP24_R1
	sta vera_data0	; (AAAAAAAA) Address 12:5
	lda ZP24_R1+1
	sta vera_data0	; (M000AAAA) Mode,000,Address 16:13


;	; Address of the sprite data. 
;	; Modify the 8 bytes for this sprite id
;	mathShiftDown_24 #5, ZP24_R1
;	lda ZP24_R1
;	sta vera_data0	; (AAAAAAAA) Address 12:5

;	;TODO Allow mode bit to be set (mode is bpp: 0 = 4bpp, 1 = 8bpp)
;;	lda #$00 ; mode is 0 (4bpp)
;	mathShiftDown_24 #8, ZP24_R1
;	lda ZP24_R1
;;	ora @mode
;	sta vera_data0	; (M000AAAA) Mode,000,Address 16:13

	lda @x
	sta vera_data0
	lda @x+1
	sta vera_data0

	lda @y
	sta vera_data0
	lda @y+1
	sta vera_data0

	lda ZP24_R0+2
;	ora @stride
	sta vera_addr_bank

	mathShiftUp_8 #2, @z_order
	lda vera_data0	; (CCCCZZVH) Collision mask,Z depth,V flip,H flip
	and #$f3
	ora @z_order		
	sta vera_data0	; (CCCCZZVH) Collision mask,Z depth,V flip,H flip
	rts
	.endproc


.export sprite_init
.proc sprite_init
	@id				= r0L
	@bpp			= r0H
	@height			= r1L
	@width			= r1H
	@pal_offset		= r2L

	memSet_IMM_24 sprite_map, ZP24_R0
	memSet_8_16 @id, sprite_id
	mathShiftUp_16 #3, sprite_id
	math_ADD_16_24 sprite_id, ZP24_R0
	math_ADD_IMM_24 6, ZP24_R0		; Index to last 2 bytes.
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10

;	; Initialize the 8 bytes for this sprite id
;	lda #0
;	sta vera_data0	; (AAAAAAAA) Address 12:5
;
;	math_SHIFT_UP_8 #7, @bpp
;	lda @bpp
;	sta vera_data0	; (M000AAAA) Bpp,000,Address 16:13
;
;	lda #0		
;	sta vera_data0	; (XXXXXXXX) X 7:0
;	lda #0
;	sta vera_data0	; (000000XX) X 9:8
;
;	lda #0		
;	sta vera_data0	; (XXXXXXXX) Y 7:0
;	lda #0
;	sta vera_data0	; (000000XX) Y 9:8


	; Init ONLY needs to set these last 2 bytes.

	lda #0		
	sta vera_data0	; (CCCCZZVH) Collision mask,Z depth,V flip,H flip

	mathShiftUp_8 #6, @height
	mathShiftUp_8 #4, @width
	lda @height
	ora @width
	ora @pal_offset
	sta vera_data0	; (HHWWPPPP) Height,Width,Palette offset
	rts
	.endproc
	

.export sprite_flip
.proc sprite_flip
	@id			= r0
	@flip		= r1L

	memSet_IMM_24 sprite_map, ZP24_R0
	mathShiftUp_16 #3, @id
	math_ADD_16_24 @id, ZP24_R0
	math_ADD_IMM_24 6, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $0

	lda vera_data0	; (CCCCZZVH) Collision mask,Z depth,V flip,H flip
	and #$8c
	ora @flip
	sta vera_data0	; (CCCCZZVH) Collision mask,Z depth,V flip,H flip
	rts
	.endproc


.export sprite_reset
.proc sprite_reset
	memSet_IMM_24 sprite_map, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10

	ldy #4	; 4 loops of 256 = 128 entries of 8 bytes per entry. 1K total.
	ldx #0
	@spritemap_page_loop:
		@spritemap_byte_loop:
			lda #$0 
			sta vera_data0
			inx
			bne @spritemap_byte_loop
		dey
		bne @spritemap_page_loop	
	rts
	.endproc

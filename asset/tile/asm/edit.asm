;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_EDIT_ASM_:
.include "../inc/main.inc"

.export edit_

edit_:

.export edit_set_pixel
.export edit_init


.proc edit_set_pixel
	bra @start

		@pixel:     .byte 0
        @offset:	.word 0
	@start:
	sta @pixel

	; Get the tile's vram addr for the tile map.
	memSet_IMM_24 VRAM_tilemap, ZP24_R0
	math_ADD_IMM_24 $81a, ZP24_R0

	; Compute the offest and add it to the addr.
	lda area_raw_x
	clc
	asl
	sta @offset
	lda area_raw_y
	sta @offset+1
	math_ADD_16_24 @offset, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	; Write the pixel.
	lda #01	; Pixel mask (Tile Index.)
	sta vera_data0
	lda @pixel	; Pixel color.
	sta vera_data0
	rts
    .endproc


.export edit_dropper
.proc edit_dropper
	bra @start

		@pixel:		.byte 0
        @offset:	.word 0
	@start:
	; Get the tile's vram addr for the tile map.
	memSet_IMM_24 VRAM_tilemap, ZP24_R0
	math_ADD_IMM_24 $81a, ZP24_R0

	; Compute the offest and add it to the addr.
	lda area_raw_x
	clc
	asl
	sta @offset
	lda area_raw_y
	sta @offset+1
	math_ADD_16_24 @offset, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	; Read the pixel color and set the palette.
	lda vera_data0	; Mask index. Don't need.
	lda vera_data0	; Pixel color
	sta @pixel

	and #$0f
	sta area_cur_color

	lda @pixel
	mathShiftDown_A #4
	sta palette_page

	jsr palette_set_cur
	jsr palette_draw

	mathBinToBcd_8 palette_page
	textStringEdit #palette_page_sze ,#$b7
	rts
	.endproc


.export edit_fill
.proc edit_fill
	rts
	.endproc


.export edit_global_fill
.proc edit_global_fill
	bra @start

		@old_pixel:		.byte $10
		@new_pixel:		.byte $00
	@start:
	; Set up both vera addresses:
	memSet_IMM_24 VRAM_areadata, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	mem_SET_VRAM_ADDR ZP24_R0, 1, $10	; Addr1, stride 1

	ldy #0
	ldx #0
		@loop_y:
			@loop_x:
			lda vera_data0
			cmp @old_pixel
			beq @fill
			sta vera_data1
			dex
			bne @loop_x
			bra @break
			@fill:
			lda @new_pixel
			sta vera_data1
			dex
			bne @loop_x

		@break:
		dey
		bne @loop_y
	rts
	.endproc


.proc edit_init_tilemap
	memSet_IMM_24 VRAM_tilemap, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	ldy #32	; 32 loops of 512 = 16K total.
	ldx #0
	@page_loop:
		@word_loop:
			lda #$00
			sta vera_data0
			lda #$00
			;txa
			sta vera_data0
			inx
			bne @word_loop
		dey
		bne @page_loop	
	rts
	.endproc


.proc edit_init_tiledata
	memSet_IMM_24 VRAM_tiledata, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	ldy #4	; 4 loops of 256 = 1K total.
	ldx #0
	@page_loop:
		@byte_loop:
			lda #$00
			sta vera_data0
			inx
			bne @byte_loop
		dey
		bne @page_loop	

	memSet_IMM_24 VRAM_tiledata, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	lda #$00
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0

	lda #$00
	sta vera_data0
	lda #$7e
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	lda #$00
	sta vera_data0

	lda #$ff
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0

	lda #$00
	sta vera_data0
	lda #$7f
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0

	lda #$00
	sta vera_data0
	lda #$fe
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0

	lda #$7f
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	lda #$00
	sta vera_data0

	lda #$fe
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	lda #$00
	sta vera_data0

	lda #$00
	sta vera_data0
	lda #$ff
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0

	lda #$ff
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	sta vera_data0
	lda #$00
	sta vera_data0

	rts
	.endproc


.proc edit_init
    jsr edit_init_tilemap
    jsr edit_init_tiledata
	rts
    .endproc
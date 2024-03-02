;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_VERA_ASM_:
.include "../inc/palette.inc"


.export vera_
vera_:


.export vera_init_sprite 
.proc vera_init_sprite
	; Init the sprites used from the VRAM_mouse sprites.
	; params: id, bpp, height, width, palette_offset
	memSet_IMM_24 VRAM_mouse, ZP24_R0
	jsr sprite_reset

	sprite_init #0, #0, #1, #1, #0	; Mouse
	sprite_init #1, #0, #1, #1, #0	; Cursor
	rts
	.endproc


.export vera_clear_text_line
.proc vera_clear_text_line
	bra @start

		@color:	.byte 0
	@start:
	sta @color
	ldx #128
	@loop:
	stz vera_data0
	lda @color
	sta vera_data0
	dex
	bne @loop
	rts
	.endproc


.export vera_init_text
.proc vera_init_text
	; Copy VRAM textmap location to memory
	memSet_IMM_24 VRAM_textmap, ZP24_R0
	jsr text_init

	memSet_IMM_24 VRAM_textmap, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	; Clear Title bar.
	lda #$b1	;Background color.
	jsr vera_clear_text_line

	; Clear Area Edit area.
	ldy #28
	@loop:
	lda #$01	;Background color.
	jsr vera_clear_text_line
	dey
	bne @loop

	; Clear Status bar bar.
	lda #$b1	;Background color.
	jsr vera_clear_text_line
	rts
	.endproc


.export vera_init_tilemap
.proc vera_init_tilemap
	bra @start

		@color:		.byte 0
	@start:
	; Zero out the mapbase for layer 1:
	; Set the VRAM address VERA will write to.
	memSet_IMM_24 VRAM_tilemap, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	ldy #8	; 8 loops of 512 = 2K entries of 2 bypes per entry (char, color) 4K total.
	ldx #0
	@mapbase_page_loop:
		@mapbase_byte_loop:
			lda #$0
			sta vera_data0
			lda #$0
			sta vera_data0
			inx
			bne @mapbase_byte_loop
		dey
		bne @mapbase_page_loop	

	memSet_IMM_24 VRAM_tilemap, ZP24_R0 
	math_ADD_IMM_24 776, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	ldy #16
	ldx #16
	stz @color
	@mapbase_page_loop2:
		@mapbase_byte_loop2:
			lda #$01
			sta vera_data0
			lda @color
			sta vera_data0
			inc @color
			dex
			bne @mapbase_byte_loop2

		math_ADD_IMM_24 128, ZP24_R0
		mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
		ldx #16
		dey
		bne @mapbase_page_loop2	
	rts
	.endproc


.export vera_init_tiledata
.proc vera_init_tiledata
	memSet_IMM_24 VRAM_tiledata, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	ldx #32
	@mapbase_byte_loop:
		lda #$00
		sta vera_data0
		dex
		bne @mapbase_byte_loop

	lda #$00
	sta vera_data0
	lda #$00
	sta vera_data0

	ldx #14
	@mapbase_byte_loop2:
		lda #$7f
		sta vera_data0
		lda #$fe
		sta vera_data0
		dex
		bne @mapbase_byte_loop2

		stz vera_data0
		stz vera_data0
	rts
	.endproc


.export vera_init_tile
.proc vera_init_tile
	jsr vera_init_tilemap
	jsr vera_init_tiledata
	rts
	.endproc


.export vera_blank 
.proc vera_blank
	stz vera_ctrl
	lda #$01	; VGA mode only, no active layers.
	sta vera_dc_video
	rts
	.endproc


.export vera_init 
.proc vera_init
	; Initialize VERA for layer 1 on in 16 color text mode, 8 by 16 tiles. 
	lda #128
	sta vera_dc_hscale
	sta vera_dc_vscale

	; Layer 1 is on top. Layer 0 is underneath.

	; Zero out the scroll values.
	stz vera_L1_hscroll_l
	stz vera_L1_hscroll_h
	stz vera_L1_vscroll_l
	stz vera_L1_vscroll_h
	stz vera_L0_hscroll_l
	stz vera_L0_hscroll_h
	stz vera_L0_vscroll_l
	stz vera_L0_vscroll_h

	; Layer 1, text layer with 8 by 16 glyphs.
	lda #$20
	sta vera_L1_config
	lda #$f2	; Base address of $1e000 plus 8 x 16 tiles.	
	sta vera_L1_tilebase	; Where the tiles are stored. (Ex: The letters A, B, etc.)
	lda #$e0	; Base address of $1c000
	sta vera_L1_mapbase 	; Where the tile map is stored. (Where on the screen the letters go.)

	; Layer 0, Text layer with 128 x 64 tiles, each 16 x 16 256 color text mode. (16K)
	lda #$18	; Text mode plus 128x64 and 256 color and 1 bpp mode.
	sta vera_L0_config
	lda #$10		; Base address of $02000
	sta vera_L0_mapbase
	lda #$03		; Base address of $00000 plus 16 bit height and width.
	sta vera_L0_tilebase

	lda #$71	; Sprites and Layer 0,1 active plus VGA mode.
	sta vera_dc_video    
	rts
	.endproc

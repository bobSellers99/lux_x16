;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_VERA_ASM_:
.include "../inc/shell.inc"


.export vera_
vera_:

.export vera_blank
.export vera_init


; Init the sprite lib module with this program's interface.
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
;	lda #$20
	stz vera_data0
	lda @color
	sta vera_data0
	dex
	bne @loop
	rts
	.endproc


; Init the text lib module with this program's interface.
.export vera_init_text 
.proc vera_init_text
	; Copy VRAM textmap location to memory
	memSet_IMM_24 VRAM_textmap, ZP24_R0
	jsr text_init
	memSet_IMM_24 VRAM_textmap, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10

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

	; Zero out the scroll values.
	stz vera_L1_hscroll_l
	stz vera_L1_hscroll_h
	stz vera_L1_vscroll_l
	stz vera_L1_vscroll_h

	; Layer 1 is on top. Layer 0 is underneath.
	lda #$20
	sta vera_L1_config
	lda #$f2	; Base address of $1e000 plus 8 x 16 tiles.	
	sta vera_L1_tilebase	; Where the tiles are stored. (Ex: The letters A, B, etc.)
	lda #$e0	; Base address of $1c000
	sta vera_L1_mapbase 	; Where the tile map is stored. (Where on the screen the letters go.)

	lda #$61	; Sprites and Layer 1 active plus VGA mode.
	sta vera_dc_video    

	stz vera_ctrl ; Reset off, data0 selected.
	rts
	.endproc

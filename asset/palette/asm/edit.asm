;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_EDIT_ASM_:
.include "../inc/palette.inc"

.export edit_
.export edit_entry_sze
edit_:

edit_entry_id:      .byte 0
edit_rgb_word:		.word 0
edit_entry_sze:		.res 8 ; 3 chars plus 4 byte overhead / z
edit_entry_temp:	.res 3
palette_r:			.byte 0
palette_g:			.byte 0
palette_b:			.byte 0
palette_cur_color:	.byte $f1
palette_back_color: .byte $f0

edit_entry_def:		.byte "000",0

; 16 color UI palette, palette 0.
palette_init_00: .byte 00,00,00, 15,15,15, 08,00,00, 10,15,15
palette_init_04: .byte 12,04,12, 02,12,04, 00,00,10, 14,14,06
palette_init_08: .byte 13,08,06, 06,04,00, 15,07,07, 03,03,03
palette_init_0c: .byte 07,07,07, 09,15,09, 00,08,15, 11,11,11

; 16 color greyscale palette
palette_init_10: .byte 00,00,00, 01,01,01, 02,02,02, 03,03,03
palette_init_14: .byte 04,04,04, 05,05,05, 06,06,06, 07,07,07
palette_init_18: .byte 08,08,08, 09,09,09, 10,10,10, 11,11,11
palette_init_1c: .byte 12,12,12, 13,13,13, 14,14,14, 15,15,15

; Color set 1
palette_init_20: .byte 02,01,01, 04,03,03, 06,04,04, 08,06,06
palette_init_24: .byte 10,08,08, 12,09,09, 15,11,11, 02,01,01
palette_init_28: .byte 04,02,02, 06,03,03, 08,04,04, 10,05,05
palette_init_2c: .byte 12,06,06, 15,07,07, 02,00,00, 04,01,01

; Color set 2
palette_init_30: .byte 06,01,01, 08,02,02, 10,02,02, 12,03,03
palette_init_34: .byte 15,03,03, 02,00,00, 04,00,00, 06,00,00
palette_init_38: .byte 08,00,00, 10,00,00, 12,00,00, 15,00,00
palette_init_3c: .byte 02,02,01, 04,04,03, 06,06,04, 08,08,06

; Color set 3
palette_init_40: .byte 10,10,08, 12,12,09, 15,14,11, 02,01,01
palette_init_44: .byte 04,03,02, 06,05,03, 08,07,04, 10,09,05
palette_init_48: .byte 12,11,06, 15,13,07, 02,01,00, 04,03,01
palette_init_4c: .byte 06,05,01, 08,06,02, 10,08,02, 12,10,03

; Color set 4
palette_init_50: .byte 15,12,03, 02,01,00, 04,03,00, 06,04,00
palette_init_54: .byte 08,06,00, 10,08,00, 12,09,00, 15,11,00
palette_init_58: .byte 01,02,01, 03,04,03, 05,06,04, 07,08,06
palette_init_5c: .byte 09,10,08, 11,12,09, 13,15,11, 01,02,01

; Color set 5
palette_init_60: .byte 03,04,02, 04,06,03, 06,08,04, 08,10,05
palette_init_64: .byte 09,12,06, 11,15,07, 01,02,00, 02,04,01
palette_init_68: .byte 04,06,01, 05,08,02, 06,10,02, 08,12,03
palette_init_6c: .byte 09,15,03, 01,02,00, 02,04,00, 03,06,00

; Color set 6
palette_init_70: .byte 04,08,00, 05,10,00, 06,12,00, 07,15,00
palette_init_74: .byte 01,02,01, 03,04,03, 04,06,05, 06,08,06
palette_init_78: .byte 08,10,08, 09,12,10, 11,15,12, 01,02,01
palette_init_7c: .byte 02,04,02, 03,06,04, 04,08,05, 05,10,06

; Color set 7
palette_init_80: .byte 06,12,08, 07,15,09, 00,02,00, 01,04,01
palette_init_84: .byte 01,06,02, 02,08,03, 02,10,04, 03,12,05
palette_init_88: .byte 03,15,06, 00,02,00, 00,04,01, 00,06,01
palette_init_8c: .byte 00,08,02, 00,10,02, 00,12,03, 00,15,03

; Color set 8
palette_init_90: .byte 01,02,02, 03,04,04, 04,06,06, 06,08,08
palette_init_94: .byte 08,10,10, 09,12,12, 11,15,15, 01,02,02
palette_init_98: .byte 02,04,04, 03,06,06, 04,08,08, 05,10,10
palette_init_9c: .byte 06,12,12, 07,15,15, 00,02,02, 01,04,04

; Color set 9
palette_init_a0: .byte 01,06,06, 02,08,08, 02,10,10, 03,12,12
palette_init_a4: .byte 03,15,15, 00,02,02, 00,04,04, 00,06,06
palette_init_a8: .byte 00,08,08, 00,10,10, 00,12,12, 00,15,15
palette_init_ac: .byte 01,01,02, 03,03,04, 04,05,06, 06,06,08

; Color set a
palette_init_b0: .byte 08,08,10, 09,10,12, 11,12,15, 01,01,02
palette_init_b4: .byte 02,02,04, 03,04,06, 04,05,08, 05,06,10
palette_init_b8: .byte 06,08,12, 07,09,15, 00,00,02, 01,01,04
palette_init_bc: .byte 01,02,06, 02,03,08, 02,04,10, 03,05,12

; Color set b
palette_init_c0: .byte 03,06,15, 00,00,02, 00,01,04, 00,01,06
palette_init_c4: .byte 00,02,08, 00,02,10, 00,03,12, 00,03,15
palette_init_c8: .byte 01,01,02, 03,03,04, 05,04,06, 07,06,08
palette_init_cc: .byte 09,08,10, 11,09,12, 13,11,15, 01,01,02

; Color set c
palette_init_d0: .byte 03,02,04, 04,03,06, 06,04,08, 08,05,10
palette_init_d4: .byte 09,06,12, 11,07,15, 01,00,02, 02,01,04
palette_init_d8: .byte 04,01,06, 05,02,08, 06,02,10, 08,03,12
palette_init_dc: .byte 09,03,15, 01,00,02, 02,00,04, 03,00,06

; Color set d
palette_init_e0: .byte 04,00,08, 05,00,10, 06,00,12, 07,00,15
palette_init_e4: .byte 02,01,02, 04,03,04, 06,04,06, 08,06,08
palette_init_e8: .byte 10,08,10, 12,09,12, 15,11,14, 02,01,01
palette_init_ec: .byte 04,02,03, 06,03,05, 08,04,07, 10,05,09

; Color set e
palette_init_f0: .byte $c,$6,$b, $f,$7,$d, $2,$0,$1, $4,$1,$3
palette_init_f4: .byte $6,$1,$5, $8,$2,$6, $a,$2,$8, $c,$3,$a
palette_init_f8: .byte $f,$3,$c, $2,$0,$1, $4,$0,$3, $6,$0,$4
palette_init_fc: .byte $8,$0,$6, $a,$0,$8, $c,$0,$9, $f,$0,$b

.export edit_init

palette_set_page:
	; UI colors, index $00 to $0f of the page set
	; by palette_cur_color
	; palette page default address in $40, $41
	ldy #0
	@loop:
	lda ($40),y
	sta palette_r
	iny
	lda ($40),y
	sta palette_g
	iny
	lda ($40),y
	sta palette_b
	iny
	jsr palette_set_index
	inc palette_cur_color
	tya
	cmp #$30
	bne @loop
	rts


set_palette_defaults:
	stz palette_cur_color
	ldx #0
	lda #<palette_init_00
	sta $40
	lda #>palette_init_00
	sta $41

	; Palette indexes $00 to $ff 
	@loop:
	jsr palette_set_page
	math_ADD_IMM_16 48, $40
	inx
	txa
	cmp #$10
	bne @loop

	lda #$f1
	sta palette_cur_color
	lda #$f0
	sta palette_back_color
	rts


palette_set_RGB:
	clc
	lda palette_g
	asl
	asl
	asl
	asl
	adc palette_b
	sta vera_data0
	lda palette_r
	sta vera_data0
	rts


palette_set_index:
	memSet_IMM_24 VRAM_palette, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	; Adjust the palette base for the index.
	; Palette index is 0 to 255. Palette is 2 bytes per index.
	lda palette_cur_color
	sta $44
	stz $45
	mathShiftUp_16 #1, $44
	vera_ADD_OFFSET_16 $44
	
	memSet_IMM_24 VRAM_palette, ZP24_R0
	math_ADD_16_24 $44, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	jsr palette_set_RGB
	rts


.proc edit_entry_callback
	if_case_else #CTL_STATE_OVER
		textStringEdit #edit_entry_sze ,#$b7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textStringEdit #edit_entry_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_NORMAL
		textStringEdit #edit_entry_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr edit_name_mouse_left
		rts

:	if_case_else #CTL_KEY_INPUT
		lda ctl_focus
		cmp edit_entry_id
		bne :+
		jsr ctl_edit_process
		jsr edit_set_palette_entry		
:		rts
	.endproc


.proc edit_name_mouse_left
	ctlEditBegin #edit_entry_sze
	rts
	.endproc


.export edit_set_palette_entry
.proc edit_set_palette_entry
	bra @start

		@index:	.word 0
		@r:		.byte 0
		@g:		.byte 0
		@b:		.byte 0
		@pal_0:	.byte 0
		@pal_1:	.byte 0
	@start:

	szEditGetAddr #edit_entry_sze, zp_ind
	ldy #0
	lda (zp_ind),y
	szCharToBin
	sta @r
	iny
	lda (zp_ind),y
	szCharToBin
	sta @g
	iny
	lda (zp_ind),y
	szCharToBin
	sta @b
	mathShiftUp_8 #4, @g
	lda @g
	ora @b
	sta @pal_0
	lda @r
	sta @pal_1

	lda area_selected
	sta @index
	stz @index+1
	mathShiftUp_16 #1, @index
	memSet_IMM_24 VRAM_palette, ZP24_R0
	math_ADD_16_24 @index, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	lda @pal_0
	sta vera_data0
	lda @pal_1
	sta vera_data0
	rts
	.endproc


.proc edit_init
; 	jsr set_palette_defaults
	szEditInit #edit_entry_sze, #3, #3, #55, #10, #edit_entry_def
    ctlCreate #(55*8), #(10*16), #(3*8), #16, #edit_entry_callback
    sta edit_entry_id
    rts
    .endproc
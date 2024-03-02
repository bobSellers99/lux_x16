;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_DATA_ASM_:
.include "../inc/sprite.inc"

.export data_
data_:

data_name_id:		.byte 0
data_name_sze:		.res 37 ; 32 chars max plus 4 byte overhead and null
data_name_def:		.byte "/bin/lux/us_ascii.key",0
;data_str_name:		.res 33

data_str_file:		.byte "File:",0
data_str_load:		.byte " Load ",0
data_str_save:		.byte " Save ",0

keymap_normal:
;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
.byte $00,$60,$31,$32,$33,$34,$35,$36,$37,$38,$39,$30,$2d,$3d,$00,$08   ;0
.byte $09,$71,$77,$65,$72,$74,$79,$75,$69,$6f,$70,$5b,$5d,$5c,$00,$61   ;1
.byte $73,$64,$66,$67,$68,$6a,$6b,$6c,$3b,$27,$00,$0d,$00,$00,$7a,$78   ;2
.byte $63,$76,$62,$6e,$6d,$2c,$2e,$2f,$00,$00,$00,$00,$00,$20,$00,$00   ;3
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$00,$00,$80   ;4
.byte $84,$85,$00,$82,$83,$86,$87,$00,$00,$81,$00,$37,$34,$31,$00,$2f   ;5
.byte $38,$35,$32,$30,$2a,$39,$36,$33,$2e,$2d,$2b,$00,$0d,$00,$1b,$00   ;6
.byte $90,$91,$92,$93,$94,$95,$96,$97,$00,$00,$00,$00,$00,$00,$00,$00   ;7

keymap_normal_shift:
;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
.byte $00,$7e,$21,$40,$23,$24,$25,$5e,$26,$2a,$28,$29,$5f,$2b,$00,$08   ;0
.byte $09,$51,$57,$45,$52,$54,$59,$55,$49,$4f,$50,$7b,$7d,$7c,$00,$41   ;1
.byte $53,$44,$46,$47,$48,$4a,$4b,$4c,$3a,$22,$00,$0d,$00,$00,$5a,$58   ;2
.byte $43,$56,$42,$4e,$4d,$3c,$3e,$3f,$00,$00,$00,$00,$00,$20,$00,$00   ;3
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$00,$00,$80   ;4
.byte $84,$85,$00,$82,$83,$86,$87,$00,$00,$81,$00,$37,$34,$31,$00,$2f   ;5
.byte $38,$35,$32,$30,$2a,$39,$36,$33,$2e,$2d,$2b,$00,$0d,$00,$1b,$00   ;6
.byte $90,$91,$92,$93,$94,$95,$96,$97,$00,$00,$00,$00,$00,$00,$00,$00   ;7

keymap_normal_alt:
;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
.byte 000,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9,$aa,$ab,$ac,000,000   ;0
.byte 000,$ad,$ae,$af,$b0,$b1,$b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9,000,$ba   ;1
.byte $bb,$bc,$bd,$be,$bf,$c0,$c1,$c2,$c3,$c4,000,000,000,000,$c5,$c6   ;2
.byte $c7,$c8,$c9,$ca,$cb,$cc,$cd,$ce,000,000,000,000,000,000,000,000   ;3
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;4
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;5
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;6
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;7

keymap_normal_ctl:
;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
.byte 000,$d0,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$da,$db,$dc,000,000   ;0
.byte 000,$dd,$de,$df,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7,$e8,$e9,000,$ea   ;1
.byte $eb,$ec,$ed,$ee,$ef,$f0,$f1,$f2,$f3,$f4,000,000,000,000,$f5,$f6   ;2
.byte $f7,$f8,$f9,$fa,$fb,$fc,$fd,$fe,000,000,000,000,000,000,000,000   ;3
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;4
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;5
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;6
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;7

keymap_caplock:
;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
.byte $00,$60,$31,$32,$33,$34,$35,$36,$37,$38,$39,$30,$2d,$3d,$00,$08   ;0
.byte $09,$71,$77,$65,$72,$74,$79,$75,$69,$6f,$70,$5b,$5d,$5c,$00,$61   ;1
.byte $73,$64,$66,$67,$68,$6a,$6b,$6c,$3b,$27,$00,$0d,$00,$00,$7a,$78   ;2
.byte $63,$76,$62,$6e,$6d,$2c,$2e,$2f,$00,$00,$00,$00,$00,$20,$00,$00   ;3
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$00,$00,$80   ;4
.byte $84,$85,$00,$82,$83,$86,$87,$00,$00,$81,$00,$37,$34,$31,$00,$2f   ;5
.byte $38,$35,$32,$30,$2a,$39,$36,$33,$2e,$2d,$2b,$00,$0d,$00,$1b,$00   ;6
.byte $90,$91,$92,$93,$94,$95,$96,$97,$00,$00,$00,$00,$00,$00,$00,$00   ;7

keymap_caplock_shift:
;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
.byte $00,$7e,$21,$40,$23,$24,$25,$5e,$26,$2a,$28,$29,$5f,$2b,$00,$08   ;0
.byte $09,$51,$57,$45,$52,$54,$59,$55,$49,$4f,$50,$7b,$7d,$7c,$00,$41   ;1
.byte $53,$44,$46,$47,$48,$4a,$4b,$4c,$3a,$22,$00,$0d,$00,$00,$5a,$58   ;2
.byte $43,$56,$42,$4e,$4d,$3c,$3e,$3f,$00,$00,$00,$00,$00,$20,$00,$00   ;3
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$00,$00,$80   ;4
.byte $84,$85,$00,$82,$83,$86,$87,$00,$00,$81,$00,$37,$34,$31,$00,$2f   ;5
.byte $38,$35,$32,$30,$2a,$39,$36,$33,$2e,$2d,$2b,$00,$0d,$00,$1b,$00   ;6
.byte $90,$91,$92,$93,$94,$95,$96,$97,$00,$00,$00,$00,$00,$00,$00,$00   ;7

keymap_caplock_alt:
;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;0
.byte 000,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9,$aa,000,000,000,000   ;1
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;2
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;3
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;4
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;5
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;6
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;7

keymap_caplock_ctl:
;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;0
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;1
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;2
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;3
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;4
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;5
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;6
.byte 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,000   ;7


.export data_name_mouse_left 
.proc data_name_mouse_left
	ctlEditBegin #data_name_sze
	rts
	.endproc


.export data_name_callback 
.proc data_name_callback
	if_case_else #CTL_STATE_OVER
		textStringEdit #data_name_sze ,#$b7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textStringEdit #data_name_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_NORMAL
		textStringEdit #data_name_sze ,#$b1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr data_name_mouse_left
		rts

:	if_case_else #CTL_KEY_INPUT
		lda ctl_focus
		cmp data_name_id
		bne :+
		jsr ctl_edit_process
:		rts
	.endproc


.export data_load_file 
.proc data_load_file
	@filename		= zp_ind

	; TODO Checks like this (String cannot be zero length.) need to be in the bios
	szEditGetAddr #data_name_sze, @filename	
	szLength @filename
	beq @return

	fileLoad @filename, #keymap_normal, #0, #$00

	@return:
	rts
	.endproc


.export data_load_mouse_left 
.proc data_load_mouse_left
	stz mouse_btns

	jsr data_load_file

	@return:
	rts
	.endproc


.export data_load_callback 
.proc data_load_callback
	if_case_else #CTL_STATE_OVER
		textString #40, #29 ,#data_str_load ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #40, #29 ,#data_str_load ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #40, #29 ,#data_str_load ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr data_load_mouse_left
:		rts
	.endproc


.export data_save_file 
.proc data_save_file
	@filename		= zp_ind

	; TODO Checks like this (String cannot be zero length.) need to be in the bios
	szEditGetAddr #data_name_sze, @filename	
	szLength @filename
	beq @return

	fileSave @filename, #keymap_normal, #$0400, #$00

	@return:
	rts
	.endproc


.export data_save_mouse_left 
.proc data_save_mouse_left
	stz mouse_btns

	jsr data_save_file
	
	@return:
	rts
	.endproc


.export data_save_callback 
.proc data_save_callback
	if_case_else #CTL_STATE_OVER
		textString #48, #29 ,#data_str_save ,#$c7
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #48, #29 ,#data_str_save ,#$bc
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #48, #29 ,#data_str_save ,#$c1
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr data_save_mouse_left
:		rts
	.endproc


.export data_init
.proc data_init
	textString #0, #29 ,#data_str_file ,#$b5
	szEditInit #data_name_sze, #32, #11, #6, #29, #data_name_def
    ctlCreate #(6*8), #(29*16), #(32*8), #16, #data_name_callback
	sta data_name_id

	ctlCreate #(40*8), #(29*16), #(6*8), #16, #data_load_callback
	ctlCreate #(48*8), #(29*16), #(6*8), #16, #data_save_callback
    rts
    .endproc

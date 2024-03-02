;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.include "../../../lib/inc/zeropage.inc"


_PS2_KEYBOARD_ASM_:

key_shift			= $bf00
key_shift_lock		= $bf01	; TODO Not implemented.
key_ctl				= $bf02
key_alt				= $bf03


ascii_norm			= $ac00
ascii_norm_shift	= $ac80
ascii_norm_alt		= $ad00
ascii_norm_ctl		= $ad80
ascii_lock			= $ac00
ascii_lock_shift	= $ac80
ascii_lock_alt		= $ad00
ascii_lock_ctl		= $ad80


; Scan code mapping:
;alphanumeric keys:	$01 to $40
;Navigation keys:	$4b to $59
;Numeric keypad:	$5a to $6d
;Function keys:		$6e to $7b

.export sys_ascii_key
.proc sys_ascii_key
;	@translate:
	; translate scan code
	tay
	lda key_ctl
	bne @control
	lda key_alt
	bne @alt
	lda key_shift
	bne @shifted
	lda #<ascii_norm
	sta zp_ind
	lda #>ascii_norm
	sta zp_ind+1
	bra @continue

	@shifted:
	lda #<ascii_norm_shift
	sta zp_ind
	lda #>ascii_norm_shift
	sta zp_ind+1
	bra @continue

	@control:
	lda #<ascii_norm_ctl
	sta zp_ind
	lda #>ascii_norm_ctl
	sta zp_ind+1
	bra @continue

	@alt:
	lda #<ascii_norm_alt
	sta zp_ind
	lda #>ascii_norm_alt
	sta zp_ind+1
	bra @continue

	@continue:
	lda (zp_ind),y
    sta kyb_ascii
	rts
	.endproc


.export sys_translate_key
.proc sys_translate_key
    pha
	phy
    sta scan_code

    and #$ff    ;ensure A sets flags
  
	cmp #$ac
	beq @reset_shift
	cmp #$2c
	beq @set_shift
	cmp #$b9
	beq @reset_shift
	cmp #$39
	beq @set_shift

	cmp #$ba
	beq @reset_control
	cmp #$3a
	beq @set_control
	cmp #$c0
	beq @reset_control
	cmp #$40
	beq @set_control

	cmp #$bc
	beq @reset_alt
	cmp #$3c
	beq @set_alt
	cmp #$be
	beq @reset_alt
	cmp #$3e
	beq @set_alt

    and #$ff    ;ensure A sets flags
    bmi @exit    ;A & 0x80 is key up

;	bra @translate
	jsr sys_ascii_key

	; Shift key
	@reset_shift:
	stz key_shift
	bra @exit
	@set_shift:
	lda #01
	sta key_shift
	bra @exit

	; Control key
	@reset_control:
	stz key_ctl
	bra @exit
	@set_control:
	lda #01
	sta key_ctl
	bra @exit

	; Alt key
	@reset_alt:
	stz key_alt
	bra @exit
	@set_alt:
	lda #01
	sta key_alt
	bra @exit

	@exit:
    ply
	pla
    lda #0
	rts
   .endproc 

;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02
.include "../../../lib/inc/zeropage.inc"
.include "../inc/i2c.inc"

_PS2_MOUSE_ASM_:

.export check_mouse_pos
.proc check_mouse_pos
	stz $02f9
	stz $02fa

	; Check for less than 0.
	lda mouse_x+1
	bmi @reset_xl
	lda mouse_y+1
	bmi @reset_yl

	; Check for > than 639/479
	sec
	lda mouse_x
	sbc #$7f
	lda mouse_x+1
	sbc #$02
	bpl @reset_xh

	sec
	lda mouse_y
	sbc #$df
	lda mouse_y+1
	sbc #$01
	bpl @reset_yh
	rts

	@reset_xl:
	stz mouse_x
	stz mouse_x+1
	rts

	@reset_yl:
	stz mouse_y
	stz mouse_y+1
	rts

	@reset_xh:
	lda #$7f
	sta mouse_x
	lda #$02
	sta mouse_x+1
	rts

	@reset_yh:
	lda #$df
	sta mouse_y
	lda #$01
	sta mouse_y+1
	rts
    .endproc


.export sys_update_mouse
.proc sys_update_mouse
	ldx #I2C_ADDRESS
	ldy #I2C_GET_MOUSE_MOVEMENT_OFFSET
	jsr i2c_read_first_byte
	beq @return
	sta $02f8
	jsr i2c_read_next_byte
	sta $02f9
	jsr i2c_read_next_byte
	sta $02fa

	@return:
	jsr i2c_read_stop       ; Stop I2C transfer

	lda $02f8
	sta mouse_btns
	lda $02f9
	bpl @x2
	bmi @x3

	@x2:
	clc
	lda mouse_x
	adc $02f9
	sta mouse_x
	lda mouse_x+1
	adc #0
	sta mouse_x+1
	bra @do_y

	@x3:
	lda $02f9
	eor #$ff
	inc
	sta $02f9
	sec
	lda mouse_x
	sbc $02f9
	sta mouse_x
	lda mouse_x+1
	sbc #0
	sta mouse_x+1

	@do_y:
	lda $02fa
	bpl @y3
	bmi @y2

	@y3:
	sec
	lda mouse_y
	sbc $02fa
	sta mouse_y
	lda mouse_y+1
	sbc #0
	sta mouse_y+1
	bra @done

	@y2:
	lda $02fa
	eor #$ff
	inc
	sta $02fa
	clc
	lda mouse_y
	adc $02fa
	sta mouse_y
	lda mouse_y+1
	adc #0
	sta mouse_y+1

	@done:
	jsr check_mouse_pos
	rts
    .endproc

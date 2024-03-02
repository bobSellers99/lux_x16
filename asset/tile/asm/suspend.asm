;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_SUSPEND_ASM_:
.include "../inc/main.inc"

.segment "DATA"

.export data_end
data_end:

.segment "CODE"

suspend_fn:			.byte "tile_data",0
suspend_crc:		.word 0

.export suspend_get_crc
.proc suspend_get_crc

	memSet_16_16 #data_start, zp_ind
	ldy #2
	memSet_16_16 #0, data_crc
	@add_to_crc:
		lda (zp_ind),y
		math_ADD_A_16 data_crc
		iny
		bne @check_end
		inc zp_ind+1

	@check_end:
	phy
	plx
	cpx #<data_end
	bne @add_to_crc
	ldx zp_ind+1
	cpx #>data_end
	bne @add_to_crc		

	rts
	.endproc


.export suspend_clear
.proc suspend_clear
	memSet_16_16 #suspend_fn, fat32_ptr 
	jsr file_delete
	rts
	.endproc


.export suspend_save
.proc suspend_save
	memSet_16_16 #application_key, data_key
	jsr suspend_get_crc
	fileSave #suspend_fn, #data_start, #$100, #0
	rts
	.endproc


.export suspend_load
.proc suspend_load
	fileLoad #suspend_fn, #data_start, #0, #0
	memSet_16_16 data_crc, suspend_crc
	jsr suspend_get_crc

	; Check the crc
	lda data_crc
	cmp suspend_crc
	bne @init

	lda data_crc+1
	cmp suspend_crc+1
	bne @init

	; Check the application key.
	lda #<application_key
	cmp data_key
	bne @init

	lda #>application_key
	cmp data_key+1
	bne @init

	bra @return

	@init:
	jsr suspend_init

	@return:
	rts
	.endproc


.export suspend_init
.proc suspend_init
	memSet_16_16 #data_start, zp_ind
	ldy #0
	lda #0
	@clear_loop:
		sta (zp_ind),y
		iny
		bne @check_end
		inc zp_ind+1

	@check_end:
	phy
	plx
	cpx #<data_end
	bne @clear_loop
	ldx zp_ind+1
	cpx #>data_end
	bne @clear_loop		

	jsr area_data_init
	jsr data_data_init

	rts
	.endproc
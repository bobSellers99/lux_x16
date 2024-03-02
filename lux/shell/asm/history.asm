;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_HISTORY_ASM_:
.include "../inc/shell.inc"

.export history_cur
.export history_pos

history_cur:    .byte 0
history_max:    .byte 10
history_fn:     .byte "/bin/lux/history",0
history_pos:	.res 3


.export history_save
.proc history_save
	; Open VERA_data0 to point to data location.
	memSet_IMM_24 VRAM_history, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	fileSave #history_fn, #vera_data0, #$400, #$80
	rts
	.endproc


.export history_load
.proc history_load
	; Open VERA_data0 to point to data location.
	memSet_IMM_24 VRAM_history, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	fileLoad #history_fn, #vera_data0, #0, #$80
	rts
	.endproc


.export history_clear
.proc history_clear
	memSet_IMM_24 VRAM_history, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	ldy #4 ; 4 x 256 bytes = 1K
	ldx #0
	@loop_y:
		@loop_x:
			lda #0
			sta vera_data0
			dex
			bne @loop_x

		dey
		bne @loop_y
	rts
    .endproc


.export history_reset
.proc history_reset
	stz history_cur
	memSet_IMM_24 VRAM_history, history_pos 
	rts
	.endproc


.export history_add_top
.proc history_add_top
    bra @start

        @length:    .byte 0
    @start:
	; Get length of new command line.
    szLength #lux_cmd_str
    inc		; Include null terminator.
    sta @length

	memSet_IMM_24 VRAM_history, ZP24_R0 
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1

	ldx #0
	@copy:
		lda lux_cmd_str,x
		sta vera_data0
		inx
		dec @length
		lda @length
		bne @copy

	stz history_cur

	rts
	.endproc


.export history_swap
.proc history_swap
	; Go back to the previous history element (The one to swap to the top.)
;	jsr history_set_last

	; That history entry is already in the lux_cmd_buf, so it's saved.

	; Starting from the top of the buffer, set the 

	rts
	.endproc


.export history_scroll
.proc history_scroll
    bra @start

        @length:    .byte 0
		@copy_size:	.word 0
    @start:
	; Get length of new command line.
    szLength #lux_cmd_str
    inc		; Include null terminator.
    sta @length

	; Addr 0 is the read address.
	memSet_IMM_24 VRAM_history, ZP24_R0 
	math_ADD_IMM_24 $3ff, ZP24_R0
	math_SUB_8_24 @length, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $18	; Addr0, stride -1

	; Addr 1 is the write address.
	memSet_IMM_24 VRAM_history, ZP24_R0 
	math_ADD_IMM_24 $3ff, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 1, $18	; Addr1, stride -1

	; Total length to copy is (1K-1) - @length
    mem_SET_IMM_16 $400, @copy_size
	math_SUB_8_16 @length, @copy_size
	@move:
		lda vera_data0
		sta vera_data1
		math_DEC_16 @copy_size
		lda @copy_size
		bne @move
		lda @copy_size+1
		bne @move

	; Set final byte to 0.
	memSet_IMM_24 VRAM_history, ZP24_R0 
	math_ADD_IMM_24 $3ff, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $00	; Addr0, stride 0
	stz vera_data0
	rts
	.endproc


.export history_get_next
.proc history_get_next
	mem_SET_VRAM_ADDR history_pos, 0, $00	; Addr0, stride 0
	@copy:
		lda vera_data0
		beq @copy_done
		sta edit_cur_char
		jsr edit_insert

		math_INC_24 history_pos
		mem_SET_VRAM_ADDR history_pos, 0, $00	; Addr0, stride 0
		bra @copy

	@copy_done:
	math_INC_24 history_pos
	inc history_cur
	rts
	.endproc


.export history_set_last
.proc history_set_last
	math_DEC_24 history_pos
	math_DEC_24 history_pos
	mem_SET_VRAM_ADDR history_pos, 0, $00	; Addr0, stride 0
	@go_back:
		lda vera_data0
		beq @go_back_done
		math_DEC_24 history_pos
		if_16_eq_IMM history_pos, VRAM_history
			math_DEC_24 history_pos
			bra @go_back_done

	:	mem_SET_VRAM_ADDR history_pos, 0, $00	; Addr0, stride 0
		bra @go_back

	@go_back_done:
	math_INC_24 history_pos
	dec history_cur
	rts
	.endproc


.export history_up_arrow
.proc history_up_arrow
	; Don't go beyond end of buffer.
	lda history_cur
	cmp history_max
	bne @continue
	rts

	@continue:
	jsr term_init_cmd
	jsr history_get_next
	rts
	.endproc


.export history_down_arrow
.proc history_down_arrow
	; Don't go above beginning of buffer.
	lda history_cur
	bne @continue
	rts

	@continue:
	jsr term_init_cmd
	jsr history_set_last
	lda history_cur
	beq @return

	jsr history_set_last
	jsr history_get_next

	@return:
	rts
	.endproc


.export history_add
.proc history_add
	; Don't add if history_cur is non-zero.
	lda history_cur
	beq @add

	; Otherwise, swap current to top.
	jsr history_swap
	rts

	@add:
	jsr history_scroll
	jsr history_add_top
	rts
    .endproc


.export history_init
.proc history_init
	stz history_cur
	memSet_IMM_24 VRAM_history, history_pos 
	jsr history_clear
	jsr history_load
	rts
	.endproc
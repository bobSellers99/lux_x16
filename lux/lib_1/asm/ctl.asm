;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.export _CTL_ASM_
_CTL_ASM_:
.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/defines.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/math.inc"
.include "../../../lib/inc/if.inc"
.include "../../../lib/inc/ctl.inc"
.include "../../../lib/inc/text.inc"



.export ctl_
;.export ctl_cur_over
;.export ctl_debug_last_state
;.export ctl_debug_last_ctl
.export ctl_data

NUM_CTLS = 32
CTL_SIZE = 16

ctl_:
ctl_cur_over:			.byte 0
ctl_debug_last_state:	.byte 0
ctl_debug_last_ctl:		.byte 0

ctl_data:				.res CTL_SIZE*NUM_CTLS


.export ctl_jump_abs_ind 
.proc ctl_jump_abs_ind
	@index			= r0L
	
	pha
	ldy @index
	lda (zp_ind),y
	sta zp_ind2
	iny
	lda (zp_ind),y
	sta zp_ind2+1

	pla
	jmp (zp_ind2)
	rts
	.endproc


; A is the return. '0' is "Nope!" '1' is "Mouse is in the box!"
.export ctl_is_mouse_over_cur_ctl 
.proc ctl_is_mouse_over_cur_ctl
	bra @start
		@screen_x:		.word 0
		@screen_y:		.word 0
		@width:			.word 0
		@height:		.word 0

		@result:		.word 0

	@start:
	mem_SET_IND_16 ctl_loop, #ctl::loc_x, @screen_x
	mem_SET_IND_16 ctl_loop, #ctl::loc_y, @screen_y
	mem_SET_IND_16 ctl_loop, #ctl::width, @width
	mem_SET_IND_16 ctl_loop, #ctl::height, @height

	; Check mouse_x < left, if plus, continue.
	memSet_16_16 mouse_x, @result
	math_SUB_16_16 @screen_x, @result
	bpl @check_top
	lda #0
	rts

	@check_top:
	; Check mouse_y < top, if minus, return 0.
	memSet_16_16 mouse_y, @result
	math_SUB_16_16 @screen_y, @result
	bpl @check_right
	lda #0
	rts

	@check_right:
	; Check mouse_x > (left + width), if plus, return 0.
	math_ADD_16_16 @width, @screen_x
	memSet_16_16 mouse_x, @result
	math_SUB_16_16 @screen_x, @result
	bmi @check_bottom
	lda #0
	rts

	@check_bottom:
	; Check mouse_y > (top + height), if plus, return 0.
	math_ADD_16_16 @height, @screen_y
	memSet_16_16 mouse_y, @result
	math_SUB_16_16 @screen_y, @result
	bmi @return_yes
	lda #0
	rts

	@return_yes:
	lda ctl_index
	sta ctl_cur_over
	lda #1
	rts
	.endproc


.export ctl_normal 
.proc ctl_normal
	lda ctl_cur_over
	cmp ctl_index
	bne @return

	lda #CTL_STATE_OVER
	ldy #ctl::state
	sta (ctl_loop),y
	ctlJumpAbsInd ctl_loop, #ctl::callback, #CTL_STATE_OVER

	@return:
	rts
	.endproc


.export ctl_over 
.proc ctl_over
	lda ctl_cur_over
	cmp ctl_index
	beq @check_mouse

	; Mouse is no longer over this control! Reset it back to normal.
	lda #CTL_STATE_NORMAL
	ldy #ctl::state
	sta (ctl_loop),y
	ctlJumpAbsInd ctl_loop, #ctl::callback, #CTL_STATE_NORMAL
	rts

	@check_mouse:
	lda mouse_btns
	beq @return

	lda #CTL_STATE_PRESSED
	ldy #ctl::state
	sta (ctl_loop),y
	ctlJumpAbsInd ctl_loop, #ctl::callback, #CTL_STATE_PRESSED

	@return:
	rts
	.endproc


.export ctl_pressed
.proc ctl_pressed
	lda ctl_cur_over
	cmp ctl_index
	beq @check_mouse

	; Mouse is no longer over this control! Reset it back to normal.
	lda #CTL_STATE_NORMAL
	ldy #ctl::state
	sta (ctl_loop),y
	ctlJumpAbsInd ctl_loop, #ctl::callback, #CTL_STATE_NORMAL
	rts

	@check_mouse:
	lda mouse_btns
	bne @return
	
	lda #CTL_STATE_RELEASE
	ldy #ctl::state
	sta (ctl_loop),y
	ctlJumpAbsInd ctl_loop, #ctl::callback, #CTL_STATE_RELEASE

	@return:
	rts
	.endproc


.export ctl_release 
.proc ctl_release
	lda #CTL_STATE_NORMAL
	ldy #ctl::state
	sta (ctl_loop),y
	ctlJumpAbsInd ctl_loop, #ctl::callback, #CTL_STATE_NORMAL
	rts
	.endproc


.export ctl_process_focus 
.proc ctl_process_focus
	lda ctl_focus
	beq @return

	sta ctl_addr
	stz ctl_addr+1
	mathShiftUp_16 #4, ctl_addr
	math_ADD_IMM_16 ctl_data, ctl_addr	; ctl_addr now holds the base address for the focus data

	ctlJumpAbsInd ctl_addr, #ctl::callback, #CTL_KEY_INPUT

	@return:
	rts
	.endproc


.export ctl_process 
.proc ctl_process
	lda mouse_btns
	and #$07
	sta mouse_btns
	stz ctl_cur_over
	stz ctl_debug_last_ctl
	stz ctl_debug_last_state

	stz ctl_index
	memSet_16_16 #ctl_data, ctl_loop	; ctl_loop now holds the base address ctl 0.

	@loop:
		inc ctl_index
		lda ctl_index
		cmp #NUM_CTLS
		beq @return

		; Advance the pointer to the current control to match ctl_index.
		math_ADD_IMM_16 16, ctl_loop
	
		; If this control's state is unset, continue the loop.
		ldy #ctl::state
		lda (ctl_loop),y
		beq @loop

		; Test to see if the mouse is over a control. If it is, ctl_cur_over
		; will be set to the control's id. 
		jsr ctl_is_mouse_over_cur_ctl

		; Process the control's state.
		ldy #ctl::state
		lda (ctl_loop),y

		cmp #CTL_STATE_NORMAL
		beq @normal

		cmp #CTL_STATE_OVER
		beq @over

		cmp #CTL_STATE_PRESSED
		beq @pressed

		cmp #CTL_STATE_RELEASE
		beq @release

		; Continue the loop if the mouse is not over this control.
		beq @loop

	@normal:
	jsr ctl_normal
	bra @loop

	@over:
	jsr ctl_over
	bra @loop

	@pressed:
	jsr ctl_pressed
	bra @loop

	@release:
	jsr ctl_release
	bra @loop

	@return:
	jsr ctl_process_focus
	rts
	.endproc


.export ctl_set_state 
.proc ctl_set_state
	;A holds the ctl id
	;X holds the state to set.	
	sta zp_ind
	stz zp_ind+1
	mathShiftUp_16 #4, zp_ind
	math_ADD_IMM_16 ctl_data, zp_ind
	ldy #ctl::state
	txa
	sta (zp_ind),y
	rts
	.endproc


.export ctl_get_free_entry 
.proc ctl_get_free_entry
	bra @start

		@index:			.byte 0
		@ctl_addr:		.word 0
	@start:
	lda #1
	sta @index

	@loop:
	; Get the base address for the control.
	sta @ctl_addr
	stz @ctl_addr+1
	mathShiftUp_16 #4, @ctl_addr
	math_ADD_IMM_16 ctl_data, @ctl_addr

	; Load the State param into A.
	mem_GET_IND_IDX_A @ctl_addr, #ctl::state
	
	; We're done if the State param is zero.
	beq @return
	inc @index
	lda @index
	cmp #NUM_CTLS
	bne @loop
	lda #0
	rts

	@return:
	lda @index
	rts
	.endproc


.export ctl_delete 
.proc ctl_delete
	; A holds the ctl_id to delete.
	@ctl_addr		= zp_ind

	and #$ff
	beq @return	; Guard block if ctl_id is zero.

	sta @ctl_addr
	stz @ctl_addr+1
	mathShiftUp_16 #4, @ctl_addr
	math_ADD_IMM_16 ctl_data, @ctl_addr

	ldy #0
	@loop:
	lda #0
	sta (@ctl_addr),y
	iny
	cpy #$16
	bne @loop

	@return:
	rts
	.endproc


.export ctl_create 
.proc ctl_create
	; On exit, A holds the index of the new control or 0 if none created.	
	@loc_x			= r0
	@loc_y			= r1
	@width			= r2
	@height			= r3
	@draw			= r4

	bra @start
		@index:			.byte 0
	@start:
	; Compute offset from ctl_data and place in ctl_cur_data 
	jsr ctl_get_free_entry
	sta @index
	bne @continue
	lda #0
	rts		; Exit if there was no empty entry to use.

	@continue:
	sta ctl_addr
	stz ctl_addr+1
	mathShiftUp_16 #4, ctl_addr
	math_ADD_IMM_16 ctl_data, ctl_addr	; ctl_addr now holds the base address for the cur data

	mem_SET_16_IND @loc_x, ctl_addr, #ctl::loc_x
	mem_SET_16_IND @loc_y, ctl_addr, #ctl::loc_y
	mem_SET_16_IND @width, ctl_addr, #ctl::width
	mem_SET_16_IND @height, ctl_addr, #ctl::height
	mem_SET_16_IND @draw, ctl_addr, #ctl::callback

	; Set index and initial state.
	stz mouse_btns
	lda @index
	ldy #ctl::index
	sta (ctl_addr),y

	lda #CTL_STATE_NORMAL
	sta ctl_state
	ldy #ctl::state
	sta (ctl_addr),y
	ctlJumpAbsInd ctl_addr, #ctl::callback, #CTL_STATE_NORMAL

	lda @index
	rts
	.endproc


	.export ctl_init 
	.proc ctl_init
		stz ctl_cur_over
		stz ctl_debug_last_state
		stz ctl_debug_last_ctl
	
		; Clear the control array.
		memSet_16_16 #ctl_data, zp_ind
		ldx #2
		ldy #0
		@clear_loop_x:
			@clear_loop_y:
				lda #$0
				sta (zp_ind),y
				iny
				bne @clear_loop_y

			math_ADD_IMM_16 $100, zp_ind
			dex
			bne @clear_loop_x

		stz ctl_focus
		rts
		.endproc


	.export ctl_debug
	.proc ctl_debug
		mathBinToBcd_8 ctl_debug_last_state
		textBcd_16 #30, #0, #3, #$b1

		mathBinToBcd_8 ctl_debug_last_ctl
		textBcd_16 #34, #0, #3, #$b1
	
		mathBinToBcd_8 ctl_focus
		textBcd_8 #39, #0, #2, #$b1

		mathBinToBcd_8 ctl_index
		textBcd_8 #42, #0, #2, #$b1

		mathBinToBcd_8 ctl_cur_over
		textBcd_8 #45, #0, #2, #$b1
		rts
		.endproc	
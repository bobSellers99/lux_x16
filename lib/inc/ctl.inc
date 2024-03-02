;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

.struct ctl
	index		.byte
	state		.byte
	loc_x		.word
	loc_y		.word
	width		.word
	height		.word
	callback	.word
	extra		.res 4
	.endstruct

CTL_MOUSE_LEFT 		= 1
CTL_MOUSE_RIGHT 	= 2
CTL_MOUSE_BOTH		= 3
CTL_MOUSE_MIDDLE 	= 4
CTL_MOUSE_SCROLL_UP = 5
CTL_MOUSE_SCROLL_DN = 6
CTL_KEY_INPUT		= 7

CTL_KEY_ESCAPE 		= 32
CTL_KEY_ENTER	 	= 33

CTL_STATE_DISABLED 	= 51
CTL_STATE_NORMAL 	= 52
CTL_STATE_OVER 		= 53
CTL_STATE_PRESSED 	= 54
CTL_STATE_RELEASE 	= 55


.macro ctlJumpAbsInd addr, index, param
	memSet_16_16 addr, zp_ind
	lda index
	sta r0L
	lda param
	jsr ctl_jump_abs_ind
	.endmacro


.ifndef _CTL_ASM_

ctl_process			= $9c00
ctl_set_state		= $9c03
ctl_delete			= $9c06
ctl_create			= $9c09
ctl_init			= $9c0c
ctl_jump_abs_ind	= $9c0f
ctl_debug			= $9c12

;.macro ctl_GET_PARAM_ADDR control_index, param_index, dest_addr
;	lda control_index
;	sta ctl_get_param+2
;	lda param_index
;	sta ctl_get_param+3
;	mem_SET_IMM_16 dest_addr, ctl_get_param+4
;	jsr ctl_get_param
;	.endmacro


.macro ctlCreate loc_x, loc_y, width, height, callback
	memSet_16_16 loc_x, r0
	memSet_16_16 loc_y, r1
	memSet_16_16 width, r2
	memSet_16_16 height, r3
	memSet_16_16 callback, r4
	jsr ctl_create
	.endmacro


;.macro ctl_CREATE_IND loc_x, loc_y, width, height, callback
;	mem_SET_16_16 loc_x, ctl_create+2
;	mem_SET_16_16 loc_y, ctl_create+4
;	mem_SET_16_16 width, ctl_create+6
;	mem_SET_16_16 height, ctl_create+8
;	mem_SET_IMM_16 callback, ctl_create+10
;	jsr ctl_create
;	.endmacro

.endif

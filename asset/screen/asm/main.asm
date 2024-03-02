;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_MAIN_ASM_:
.include "../inc/screen.inc"

.org $0300

.segment "CODE"

jmp main_start

.export main_
main_:

.export main_run
.export counter_frame
.export counter_sec
.export counter_min
.export counter_hour
.export main_txt_title

main_run:				.byte 0
counter_frame:			.byte 0
counter_sec:			.byte 0
counter_min:			.byte 0
counter_hour:			.byte 0

main_txt_title:			.byte " Screen editor ",0
main_str_close:			.byte $01,$02,$03,0
main_str_suspend:		.byte $04,$05,$06,0


.export main_close_callback
.proc main_close_callback
	if_case_else #CTL_STATE_OVER
		textString #77, #0 ,#main_str_close ,#$7a
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #77, #0 ,#main_str_close ,#$ba
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #77, #0 ,#main_str_close ,#$ca
		rts

:	if_case_else #CTL_STATE_RELEASE
;		jsr suspend_clear
		lda #1
		sta main_run
:		rts
	.endproc


.export main_suspend_callback
.proc main_suspend_callback
	if_case_else #CTL_STATE_OVER
		textString #73, #0 ,#main_str_suspend ,#$7e
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #73, #0 ,#main_str_suspend ,#$be
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #73, #0 ,#main_str_suspend ,#$ce
		rts

:	if_case_else #CTL_STATE_RELEASE
		lda #1
		sta main_run
:		rts
	.endproc


.export main_start
.proc main_start
	jsr vera_init_sprite
	jsr vera_init_text
	jsr vera_init
	jsr ctl_init
	jsr menu1_init
	jsr edit_init
	jsr area_init

	textString #23, #0 ,#main_txt_title ,#$b1
	ctlCreate #(77*8), #0, #(3*8), #16, #main_close_callback
	ctlCreate #(73*8), #0, #(3*8), #16, #main_suspend_callback

	; Set the main loop hook.
	lda #<main_loop
	sta $020a
	lda #>main_loop
	sta $020b

	jmp sys_release
	.endproc


.export main_loop
.proc main_loop
	; System updates for this frame.
	jsr sys_update_clock
	jsr sys_update_mouse
	jsr sys_update_key
	cmp #0
	beq @start_loop
	sta scan_code
	jsr sys_translate_key

	; If there is a char in kyb_ascii save it for the debug display.
	lda kyb_ascii
	beq @start_loop
	sta loop_last_ascii

	@start_loop:
	lda loop_help_on
	bne :+
	jsr ctl_process
	:
	; Set the mouse pointer based on the current control state.
	jsr loop_set_mouse_image
	metaShowClock #54,#0
	jsr loop_key_input
	jsr loop_status_line
	
	lda main_run	; Exit program if "main_run" is ever set above 0.
	cmp #1
	beq @reset
	cmp #2
	beq @launch
	jmp sys_release

	@reset:
	stz kyb_ascii
	stz $01
	jmp sys_reset

	@launch:
	jmp sys_launch
	rts
	.endproc

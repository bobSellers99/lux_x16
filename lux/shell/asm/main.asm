;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_MAIN_ASM_:
.include "../inc/shell.inc"

.org $0300
.segment "CODE"

jmp main_start

; Vectors for cmd programs to return data.
lux_print_char:
	jsr term_print_char
	rts

lux_set_color:
	jsr term_set_color
	rts

.export main_
main_:

.export lux_drive_id
.export lux_cmd_str
.export lux_path_str
.export main_run

lux_drive_id:			.byte 1
lux_cmd_str:			.res 256
lux_path_str:			.res 256
main_run:				.byte 0
counter_frame:			.byte 0
counter_sec:			.byte 0
counter_min:			.byte 0
counter_hour:			.byte 0

library_fn:				.byte "/bin/lux/lib_1.bin",0
ascii_trans_fn:			.byte "/bin/lux/us_ascii.key",0
text_tiles_fn:			.byte "/bin/lux/alpha.til",0
palette_fn:				.byte "/bin/lux/default.pal",0
system_sprites_fn:		.byte "/bin/lux/mouse.spr",0
main_txt_title:			.byte "Command Shell",0
main_power_off:			.byte $07,$08,$09,0

test_bcd:				.byte $34,$12,$00,$00


.export power_off_callback
.proc power_off_callback
	if_case_else #CTL_STATE_OVER
		textString #77, #0 ,#main_power_off ,#$7a
		rts

:	if_case_else #CTL_STATE_PRESSED
		textString #77, #0 ,#main_power_off ,#$ba
		rts

:	if_case_else #CTL_STATE_NORMAL
		textString #77, #0 ,#main_power_off ,#$ca
		rts

:	if_case_else #CTL_STATE_RELEASE
		jsr sys_power_off
:		rts
	.endproc


.export main_start
.proc main_start
	jsr vera_blank

	; Load library into high mem.
	fileLoad #library_fn, #$7000, #0, #0

	; Load ascii translation table.
	fileLoad #ascii_trans_fn, #$ac00, #0, #0

	; Load charset.
	memSet_IMM_24 VRAM_textdata, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr 0, Stride 1	
	fileLoad #text_tiles_fn, #vera_data0, #16, #$80

	; Load default palette.
	memSet_IMM_24 VRAM_palette, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr 0, Stride 1	
	fileLoad #palette_fn, #vera_data0, #0, #$80

	; Load system sprites.
	memSet_IMM_24 VRAM_mouse, ZP24_R0
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr 0, Stride 1	
	fileLoad #system_sprites_fn, #vera_data0, #16, #$80

	jsr vera_init_text
	jsr vera_init_sprite
	jsr vera_init
	jsr history_init
	jsr term_init

	textString #25, #0, #main_txt_title, #$b1
    ctlCreate #(77*8), #0, #(3*8), #16, #power_off_callback

	; Set the main loop hook.
	lda #<main_loop
	sta $020a
	lda #>main_loop
	sta $020b
	jmp sys_release
	.endproc


.export main_loop
.proc main_loop
	; Vera updates for sprites and tile scrolling.
	memSet_IMM_24 VRAM_mouse, ZP24_R1
	sprite_set #0, #3, mouse_x, mouse_y

	; System updates for this frame.
	jsr sys_update_clock
	jsr sys_update_mouse
	jsr sys_update_key
	cmp #0
	beq @start_loop
	sta scan_code
	jsr sys_translate_key

	@start_loop:
	; Call routines for the application.
	jsr ctl_process
	jsr edit_process
	metaShowClock #58, #0

	; End of loop. "sys_release" releases the CPU to the system without
	; closing the program (Loop will restart next frame.) "sys_launch"
	; closes this application and launches another.
	lda main_run
	cmp #2
	beq @launch
	jmp sys_release
	
	@launch:
	jmp sys_launch
	.endproc


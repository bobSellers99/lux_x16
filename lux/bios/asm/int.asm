;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.include "../../../lib/inc/zeropage.inc"
.include "../inc/i2c.inc"
.include "../inc/ps2_keyboard.inc"
.include "../inc/ps2_mouse.inc"
.include "../inc/scheduler.inc"


_INT_ASM_:


INT_VERA_VSYNC		= 1
INT_VERA_LINE		= 2
INT_VERA_SCOL		= 4
INT_VERA_AFLOW		= 8

vera_ien			= $9f26
vera_isr			= $9f27


;*****************************************
; FETCH KEY CODE:
; out: A: key code (0 = none)
;         bit 7=0 => key down, else key up
;         A = 127/255 => extended key code
;      X: Extended key code second byte
;      Z: 1 if no key
;*****************************************
.export sys_update_key
.proc sys_update_key
	ldx #I2C_ADDRESS
	ldy #I2C_GET_SCANCODE_OFFSET
	jsr i2c_read_byte 	; Key code returned in A
	rts			; 0 = no key code available
	.endproc


.export int_reset_rotor
.proc int_reset_rotor
	lda #1
	sta sys_rotor

; Poll for mouse offset.
;	jsr sys_update_mouse

; Poll for a key code from the SMC over I2C.
;	jsr sys_update_key
;	cmp #0
;	beq @return

; On key code, call the stub for smc_key_in
;	sta scan_code
;	jsr sys_translate_key

	@return:
	rts
	.endproc


.export int_vera_vsync 
.proc int_vera_vsync
	jsr int_reset_rotor
	jmp $02be
	.endproc


.export int_vera_line 
.proc int_vera_line
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be
	.endproc


.export int_vera_sprite_collision 
.proc int_vera_sprite_collision
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be
	.endproc


.export int_vera_audio_flow 
.proc int_vera_audio_flow
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be
	.endproc


.export int_via_1 
.proc int_via_1
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be
	.endproc


.export int_via_2 
.proc int_via_2
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be
	.endproc


.export shell_vera_int 
.proc shell_vera_int
	lda vera_isr
	and #INT_VERA_VSYNC
	cmp #INT_VERA_VSYNC
	beq @vsync

	lda vera_isr
	and #INT_VERA_LINE
	cmp #INT_VERA_LINE
	beq @line

	lda vera_isr
	and #INT_VERA_SCOL
	cmp #INT_VERA_SCOL
	beq @sprite_collision

	lda vera_isr
	and #INT_VERA_AFLOW
	cmp #INT_VERA_AFLOW
	beq @audio_flow

	lda $02a0	; Recover the original ROM bank
	sta $01

	plp
	ply
	plx
	pla
	cli
	rti

	@vsync:
	lda #INT_VERA_VSYNC 
	sta vera_isr
	jmp ($0202)

	@line:
	lda #INT_VERA_LINE 
	sta vera_isr
	jmp ($0204)

	@sprite_collision:
	lda #INT_VERA_SCOL 
	sta vera_isr
	jmp ($0206)

	@audio_flow:
; AFLOW interrupt can only be cleared by filling the audio FIFO for at least 1/4
	jmp ($0208)
	.endproc


.export shell_init_int 
.proc shell_init_int
	; Install VERA interrupt vectors.
	lda #<shell_vera_int
	sta $0200
	lda #>shell_vera_int
	sta $0201

	lda #<int_vera_vsync
	sta $0202
	lda #>int_vera_vsync
	sta $0203

	lda #<int_vera_line
	sta $0204
	lda #>int_vera_line
	sta $0205

	lda #<int_vera_sprite_collision
	sta $0206
	lda #>int_vera_sprite_collision
	sta $0207

	lda #<int_vera_audio_flow
	sta $0208
	lda #>int_vera_audio_flow
	sta $0209

	lda #INT_VERA_VSYNC ; Make VERA only generate VSYNC IRQs.
	sta vera_ien

	cli	; enable IRQ now that vectors are properly set.
	rts
	.endproc


.export shell_init_userspace 
.proc shell_init_userspace
	lda #<sys_user_loop
	sta $020a
	lda #>sys_user_loop
	sta $020b
	rts
	.endproc


.export shell_create_int_link
.proc shell_create_int_link
	@source			= r1
	@dest			= r2
	; This supports the hardware feature that sets the ROM bank 
	; to 0 when an interrupt is called. The interrupt vector 
	; itself is at $02XX, then jumps to the entry vector in ROM
	; bank 0. 

	; Set the link data.

	; Copy the link code.
	; Copy the link code to $0286
	lda #<@link_start
	sta @source
	lda #>@link_start
	sta @source+1
	lda #$b0	; Fix for proper address.
	sta @dest
	lda #$02
	sta @dest+1
	ldy #0
	@link_load_loop:
		lda (@source),y
		sta (@dest),y
		iny
		cpy #(@link_end-@link_start)
		bne @link_load_loop
	rts

	; The actual code that goes in $02b0 (Don't run it here!)
	@link_start:
	pha
	phx
	phy
	php

	lda $01		; Save off the original ROM bank to memory.
	sta $02a0
	stz $01

	jmp ($0200)	; Jump to interrupt dispatch in ROM bank 0

	lda $02a0	; Recover the original ROM bank
	sta $01
	plp
	ply
	plx
	pla
	cli
	rti
	@link_end:
	.endproc


;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02

_MAIN_ASM_:

;.include "../inc/regs.inc"
.include "../../../lib/inc/zeropage.inc"
.include "../inc/file.inc"
.include "../inc/int.inc"
.include "../inc/ps2_keyboard.inc"
.include "../inc/ps2_mouse.inc"
.include "../inc/scheduler.inc"
.include "../inc/fat32.inc"
.include "../inc/sdcard.inc"
.include "../inc/rtc.inc"

.import i2c_read_byte, i2c_write_byte

vera_ctrl			= $9f25
vera_dc_video		= $9f29

shell_fn:		.byte "/bin/lux/lux",0


.export shell_clear_ram_02 
.proc shell_clear_ram_02
	@index		= r7L
	@page_val	= r7H

	lda #$00
	sta @index
	lda #$02
	sta @page_val

	ldy #0
	@page_loop:
		@loop:
			lda @page_val
			sta (@index),y
			iny
			bne @loop
		inc @page_val
		lda @page_val
		cmp #$9f
		bne @page_loop
	rts
	.endproc


.export shell_clear_ram_a0
.proc shell_clear_ram_a0
	lda #$00
	sta r7
	lda #$a0
	sta r7+1

	ldy #0
	@page_loop:
		@loop:
			lda r7+1
			sta (r7),y
			iny
			bne @loop
		inc r7+1
		lda r7+1
		cmp #$c0
		bne @page_loop
	rts
	.endproc


.export shell_clear_zp 
.proc shell_clear_zp
	ldx #0
	lda #0
	@loop:
		sta $0000,x
		inx
		bne @loop
	rts	
	.endproc


;.export shell_init_rom_bank_link
;shell_init_rom_bank_link:
;	; This allows a ROM bank to call code in another ROM bank.
;	; The destination bank's function must be in the bank's LINKs.
;	; 4 bytes for the xfer data:
;	; Original rombank
;	; Destination rombank
;	; dest addr
;
;	@source			= r0
;	@dest			= r1
;
;	stz $0280 ; Destination address
;	stz $0281 
;
;	; Copy the link code to $0282
;	lda #<@link_start
;	sta @source
;	lda #>@link_start
;	sta @source+1
;	lda #$82
;	sta @dest
;	lda #$02
;	sta @dest+1
;	ldy #0
;	@link_load_loop:
;		lda (@source),y
;		sta (@dest),y
;		iny
;		cpy #(@link_end-@link_start)
;		bne @link_load_loop
;	rts
;
;	; The actual code that goes in $0282 (Don't run it here!)
;	@link_start:
;	lda dest_bank				; a5 ed
;	sta rom_bank				; 85 01
;	lda tmp2					; 85 eb	; depreciated
;	jmp ($0280)					; 6C 80 02
;
;	lda orig_bank
;	sta rom_bank
;	lda tmp2
;	rts
;	@link_end:


.export shell_main 
.proc shell_main
	stz vera_ctrl
	lda #$01	; VGA mode only, no active layers.
	sta vera_dc_video

	ldx #0
	@clear_zp:
		stz $0000,x
		dex
		bne @clear_zp

	ldx #0
	@clear_stack:
		stz $0100,x
		dex
		bne @clear_stack

	; "Page tag" ram from 0200 to $9eff.
	jsr shell_clear_ram_02
	; "Page tag" ram from 0a000 to $bfff.
	jsr shell_clear_ram_a0

;	jsr shell_init_rom_bank_link
	jsr shell_create_int_link

	jsr shell_init_int
	jsr shell_init_userspace

	; Initialize the SDcard.
	jsr sdcard_init
	bcs @fat32_init
	jsr shell_stop

	; Initialize the fat32 memory area in RAM page 0
	@fat32_init:
	jsr fat32_init
	bcs @init_rtc
	jsr shell_stop

	; Initialize the RTC
	@init_rtc:
	jsr rtc_init

	; mount the volume.
	@fat32_mount:
	lda #$ff
	jsr fat32_alloc_context
	jsr fat32_get_context
	jsr fat32_free_context
	bcs @continue
	jsr shell_stop

	@continue:
	; Initialize the key modifiers.
	stz key_shift
	stz key_shift_lock
	stz key_ctl
	stz key_alt

	; Load command shell program.
	@context 	= r1
	fileOpen #shell_fn
	sta @context
	jsr file_get_remaining
	fileRead #$0300, #0
	fileClose @context

	bcc @abort

	; Execute command shell.
	jmp $0300

	@abort:
	jsr shell_stop
	.endproc

.export sys_release
.proc sys_release
	jmp scheduler
	.endproc


.export sys_launch
.proc sys_launch
	; Reset the main loop hook. (reset interrupts.)
	lda #<sys_user_loop
	sta $020a
	lda #>sys_user_loop
	sta $020b

	; Reset the stack.
	ldx #0
	@clear_stack:
		stz $0100,x
		dex
		bne @clear_stack
	ldx #$fd
	txs

	; Load command shell program.
	fileOpen fat32_ptr
	pha
	jsr file_get_remaining
	fileRead fat32_param32, #$00
	pla
	jsr file_close

	; Execute program.
	jmp $0300
	rts
	.endproc


.export sys_reset
.proc sys_reset
	sei
	stz vera_ctrl
	lda #$01	; VGA mode only, no active layers.
	sta vera_dc_video

	; Reset the stack.
	ldx #0
	@clear_stack:
		stz $0100,x
		dex
		bne @clear_stack
	ldx #$fd
	txs

;	jsr shell_init_rom_bank_link
	jsr shell_create_int_link

	jsr shell_init_int
	jsr shell_init_userspace

;	@continue:
	; Initialize the key modifiers.
	stz key_shift
	stz key_shift_lock
	stz key_ctl
	stz key_alt

	; Load command shell program.
	fileOpen #shell_fn
	sta r1
	jsr file_get_remaining
	fileRead #$0300, #0
	fileClose r1

	; Execute command shell.
	jmp $0300
	.endproc


.export sys_set_event
.proc sys_set_event
	rts
	.endproc


.export sys_power_off
.proc sys_power_off
	ldx #$42
	ldy #$1
	lda #$0
	jsr i2c_write_byte
	rts
	.endproc



; shell stop! This is the bad end. Something crashed.
; To handle this... Get the data needed to start the system from a
; ROM bank (charset and translate table.)
shell_stop:
	bra shell_stop


; Start the segment where the shell rom soft links are.
.segment "LINKS"

; Interrupt management.


; File operations.
jmp file_open			; $ff00
jmp file_create			; $ff03
jmp file_seek			; $ff06
jmp file_size			; $ff09
jmp file_get_remaining	; $ff0c
jmp file_read			; $ff0f
jmp file_write			; $ff12
jmp file_close			; $ff15

; Directory operations.
jmp file_find_dirent	; $ff18
jmp file_open_dir		; $ff1b
jmp file_read_dirent	; $ff1e
jmp file_open_tree		; $ff21
jmp file_walk_tree		; $ff24
jmp file_chdir			; $ff27
jmp file_mkdir			; $ff2a
jmp file_rmdir			; $ff2d
jmp file_rename			; $ff30
jmp file_set_attribute	; $ff33
jmp file_delete			; $ff36

; System control.
jmp sys_release			; $ff39
jmp sys_launch			; $ff3c
jmp sys_reset			; $ff3f
jmp sys_set_event		; $ff42
jmp sys_update_clock	; $ff45
jmp sys_update_mouse	; $ff48
jmp sys_update_key		; $ff4b
jmp sys_translate_key	; $ff4e
jmp sys_power_off		; $ff51



; Start the segment where the reset vectors are. (nmi, reset, and irq)
.segment "VECTORS" 
.word   shell_main	; NMI will just restart the program.
.word   shell_main	; Reset vector that starts execution.
.word   $02b0		; Interrupt request from VERA.
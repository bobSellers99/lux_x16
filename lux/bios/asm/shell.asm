.include "../inc/shell.inc"
.include "../inc/regs.inc"

.pc02

.org $C000		
.segment "CODE"	

I2C_ADDRESS = $42
I2C_GET_SCANCODE_OFFSET = $07
I2C_GET_MOUSE_MOVEMENT_OFFSET = $21

;I2C_KBD_CMD2 = $1a

.import i2c_read_byte, i2c_write_byte
.import i2c_read_first_byte, i2c_read_next_byte, i2c_read_stop

.import rtc_get_date_time, rtc_set_date_time
.import rtc_get_nvram, rtc_set_nvram, rtc_check_nvram_checksum

.export tmp2

; Zero page registers.
R0					= $02
R1					= $04
R2					= $06
R3					= $08
R4					= $0a
R5					= $0c
R6					= $0e
R7					= $10
R8					= $12
R9					= $14
R10					= $16
R11					= $18
R12					= $1a
zp_ind				= $22;$23
zp_ind2				= $24;$25
tmp2				= $26	; Scratch pad used by rtc

; System parameters
;kernal_ptr 			= $ec;ed
;fat32_ptr			= $ee;ef

; System uses $e0 to $ff
kernal_ptr 			= $e0;e1
fat32_ptr			= $e7;e8
;fat32_size			= $e9;ea

FAT32_PARAM32       = $f0 ;$f1;$f2;f3
FAT32_OFFSET        = $f4 ;$f5
SYS_ROTOR			= $f6
SYS_TICKS			= $f7

KYB_SCAN_CODE       = $f8
KYB_ASCII           = $f9
KYB_MODIFIERS       = $fa
MOUSE_BTNS          = $fb
MOUSE_X		    	= $fc;$7d
MOUSE_Y		    	= $fe;$7f

cbdos_flags			= $0268

; Shell RAM vars.
fat32_time_year		= $b000
fat32_time_month	= $b001
fat32_time_day		= $b002
fat32_time_weekday	= $b003
fat32_time_hours	= $b004
fat32_time_minutes	= $b005
fat32_time_seconds	= $b006

fat32_errno			= $b3eb
fat32_size			= $b3e7	; 32 bit size param for calls.
fat32_file_size		= $b3fe	; 32 bit file size. DO NOT WRITE
fat32_file_pos		= $b402 ; 32 bit file pos. DO NOT WRITE

key_shift			= $bf00
key_shift_lock		= $bf01	; TODO Not implemented.
key_ctl				= $bf02
key_alt				= $bf03

INT_VERA_VSYNC		= 1
INT_VERA_LINE		= 2
INT_VERA_SCOL		= 4
INT_VERA_AFLOW		= 8

ascii_norm			= $ac00
ascii_norm_shift	= $ac80
ascii_norm_alt		= $ad00
ascii_norm_ctl		= $ad80
ascii_lock			= $ac00
ascii_lock_shift	= $ac80
ascii_lock_alt		= $ad00
ascii_lock_ctl		= $ad80

VERA_addr_low		= $9f20
VERA_addr_high		= $9f21
VERA_addr_bank		= $9f22
VERA_data0			= $9f23
VERA_ctrl			= $9f25
VERA_ien			= $9f26
VERA_isr			= $9f27
VERA_dc_video		= $9f29

shell_fn:		.byte "/bin/lux/lux",0
;us_ascii_fn:	.byte "/bin/lux/us_ascii",0

.macro bank_to_bank_call bank, dest_addr, ret_addr
	pha
	lda $01
	sta $0280
	lda #bank
	sta $0281
	lda #<dest_addr
	sta $0282
	lda #>dest_addr
	sta $0283
	lda #<ret_addr
	sta $0284
	lda #>ret_addr
	sta $0285
	jmp $0286
	.endmacro


;.macro shell_debug msg_addr, color
;	lda #<msg_addr
;	sta R1
;	lda #>msg_addr
;	sta R1+1
;	lda color
;	jsr shell_debug_out
;	.endmacro

.export sdcard_init
sdcard_init:
	bank_to_bank_call 1, $ff00, @return_addr
	@return_addr:
	rts

.export fat32_init
fat32_init:
	bank_to_bank_call 1, $ff06, @return_addr
	@return_addr:
	rts


.export fat32_alloc_context
fat32_alloc_context:
	bank_to_bank_call 1, $ff0c, @return_addr
	@return_addr:
	rts


.export fat32_set_context
fat32_set_context:
	bank_to_bank_call 1, $ff12, @return_addr
	@return_addr:
	rts


.export fat32_open
fat32_open:
	bank_to_bank_call 1, $ff18, @return_addr
	@return_addr:
	rts


.export fat32_read_byte
fat32_read_byte:
	bank_to_bank_call 1, $ff1e, @return_addr
	@return_addr:
	rts


.export fat32_get_ptable_entry
fat32_get_ptable_entry:
	bank_to_bank_call 1, $ff24, @return_addr
	@return_addr:
	rts


.export fat32_read
fat32_read:
	bank_to_bank_call 1, $ff2a, @return_addr
	@return_addr:
	rts


.export fat32_close
fat32_close:
	bank_to_bank_call 1, $ff30, @return_addr
	@return_addr:
	rts


.export fat32_seek
fat32_seek:
	bank_to_bank_call 1, $ff36, @return_addr
	@return_addr:
	rts


.export fat32_free_context
fat32_free_context:
	bank_to_bank_call 1, $ff3c, @return_addr
	@return_addr:
	rts


.export fat32_write
fat32_write:
	bank_to_bank_call 1, $ff42, @return_addr
	@return_addr:
	rts


.export fat32_create
fat32_create:
	bank_to_bank_call 1, $ff48, @return_addr
	@return_addr:
	rts


.export fat32_find_dirent
fat32_find_dirent:
	bank_to_bank_call 1, $ff4e, @return_addr
	@return_addr:
	rts


.export fat32_open_dir
fat32_open_dir:
	bank_to_bank_call 1, $ff54, @return_addr
	@return_addr:
	rts


.export fat32_read_dirent
fat32_read_dirent:
	bank_to_bank_call 1, $ff5a, @return_addr
	@return_addr:
	rts


.export fat32_chdir
fat32_chdir:
	bank_to_bank_call 1, $ff60, @return_addr
	@return_addr:
	rts


.export fat32_mkdir
fat32_mkdir:
	bank_to_bank_call 1, $ff66, @return_addr
	@return_addr:
	rts


.export fat32_rmdir
fat32_rmdir:
	bank_to_bank_call 1, $ff6c, @return_addr
	@return_addr:
	rts


.export fat32_get_context
fat32_get_context:
	bank_to_bank_call 1, $ff72, @return_addr
	@return_addr:
	rts


.export fat32_open_tree
fat32_open_tree:
	bank_to_bank_call 1, $ff78, @return_addr
	@return_addr:
	rts


.export fat32_walk_tree
fat32_walk_tree:
	bank_to_bank_call 1, $ff7e, @return_addr
	@return_addr:
	rts


; Scan code mapping:
;alphanumeric keys:	$01 to $40
;Navigation keys:	$4b to $59
;Numeric keypad:	$5a to $6d
;Function keys:		$6e to $7b

kyb_translate_scan_code:
    pha
	phy
    sta KYB_SCAN_CODE

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

	bra @translate

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

	@translate:
	; translate scan code
 ;   sta ZPB_SCAN_CODE
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
    sta KYB_ASCII
;	sta debug_last_key
;	jsr $ffd2

	@exit:vera_ien			= $9f26
vera_isr			= $9f27

; FETCH KEY CODE:
; out: A: key code (0 = none)
;         bit 7=0 => key down, else key up
;         A = 127/255 => extended key code
;      X: Extended key code second byte
;      Z: 1 if no key
;*****************************************
fetch_key_code:
	ldx #I2C_ADDRESS
	ldy #I2C_GET_SCANCODE_OFFSET
	jsr i2c_read_byte 	; Key code returned in A
	rts			; 0 = no key code available


.export check_mouse_pos
check_mouse_pos:
	stz $02f9
	stz $02fa

	; Check for less than 0.
	lda MOUSE_X+1
	bmi @reset_xl
	lda MOUSE_Y+1
	bmi @reset_yl

	; Check for > than 639/479
	sec
	lda MOUSE_X
	sbc #$7f
	lda MOUSE_X+1
	sbc #$02
	bpl @reset_xh

	sec
	lda MOUSE_Y
	sbc #$df
	lda MOUSE_Y+1
	sbc #$01
	bpl @reset_yh
	rts

	@reset_xl:
	stz MOUSE_X
	stz MOUSE_X+1
	rts

	@reset_yl:
	stz MOUSE_Y
	stz MOUSE_Y+1
	rts

	@reset_xh:
	lda #$7f
	sta MOUSE_X
	lda #$02
	sta MOUSE_X+1
	rts

	@reset_yh:
	lda #$df
	sta MOUSE_Y
	lda #$01
	sta MOUSE_Y+1
	rts


.export get_mouse_offset
get_mouse_offset:
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
	sta MOUSE_BTNS
	lda $02f9
	bpl @x2
	bmi @x3

	@x2:
	clc
	lda MOUSE_X
	adc $02f9
	sta MOUSE_X
	lda MOUSE_X+1
	adc #0
	sta MOUSE_X+1
	bra @do_y

	@x3:
	lda $02f9
	eor #$ff
	inc
	sta $02f9
	sec
	lda MOUSE_X
	sbc $02f9
	sta MOUSE_X
	lda MOUSE_X+1
	sbc #0
	sta MOUSE_X+1

	@do_y:
	lda $02fa
	bpl @y3
	bmi @y2

	@y3:
	sec
	lda MOUSE_Y
	sbc $02fa
	sta MOUSE_Y
	lda MOUSE_Y+1
	sbc #0
	sta MOUSE_Y+1
	bra @done

	@y2:
	lda $02fa
	eor #$ff
	inc
	sta $02fa
	clc
	lda MOUSE_Y
	adc $02fa
	sta MOUSE_Y
	lda MOUSE_Y+1
	adc #0
	sta MOUSE_Y+1

	@done:
	jsr check_mouse_pos
	rts


.export int_vera_vsync 
int_vera_vsync:
; Set SYS_ROTOR to user_loop start
; TODO Move this to line interrupt for line 1, user start should
; be there. This start point should be for VERA changes. 
;	lda #00
;	sta $01

	lda #1
	sta SYS_ROTOR

; Poll for mouse offset.
	jsr get_mouse_offset

; Poll for a key code from the SMC over I2C.
	jsr fetch_key_code
	cmp #0
	beq @return

; On key code, call the stub for smc_key_in
	sta KYB_SCAN_CODE
	jsr kyb_translate_scan_code
;	jsr hook_smc_key_in

	@return:
	jmp $02be


.export int_vera_line 
int_vera_line:
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be


.export int_vera_sprite_collision 
int_vera_sprite_collision:
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be


.export int_vera_audio_flow 
int_vera_audio_flow:
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be


.export int_via_1 
int_via_1:
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be


.export int_via_2 
int_via_2:
	lda $02a0	; Recover the original ROM bank
	sta $01
	jmp $02be


.export sys_user_loop
sys_user_loop:
	jmp scheduler


.export shell_vera_int 
shell_vera_int:
	lda VERA_isr
	and #INT_VERA_VSYNC
	cmp #INT_VERA_VSYNC
	beq @vsync

	lda VERA_isr
	and #INT_VERA_LINE
	cmp #INT_VERA_LINE
	beq @line

	lda VERA_isr
	and #INT_VERA_SCOL
	cmp #INT_VERA_SCOL
	beq @sprite_collision

	lda VERA_isr
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
	sta VERA_isr
	jmp ($0202)

	@line:
	lda #INT_VERA_LINE 
	sta VERA_isr
	jmp ($0204)

	@sprite_collision:
	lda #INT_VERA_SCOL 
	sta VERA_isr
	jmp ($0206)

	@audio_flow:
; AFLOW interrupt can only be cleared by filling the audio FIFO for at least 1/4
	jmp ($0208)


.export shell_init_int 
shell_init_int:
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
	sta VERA_ien

	cli	; enable IRQ now that vectors are properly set.
	rts


.export shell_init_userspace 
shell_init_userspace:
	lda #<sys_user_loop
	sta $020a
	lda #>sys_user_loop
	sta $020b
	rts


.export shell_create_int_link
shell_create_int_link:
	; This supports the hardware feature that sets the ROM bank 
	; to 0 when an interrupt is called. The interrupt vector 
	; itself is at $02XX, then jumps to the entry vector in ROM
	; bank 0. 

	; Set the link data.

	; Copy the link code.
	; Copy the link code to $0286
	lda #<@link_start
	sta R1
	lda #>@link_start
	sta R1+1
	lda #$b0	; Fix for proper address.
	sta R2
	lda #$02
	sta R2+1
	ldy #0
	@link_load_loop:
		lda (R1),y
		sta (R2),y
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

	lda $01		; Save off the original ROM bank to the stack.
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


.export shell_create_bank_link
shell_create_bank_link:
	; This allows a ROM bank to call code in another ROM bank.
	; The destination bank's function must be in the bank's LINKs.
	; 6 bytes for the xfer data:
	; Original rombank
	; Destination rombank
	; dest addr
	; return addr
	stz $0280 ; Original rombank
	stz $0281 ; Destination rombank
	stz $0282 ; Destination address
	stz $0283 
	stz $0284 ; Return address
	stz $0285 

	; Copy the link code to $0286
	lda #<@link_start
	sta R1
	lda #>@link_start
	sta R1+1
	lda #$86
	sta R2
	lda #$02
	sta R2+1
	ldy #0
	@link_load_loop:
		lda (R1),y
		sta (R2),y
		iny
		cpy #(@link_end-@link_start)
		bne @link_load_loop
	rts

	; The actual code that goes in $0286 (Don't run it here!)
	@link_start:
;	sei				; 78	
	lda $0281		; AD 81 02
	sta $01			; 85 01
	pla				; 68


	jmp ($0280)		; 6C 82 02


	nop
	pha				; 48
	lda $0280		; AD 80 02
	sta $01			; 85 01
	pla				; 68
;	cli				; 58
	jmp ($0284)		; 6C 84 02
	@link_end:


.export shell_clear_ram_02 
shell_clear_ram_02:
	lda #$00
	sta R7
	lda #$02
	sta R7+1

	ldy #0
	@page_loop:
		@loop:
			lda R7+1
			sta (R7),y
			iny
			bne @loop
		inc R7+1
		lda R7+1
		cmp #$9f
		bne @page_loop
	rts


shell_clear_ram_a0:
	lda #$00
	sta R7
	lda #$a0
	sta R7+1

	ldy #0
	@page_loop:
		@loop:
			lda R7+1
			sta (R7),y
			iny
			bne @loop
		inc R7+1
		lda R7+1
		cmp #$c0
		bne @page_loop
	rts


.export shell_clear_zp 
shell_clear_zp:
	ldx #0
	lda #0
	@loop:
		sta $0000,x
		inx
		bne @loop
	rts	


; Set fat32_size param in 0 to 255 range via A
shell_set_size:
	sta $b3e6
	lda #0
	sta $b3e7
	lda #0
	sta $b3e8
	lda #0
	sta $b3e9
	rts

;jmp file_alloc_context 	; $ff00
;jmp file_open			; $ff03
;jmp file_seek			; $ff06
;jmp file_read			; $ff09
;jmp file_write			; $ff0c
;jmp file_close			; $ff0f

.export file_alloc_context
file_alloc_context:
	jsr fat32_alloc_context
	rts

.export file_set_context
file_set_context:
	jsr fat32_set_context
	rts


.export file_open
file_open:
	; Turn on the activity light
	ldx #$42
	ldy #$5
	lda #$80
	jsr i2c_write_byte
	lda #$10
	sta cbdos_flags

	jsr fat32_open
	rts


.export file_seek
file_seek:
	jsr fat32_seek
	rts


.export file_read
file_read:
	jsr fat32_read
	rts


.export file_write
file_write:
	jsr fat32_write
	rts


.export file_close
file_close:
	; file context is passed in A.
	pha
	jsr fat32_set_context
	jsr fat32_close
	pla
	jsr fat32_free_context

	; Turn off the activity light
	ldx #$42
	ldy #$5
	lda #$00
	jsr i2c_write_byte
	lda #$00
	sta cbdos_flags
	rts


.export shell_copy_name
	shell_copy_name:
	; Set up a remote located filename for file_open.
	stx R6
	sty R6+1
	lda #$00
	sta R5
	lda #$9e
	sta R5+1
	ldy #0
	@loop2:
		lda (R6),y
		sta (R5),y
		beq @return
		iny
		bra @loop2

	@return:
	rts


.export shell_copy_data
	shell_copy_data:
	; Set up a remote located filename for file_open.
	stx R6
	sty R6+1
	lda #$00	
	sta R5
	lda #$80
	sta R5+1
	ldy #0
	@loop2:
		lda (R6),y
		sta (R5),y
	;	beq @return
		iny
		bne @loop2

	@return:
	rts


.export file_set_name
file_set_name:
	; file address is passed in X,Y. (X = lo, Y = hi)
	stx fat32_ptr
	sty fat32_ptr+1
	rts


.export file_get_remaining
file_get_remaining:
	sec
	lda fat32_file_size
	sbc fat32_file_pos
	sta fat32_size
	lda fat32_file_size+1
	sbc fat32_file_pos+1
	sta fat32_size+1
	lda fat32_file_size+2
	sbc fat32_file_pos+2
	sta fat32_size+2
	lda fat32_file_size+3
	sbc fat32_file_pos+3
	sta fat32_size+3
	rts


.export file_load_ram
file_load_ram:
	; Allocate context.
	lda #$00
	jsr file_alloc_context
	bcc @error
	sta R7

	; Set the current context
	jsr file_set_context
	bcc @error

	; Open file
	jsr file_open
	bcc @error

	; Use offset word to seek to start of data.
	lda FAT32_OFFSET
	sta fat32_size
	lda FAT32_OFFSET+1
	sta fat32_size+1
	stz fat32_size+2
	stz fat32_size+3
	jsr fat32_seek
	bcc @error

	; Get amount to load and put it into "fat32_size" 
	; If R12 is 0, put amount remaining in file into "fat32_size"
	lda R12
	bne @use_R12_as_size
	lda R12+1
	bne @use_R12_as_size
	jsr file_get_remaining
	bra @set_vram

	; else just transfer R12 to "fat32_size"
	@use_R12_as_size:
	lda R12
	sta fat32_size
	lda R12+1
	sta fat32_size+1
	stz fat32_size+2
	stz fat32_size+3

	; FLag for single address 0ff.
	@set_vram:
	stz kernal_ptr

	; Read fat32_size bytes into memory at (fat32_ptr).
	lda FAT32_PARAM32
	sta fat32_ptr
	lda FAT32_PARAM32+1
	sta fat32_ptr+1
	jsr file_read
	bcc @error

	; Close the file and free the context.
	lda R7
	jsr file_close
	bcc @error
	
	lda #0
	rts

	@error:
	rts


.export file_load_vram
file_load_vram:
	; Allocate context.
	lda #$00
	jsr file_alloc_context
	bcc @error
	sta R7

	; Set the current context
	jsr file_set_context
	bcc @error

	; Open file
	jsr file_open
	bcc @error

	; Use offset word to seek to start of data.
	lda FAT32_OFFSET
	sta fat32_size
	lda FAT32_OFFSET+1
	sta fat32_size+1
	stz fat32_size+2
	stz fat32_size+3
	jsr fat32_seek
	bcc @error

	; Get amount to load and put it into "fat32_size" 
	; If R12 is 0, put amount remaining in file into "fat32_size"
	lda R12
	bne @use_R12_as_size
	lda R12+1
	bne @use_R12_as_size
	jsr file_get_remaining
	bra @set_vram

	; else just transfer R12 to "fat32_size"
	@use_R12_as_size:
	lda R12
	sta fat32_size
	lda R12+1
	sta fat32_size+1
	stz fat32_size+2
	stz fat32_size+3

	; Set up VRAM address with stride of 0 and data0.
	@set_vram:
	stz VERA_ctrl
	lda FAT32_PARAM32
	sta VERA_addr_low
	lda FAT32_PARAM32+1
	sta VERA_addr_high
	lda FAT32_PARAM32+2
	ora #$10
	sta VERA_addr_bank

	; FLag for single address.
	lda #$80
	sta kernal_ptr

	; Read fat32_size bytes into memory at (fat32_ptr).
	lda #<VERA_data0
	sta fat32_ptr
	lda #>VERA_data0
	sta fat32_ptr+1
	jsr file_read
	bcc @error

	; Close the file and free the context.
	lda R7
	jsr file_close
	bcc @error
	
	lda #0
	rts

	@error:
	rts


.export file_load_bank
file_load_bank:
	rts



.export file_save_ram
file_save_ram:
	phy
	phx

	; Allocate context.
	lda #$00
	jsr file_alloc_context
	bcc @error
	sta R7

	; Set the current context
	jsr file_set_context
	bcc @error

	; Create file.
	sec ; Carry set = overwite existing file.
	jsr file_create
	bcc @error

	; Read fat32_size bytes into momory at (fat32_ptr).
	pla
	sta fat32_ptr
	pla
	sta fat32_ptr+1
	jsr file_write
	bcc @error

	; Close the file and free the context.
	lda R7
	jsr file_close
	bcc @error
	
	lda #0
	rts

	@error:
	rts


.export sys_release
sys_release:
	jmp scheduler


.export file_create
file_create:
	jsr fat32_create
	rts


.export file_find_dirent
file_find_dirent:
	jsr fat32_find_dirent
	rts


.export file_open_dir
file_open_dir:
	jsr fat32_open_dir
	rts


.export file_read_dirent
file_read_dirent:
	jsr fat32_read_dirent
	rts


.export file_chdir
file_chdir:
	jsr fat32_chdir
	rts


.export file_mkdir
file_mkdir:
	jsr fat32_mkdir
	rts


.export file_rmdir
file_rmdir:
	jsr fat32_rmdir
	rts


.export file_get_context
file_get_context:
	jsr fat32_get_context
	rts


.export file_free_context
file_free_context:
	jsr fat32_free_context
	rts


.export file_open_tree
file_open_tree:
	jsr fat32_open_tree
	rts


.export file_walk_tree
file_walk_tree:
	jsr fat32_walk_tree
	rts


.export file_size
file_size:

	rts



.export shell_main 
shell_main:
;	sei
	stz VERA_ctrl
	lda #$01	; VGA mode only, no active layers.
	sta VERA_dc_video

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

	jsr shell_create_bank_link
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
	jsr rtc_get_date_time
	lda r1H	; Hours
	sta fat32_time_hours
	lda r2L	; Minutes
	sta fat32_time_minutes
	lda r2H	; Seconds
	sta fat32_time_seconds
	lda r3H	; day of week
	sta fat32_time_weekday
	lda r1L	; day
	sta fat32_time_day
	lda r0H	; month
	sta fat32_time_month
	lda r0L	; year
	sta fat32_time_year

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
	ldx #<shell_fn
	ldy #>shell_fn
	jsr shell_copy_name

	ldx #$00
	ldy #$9e
	jsr file_set_name

	lda #$00
	sta FAT32_PARAM32
	lda #$03
	sta FAT32_PARAM32+1
	jsr file_load_ram

;	jsr shell_stop

	; Execute command shell.
	jmp $0300


.export sys_reset
sys_reset:
	sei
	stz VERA_ctrl
	lda #$01	; VGA mode only, no active layers.
	sta VERA_dc_video

	; Reset the stack.
	ldx #0
	@clear_stack:
		stz $0100,x
		dex
		bne @clear_stack
	ldx #$fd
	txs

	jsr shell_create_bank_link
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
	ldx #<shell_fn
	ldy #>shell_fn
	jsr shell_copy_name

	ldx #$00
	ldy #$9e
	jsr file_set_name

	lda #$00
	sta FAT32_OFFSET
	lda #$00
	sta FAT32_OFFSET+1

	lda #$00
	sta FAT32_PARAM32
	lda #$03
	sta FAT32_PARAM32+1

	lda #$00
	sta R12
	lda #$00
	sta R12+1

	jsr file_load_ram

	; Execute command shell.
	jmp $0300



.export sys_launch
sys_launch:
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

	jsr file_load_ram

	; Execute program.
	jmp $0300
	rts


; shell stop! This is the bad end. Something crashed.
; To handle this... Get the data needed to start the system from a
; ROM bank (charset and translate table.)
shell_stop:
	bra shell_stop

; TODO This will eventually be the scheduler. For now, all it does
; is call the user's main loop once per frame.
; TODO add profile code into the scheduler as well.
scheduler:
	lda SYS_ROTOR
	cmp #1
	beq @user0_loop
	jmp scheduler

	@user0_loop:
	stz SYS_ROTOR
	; System level once per tick execution.
	inc SYS_TICKS
	lda SYS_TICKS
	cmp #60
	bmi @clock_done
	stz SYS_TICKS
	inc fat32_time_seconds	; seconds
	lda fat32_time_seconds
	cmp #60
	bmi @clock_done
	stz fat32_time_seconds
	inc fat32_time_minutes	; minutes
	; Reload the time from the RTC every minute. 
	jsr rtc_get_date_time
	lda r1H	; Hours
	sta fat32_time_hours
	lda r2L	; Minutes
	sta fat32_time_minutes
	lda r2H	; Seconds
	sta fat32_time_seconds
	lda r3H	; day of week
	sta fat32_time_weekday
	lda r1L	; day
	sta fat32_time_day
	lda r0H	; month
	sta fat32_time_month
	lda r0L	; year
	sta fat32_time_year

	@clock_done:
	; User level once per tick execution.
	jmp ($020a)


; Start the segment where the shell rom soft links are.
.segment "LINKS"
jmp file_alloc_context 	; $ff00
jmp file_set_context 	; $ff03
jmp file_open			; $ff06
jmp file_seek			; $ff09
jmp file_read			; $ff0c
jmp file_write			; $ff0f
jmp file_close			; $ff12
jmp file_set_name		; $ff15
jmp file_load_ram		; $ff18
jmp file_load_vram		; $ff1b
jmp file_load_bank		; $ff1e
jmp sys_release			; $ff21
jmp file_save_ram		; $ff24
jmp file_create			; $ff27
jmp file_find_dirent	; $ff2a
jmp file_open_dir		; $ff2d
jmp file_read_dirent	; $ff30
jmp file_chdir			; $ff33
jmp file_mkdir			; $ff36
jmp file_rmdir			; $ff39
jmp file_get_context	; $ff3c
jmp file_free_context	; $ff3f
jmp file_open_tree		; $ff42
jmp file_walk_tree		; $ff45
jmp sys_launch			; $ff48
jmp sys_reset			; $ff4b
jmp file_size			; $ff4e
jmp file_get_remaining	; $ff51

; Start the segment where the reset vectors are. (nmi, reset, and irq)
.segment "VECTORS" 
.word   shell_main	; NMI will just restart the program.
.word   shell_main	; Reset vector that starts execution.
.word   $02b0		; Interrupt request from VERA.
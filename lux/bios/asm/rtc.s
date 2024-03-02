;----------------------------------------------------------------------
; MCP7940N RTC Driver
;----------------------------------------------------------------------
; (C)2021 Michael Steil, License: 2-clause BSD
.pc02			
.include "../../../lib/inc/zeropage.inc"

;.include "../inc/regs.inc"

; TODO Fix these bullshit direct references with proper includes.
fat32_time_year		= $b000
fat32_time_month	= $b001
fat32_time_day		= $b002
fat32_time_weekday	= $b003
fat32_time_hours	= $b004
fat32_time_minutes	= $b005
fat32_time_seconds	= $b006

_RTC_S_:

.import i2c_read_byte, i2c_write_byte
;.importzp tmp2

.export rtc_get_date_time, rtc_set_date_time
.export rtc_get_nvram, rtc_set_nvram, rtc_check_nvram_checksum

;.export fetch_keymap_from_nvram

;.segment "RTC"

rtc_address            = $6f

nvram_base             = $40
nvram_size             = $20
screen_mode_cksum_addr = nvram_base + $1f


.export sys_update_clock 
.proc sys_update_clock
	; System level once per tick execution.
	inc sys_ticks
	lda sys_ticks
	cmp #60
	bmi @return

	stz sys_ticks
	inc fat32_time_seconds	; seconds
	lda fat32_time_seconds
	cmp #60
	bmi @return

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

	@return:
	rts
	.endproc


;---------------------------------------------------------------
; rtc_set_date_time
;
; Function:  Get the current date and time
;
; Return:    r0L  year
;            r0H  month
;            r1L  day
;            r1H  hours
;            r2L  minutes
;            r2H  seconds
;            r3L  jiffies
;            r3H  weekday
;---------------------------------------------------------------
rtc_get_date_time:
	ldx #rtc_address
	ldy #0
	jsr i2c_read_byte ; 0: seconds
	sta r3L           ; remember seconds register contents
	and #$7f
	jsr bcd_to_bin
	sta r2H

	iny
	jsr i2c_read_byte ; 1: minutes
	jsr bcd_to_bin
	sta r2L

	iny
	jsr i2c_read_byte ; 2: hour (24h mode)
	jsr bcd_to_bin
	sta r1H

	iny
	jsr i2c_read_byte ; 3: day of week 
	and #$07
	sta r3H

	iny
	jsr i2c_read_byte ; 4: day
	jsr bcd_to_bin
	sta r1L

	iny
	jsr i2c_read_byte ; 5: month
	and #$1f
	jsr bcd_to_bin
	sta r0H

	iny
	jsr i2c_read_byte ; 6: year
	jsr bcd_to_bin
	clc
	adc #100
	sta r0L

	; if seconds have changed since we started
	; reading, read everything again
	ldy #0
	jsr i2c_read_byte
	cmp r3L
	bne rtc_get_date_time

	stz r3L ; jiffies
	rts

;---------------------------------------------------------------
; rtc_set_date_time
;
; Function:  Set the current date and time
;
; Pass:      r0L  year
;            r0H  month
;            r1L  day
;            r1H  hours
;            r2L  minutes
;            r2H  seconds
;            r3L  jiffies
;            r3H  weekday
;---------------------------------------------------------------
rtc_set_date_time:
	; stop the clock
	ldx #rtc_address
	ldy #0
    tya
    jsr i2c_write_byte

	ldy #6
	lda r0L
	sec
	sbc #100
	jsr i2c_write_byte_as_bcd ; 6: year

	dey
	lda r0H
	jsr i2c_write_byte_as_bcd ; 5: month

	dey
	lda r1L
	jsr i2c_write_byte_as_bcd ; 4: day

	dey
	lda r3H
	and #$07
	ora #$08                  ; enable battery backup
	jsr i2c_write_byte		; 3: day of week

	dey
	lda r1H
	jsr bin_to_bcd
	jsr i2c_write_byte			; 2: hour

	dey
	lda r2L
	jsr i2c_write_byte_as_bcd ; 1: minutes

	dey
	lda r2H
	jsr bin_to_bcd
	ora #$80           ; start the clock
	jmp i2c_write_byte ; 0: seconds

i2c_write_byte_as_bcd:
	jsr bin_to_bcd
	jmp i2c_write_byte

bcd_to_bin:
	phx
	ldx #$ff
	sec
	sed
@1:	inx
	sbc #1
	bcs @1
	cld
	txa
	plx
	rts

bin_to_bcd:
	phy
	tay
	lda #0
	sed
@loop:	cpy #0
	beq @end
	clc
	adc #1
	dey
	bra @loop
@end:	cld
	ply
	rts

; Inputs: 
; Y = nvram offset
; A = byte value (for write)
;
; Outputs:
; A = byte value (for read)
; C = 0: success
; C = 1: failure
;
; clobbers X
rtc_get_nvram:
	clc
	bra rtc_nvram
rtc_set_nvram:
	sec
rtc_nvram:
	php
	cpy #(nvram_base + nvram_size)
	bcc :+
	plp
	sec
	bra @exit	
:
	pha

	tya
	clc
	adc #nvram_base
	tay
	pla
	ldx #rtc_address
	plp
	bcs @write
	jmp i2c_read_byte
@write:
    jsr i2c_write_byte
	bcs @exit
	cpy #screen_mode_cksum_addr
	bcc @checksum
@good:
	clc
@exit:
	rts
@checksum:
	jsr rtc_check_nvram_checksum
	bcs @exit
	lda tmp2
	jmp i2c_write_byte ; commit the new checksum

; sets Z if equal, C on i2c error
rtc_check_nvram_checksum:
	ldx #rtc_address
	ldy #nvram_base
	stz tmp2
@cksumloop:
	jsr i2c_read_byte
	bcs @exit
	; carry is clear
	adc tmp2
	sta tmp2
	iny
	cpy #screen_mode_cksum_addr
	bcc @cksumloop
	jsr i2c_read_byte
	bcs @exit
	cmp tmp2
	clc
@exit:
	rts


fetch_keymap_from_nvram:
	; Verify NVRAM checksum
	jsr rtc_check_nvram_checksum
	bcs @exit ; I2C error
	bne @exit ; Checksum mismatch

	ldy #0
	jsr rtc_get_nvram
	bcs @exit ; I2C error

	and #1
	beq :+
	clc
	adc #12 ; second profile (plus the #1 from above) = 13
:
	clc
	adc #11 ; layout byte
	tay
	jsr rtc_get_nvram
	bcs @exit ; I2C error
	clc
	rts

@exit:
	lda #0
	rts


.export rtc_init
.proc rtc_init
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
	rts
	.endproc
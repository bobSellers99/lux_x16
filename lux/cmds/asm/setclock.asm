;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/math.inc"
.include "../../../lib/inc/sz.inc"

print_char			= $0303
set_color			= $0307
lux_cmd_str			= $030c

fat32_time_year		= $b000
fat32_time_month	= $b001
fat32_time_day		= $b002
fat32_time_weekday	= $b003
fat32_time_hours	= $b004
fat32_time_minutes	= $b005
fat32_time_seconds	= $b006

.import rtc_set_date_time, rtc_get_date_time

.pc02
.org $3000
.segment "CODE"

jmp setclock_main

param:			.res 16
help_str: 		.byte "Usage: setclock yy mm dd dw hh mm ss",0
set_year:		.byte 0
set_month:		.byte 0
set_day:		.byte 0
set_dw:			.byte 0
set_hour:		.byte 0
set_min:		.byte 0
set_sec:		.byte 0

.proc setclock_help
	ldx #0
	@print:
		lda help_str,x
		beq @return
		jsr print_char
		inx
		bra @print

	@return:
	rts
	.endproc

.export setclock_main 
.proc setclock_main
	szGetNumParams #lux_cmd_str, #' '
	cmp #7
	beq :+ 
	lda #3
	jsr set_color
	jsr setclock_help
	rts

	:
	szGetParam #lux_cmd_str, #param, #1, #' '
	szConvToBcd_A #param
	mathBcdToBin_A
	clc
	adc #100
	sta set_year

	szGetParam #lux_cmd_str, #param, #2, #' '
	szConvToBcd_A #param
	mathBcdToBin_A
	sta set_month

	szGetParam #lux_cmd_str, #param, #3, #' '
	szConvToBcd_A #param
	mathBcdToBin_A
	sta set_day

	szGetParam #lux_cmd_str, #param, #4, #' '
	szConvToBcd_A #param
	mathBcdToBin_A
	sta set_dw

	szGetParam #lux_cmd_str, #param, #5, #' '
	szConvToBcd_A #param
	mathBcdToBin_A
	sta set_hour

	szGetParam #lux_cmd_str, #param, #6, #' '
	szConvToBcd_A #param
	mathBcdToBin_A
	sta set_min

	szGetParam #lux_cmd_str, #param, #7, #' '
	szConvToBcd_A #param
	mathBcdToBin_A
	sta set_sec

	lda set_year
	sta r0L
	lda set_month
	sta r0H
	lda set_day
	sta r1L
	lda set_dw
	sta r3H
	lda set_hour
	sta r1H
	lda set_min
	sta r2L
	lda set_sec
	sta r2H

	jsr rtc_set_date_time

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
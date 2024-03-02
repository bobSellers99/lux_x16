;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.export _META_ASM_ 
_META_ASM_:

.include "../../../lib/inc/defines.inc"
.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/vera_regs.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/math.inc"
.include "../../../lib/inc/sz.inc"
.include "../../../lib/inc/text.inc"
.include "../../../lib/inc/file.inc"


clock_weekday_list:	.byte "Unk",0,"Sun",0,"Mon",0,"Tue",0,"Wed",0,"Thu",0,"Fri",0,"Sat",0
clock_month_list:	.byte "Unk",0,"Jan",0,"Feb",0,"Mar",0,"Apr",0,"May",0,"Jun",0
					.byte "Jul",0,"Aug",0,"Sep",0,"Oct",0,"Nov",0,"Dec",0


.export meta_show_clock
.proc meta_show_clock
	bra @start
		@loc_x:		.byte 0
		@loc_y:		.byte 0

		@print:		.byte 0
	@start:
	lda r0L
	sta @loc_x
	lda r0H
	sta @loc_y

	lda sys_ticks
	beq @do_clock
	rts

	@do_clock:
	lda fat32_time_weekday
	clc
	asl
	asl
	tax
	lda clock_weekday_list,x
	sta @print
	textChar @loc_x, @loc_y, @print, #$b1	
	inx
	lda clock_weekday_list,x
	sta @print
	inc @loc_x
	textChar @loc_x, @loc_y, @print, #$b1	
	inx
	lda clock_weekday_list,x
	sta @print
	inc @loc_x
	textChar @loc_x, @loc_y, @print, #$b1	
	inc @loc_x
	textChar @loc_x, @loc_y, #',', #$b1	

	lda fat32_time_month
	clc
	asl
	asl
	tax
	lda clock_month_list,x
	sta @print
	inc @loc_x
	inc @loc_x
	textChar @loc_x, @loc_y, @print, #$b1	
	inx
	lda clock_month_list,x
	sta @print
	inc @loc_x
	textChar @loc_x, @loc_y, @print, #$b1	
	inx
	lda clock_month_list,x
	sta @print
	inc @loc_x
	textChar @loc_x, @loc_y, @print, #$b1	

	mathBinToBcd_8 fat32_time_day
	inc @loc_x
	inc @loc_x
	textBcd_8 @loc_x, @loc_y, #2, #$b1	
	inc @loc_x
	inc @loc_x
	textChar @loc_x, @loc_y, #',', #$b1	

	mathBinToBcd_8 fat32_time_hours
	inc @loc_x
	inc @loc_x
	textBcd_8 @loc_x, @loc_y, #2, #$b1	
	inc @loc_x
	inc @loc_x
	textChar @loc_x, @loc_y, #':', #$b1	

	mathBinToBcd_8 fat32_time_minutes
	inc @loc_x
	textBcd_8 @loc_x, @loc_y, #2, #$b1	
	rts
	.endproc


.export meta_load_screen
.proc meta_load_screen
	@vram_addr		= ZP24_R0
	@filename		= fat32_ptr

	; This version omits the title and status bars (First and last lines.)
	inc @vram_addr+1
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr 0, Stride 1	
	fileLoad @filename, #vera_data0, #0, #$80
	rts
	.endproc


.export meta_save_screen
.proc meta_save_screen
	@vram_addr		= ZP24_R0
	@filename		= fat32_ptr
	@size			= r1

	; TODO Checks like this (String cannot be zero length.) need to be in the bios
	szLength @filename
	beq @return

	; Open VERA_data0 to point to palette location.
	inc @vram_addr+1
	mem_SET_VRAM_ADDR ZP24_R0, 0, $10	; Addr0, stride 1
	fileSave @filename, #vera_data0, @size, #$80

	@return:
	rts
	.endproc


.export meta_copy_screen
.proc meta_copy_screen
	@vram_addr		= ZP24_R0
	@bank_id		= r0L
	@size			= r1

	@saved_bank		= r0H
	@bank_addr		= r2

	inc @vram_addr+1
	memSet_16_16 #$a000, @bank_addr
	math_ADD_IMM_16 $a000, @size
	lda ram_bank
	sta @saved_bank
	lda @bank_id
	sta ram_bank

	mem_SET_VRAM_ADDR @vram_addr, 0, $10	; Addr0, stride 1
	@loop:
		if_16_eq_16 @bank_addr, @size
			lda @saved_bank
			sta ram_bank
			rts
		:
		lda vera_data0
		sta (@bank_addr)
		math_INC_16 @bank_addr
		bra @loop
	
	rts
	.endproc


.export meta_restore_screen
.proc meta_restore_screen
	@vram_addr		= ZP24_R0
	@bank_id		= r0L
	@size			= r1

	@saved_bank		= r0H
	@bank_addr		= r2

	inc @vram_addr+1
	memSet_16_16 #$a000, @bank_addr
	math_ADD_IMM_16 $a000, @size
	lda ram_bank
	sta @saved_bank
	lda @bank_id
	sta ram_bank

	mem_SET_VRAM_ADDR @vram_addr, 0, $10	; Addr0, stride 1
	@loop:
		if_16_eq_16 @bank_addr, @size
			lda @saved_bank
			sta ram_bank
			rts
		:
		lda (@bank_addr)
		sta vera_data0
		math_INC_16 @bank_addr
		bra @loop

	rts
	.endproc

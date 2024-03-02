;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.pc02
.org $3000
.segment "CODE"

jmp ls_main

.struct dirent           ; FILE             PARTITION
name          .res 256   ; file name        partition name (if FAT32, else empty)
attributes    .byte      ; file attributes  partition type
start         .dword     ; start cluster    start LBA
size          .dword     ; size in bytes    size in sectors
mtime_year    .byte
mtime_month   .byte
mtime_day     .byte
mtime_hours   .byte
mtime_minutes .byte
mtime_seconds .byte
.endstruct

fat32_ptr			= $e7 ;$e8

fat32_dirent		= $b2d8

file_close			= $ff15
file_open_dir		= $ff1b
file_read_dirent	= $ff1e

print_char			= $0303
set_color			= $0307

help_str:			.byte "ls (list short) lists the contents of the current directory.",0
;test_dir:			.byte "/bin/lux",0

ls_help:
	ldx #0
	@print:
		lda help_str,x
		beq @return
		jsr print_char
		inx
		bra @print
	
	@return:
	rts


ls_print_dir:
	bra @start

		@index:		.byte 0
	@start:
	ldx #0
	; Check for hidden file.
;	lda fat32_dirent,x
;	cmp #'.'
;	beq @exit

	; Step to next line.
	lda @index
	cmp #60
	bmi @check_color
	stz @index
	lda #$0d
	jsr print_char

	@check_color:
	; Set up color to display entry.
	lda fat32_dirent + dirent::attributes
	cmp #$10
	beq @color_dir
	cmp #$20
	beq @color_file
	bra @print

	@color_dir:
	lda #$0e
	jsr set_color
	bra @print

	@color_file:
	lda #$01
	jsr set_color
	bra @print

	@print:
		; Step to next line.
		lda @index
		cmp #80
		bmi @cont_print
		stz @index
		lda #$0d
		jsr print_char

		@cont_print:
		inc @index
		lda fat32_dirent,x
		beq @return
		jsr print_char
		inx
		bra @print
	
	@return:
	lda #$20
	jsr print_char
	lda #$20
	jsr print_char

	@exit:
	lda #$01
	jsr set_color
	rts


.export ls_main 
ls_main:
	bra @start

			@context:	.byte 0
	@start:		
	stz @context
;	jsr ls_help
;	rts

	stz fat32_ptr
	stz fat32_ptr+1
    jsr file_open_dir
	sta @context

;	lda #00
;	jsr file_alloc_context
;	sta @context
;	bcc @error
;	jsr file_set_context
;	bcc @error

;	stz fat32_ptr
;	stz fat32_ptr+1
;    jsr file_open_dir
	bcc @error

	@loop:
	jsr file_read_dirent
	bcc @return

	jsr ls_print_dir
	bra @loop

	@return:
	lda @context
	jsr file_close
;	jsr file_free_context
	rts

	@error:
	rts
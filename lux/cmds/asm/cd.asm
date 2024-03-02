;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.include "../../../lib/inc/zeropage.inc"
.include "../../../lib/inc/mem.inc"
.include "../../../lib/inc/math.inc"
.include "../../../lib/inc/sz.inc"

.pc02
.org $3000
.segment "CODE"

jmp cd_main

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

;fat32_ptr			= $e7 ;$e8

fat32_dirent		= $b2d8

file_close			= $ff15
file_chdir			= $ff27
file_open_tree		= $ff21
file_walk_tree		= $ff24

print_char			= $0303
set_color			= $0307
lux_drive_id		= $030b
lux_cmd_str			= $030c
lux_path_str		= $040c

help_str:			.byte "cd command help",0
error_str:			.byte "Directory not found",0
new_dir:			.res 32
.export new_path 
new_path:			.res 256
path_index:			.byte 0

cd_help:
	ldx #0
	@print:
		lda help_str,x
		beq @return
		jsr print_char
		inx
		bra @print
	
	@return:
	rts


cd_error:
	ldx #0
	@print:
		lda #$04
		jsr set_color

		lda error_str,x
		beq @return
		jsr print_char
		inx
		bra @print

		lda #$01
		jsr set_color
	@return:
	rts


.export cd_get_next_dir
cd_get_next_dir:
	@loop:
		cpx #0
		beq @return
		dex
		lda new_path,x
		cmp #'/'
		bne @loop

	@return:
	rts



.export cd_reverse_path
cd_reverse_path:
	; Add drive letter to path str.
	ldy #0
	lda lux_drive_id
	clc
	adc #$40
	sta lux_path_str,y
	lda #$3a
	iny
	sta lux_path_str,y
	iny

	; Index to last dir entry in the list.
	ldx #$ff
	jsr cd_get_next_dir	; Get to end of dir list.
	jsr cd_get_next_dir	; index to last entry.
	jsr cd_get_next_dir	; index to first needed entry.

	@loop:
		lda new_path,x
		sta lux_path_str,y
		inx
		iny
		lda new_path,x
		cmp #'/'
		bne @loop

	jsr cd_get_next_dir
	cpx #0
	beq @return
	
	jsr cd_get_next_dir
	bra @loop

	@return:
	lda #' '
	sta lux_path_str,y ; Space at end of line.
	iny
	lda #0
	sta lux_path_str,y	; Null terminator.
	rts


.export cd_print_dir 
cd_print_dir:
	ldx #0
	ldy path_index
	lda #'/'
	sta new_path,y
	iny
	@print:
		lda fat32_dirent,x
		beq @return
		sta new_path,y
		inx
		iny
		bra @print
	
	@return:
	sty path_index
	rts


set_def_path:
	; Add drive letter to path str.
	ldy #0
	lda lux_drive_id
	clc
	adc #$40
	sta lux_path_str,y
	lda #':'
	iny
	sta lux_path_str,y
	lda #'/'
	iny
	sta lux_path_str,y
	lda #' '
	iny
	sta lux_path_str,y
	lda #0
	iny
	sta lux_path_str,y
	rts


.export cd_main
cd_main:
	bra @start

			@context:		.byte 0
	@start:		
	stz @context
;	lda #00
;	jsr file_alloc_context
;	sta @context
;	bcc @error
;	jsr file_set_context
;	bcc @error

	szGetParam #lux_cmd_str, #new_dir, #1, #' '
	
	lda #<new_dir
	sta fat32_ptr
	lda #>new_dir
	sta fat32_ptr+1
	jsr file_chdir
	bcc @error

;	jsr file_close
;	lda @context
;	jsr file_free_context

	; Get current directory tree.
;	lda #00
;	jsr file_alloc_context
;	sta @context
;	bcc @error
;	jsr file_set_context
;	bcc @error

	jsr file_open_tree
	sta @context

	@loop:
	jsr file_walk_tree
	jsr cd_print_dir
	lda fat32_dirent
	cmp #'/'
	bne @loop
	
	jsr cd_reverse_path
	lda @context
	jsr file_close
;	jsr file_free_context
	rts

	@error:
;	jsr file_close
;	lda @context
;	jsr file_free_context

	lda lux_path_str
	bne @return

	jsr set_def_path
	rts

	@return:
	jsr cd_error
	rts

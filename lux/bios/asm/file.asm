;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02

.include "../../../lib/inc/zeropage.inc"
.include "../inc/fat32.inc"
.include "../inc/fat32_regs.inc"
.include "../inc/fat32.inc"

_FILE_ASM_:


cbdos_flags			= $0268

fat32_file_size		= $b3fe	; 32 bit file size. DO NOT WRITE
fat32_file_pos		= $b402 ; 32 bit file pos. DO NOT WRITE

.import i2c_read_byte, i2c_write_byte


.export file_activity_light
.proc file_activity_light
	; A holds the value to set the activity light to.
	php	; Save processor status to save carry flag.
	beq @set_led
	ldx #$10

	@set_led:
	stx cbdos_flags

	ldx #$42
	ldy #$5
	jsr i2c_write_byte
	plp
	rts
	.endproc


.export file_open
.proc file_open
	@context		= r0

	; Set activity light
	lda #$80
	jsr file_activity_light

   	; Allocate context.
	lda #$00
	jsr fat32_alloc_context
	bcc @close_before_use
	sta @context

	; Set the current context
	jsr fat32_set_context
	bcc @close_before_use

	; Open file.
	jsr fat32_open
	bcs @return

	@close_before_use:
	lda @context
	jsr file_close
    
	@return:
	lda @context
	rts
    .endproc


.export file_create
.proc file_create
	@context		= r0

	; Set activity light
	lda #$80
	jsr file_activity_light

   	; Allocate context.
	lda #$00
	jsr fat32_alloc_context
	bcc @close_before_use
	sta @context

	; Set the current context
	jsr fat32_set_context
	bcc @close_before_use

	; Create file.
	sec ; Carry set = overwite existing file.
	jsr fat32_create
	bcs @return

	@close_before_use:
	lda @context
	jsr file_close
    
	@return:
	lda @context
	rts
    .endproc


.export file_seek
.proc file_seek
	jsr fat32_seek
	rts
	.endproc


.export file_size
.proc file_size
	rts
	.endproc


.export file_get_remaining
.proc file_get_remaining
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
	.endproc


.export file_read
.proc file_read
	jsr fat32_read
	rts
	.endproc


.export file_write
.proc file_write
	jsr fat32_write
	rts
	.endproc


.export file_close
.proc file_close
	; file context is passed in A.
	pha
	jsr fat32_set_context
	jsr fat32_close
	pla
	jsr fat32_free_context

	; Turn off activity light
	lda #0
	jsr file_activity_light
	rts
	.endproc


.export file_find_dirent
.proc file_find_dirent
	@context		= r0L
	@file_type		= r0H

	; Set activity light
	lda #$80
	jsr file_activity_light

   	; Allocate context.
	lda #$00
	jsr fat32_alloc_context
	bcc @close_before_use
	sta @context

	; Set the current context
	jsr fat32_set_context
	bcc @close_before_use

	; Create file.
	lda @file_type
	jsr fat32_find_dirent
	bcs @return

	@close_before_use:
	lda @context
	jsr fat32_set_context
	jsr fat32_close
	lda @context
	jsr fat32_free_context
    clc

	@return:
	lda @context
	jsr fat32_set_context
	jsr fat32_close
	lda @context
	jsr fat32_free_context
	rts
	.endproc


.export file_open_dir
.proc file_open_dir
	@context		= r0L

	; Set activity light
	lda #$80
	jsr file_activity_light

   	; Allocate context.
	lda #$00
	jsr fat32_alloc_context
	bcc @close_before_use
	sta @context

	; Set the current context
	jsr fat32_set_context
	bcc @close_before_use

	; Open tree.
	jsr fat32_open_dir
	bcs @return

	@close_before_use:
	lda @context
	jsr fat32_close

	@return:
	lda @context
	rts
	.endproc


.export file_read_dirent
.proc file_read_dirent
	jsr fat32_read_dirent
	rts
	.endproc


.export file_open_tree
.proc file_open_tree
	@context		= r0L

	; Set activity light
	lda #$80
	jsr file_activity_light

   	; Allocate context.
	lda #$00
	jsr fat32_alloc_context
	bcc @close_before_use
	sta @context

	; Set the current context
	jsr fat32_set_context
	bcc @close_before_use

	; Open tree.
	jsr fat32_open_tree
	bcs @return

	@close_before_use:
	lda @context
	jsr fat32_close
    
	@return:
	lda @context
	rts
	.endproc


.export file_walk_tree
.proc file_walk_tree
	jsr fat32_walk_tree
	rts
	.endproc


.export file_chdir
.proc file_chdir
	jsr fat32_chdir
	rts
	.endproc


.export file_mkdir
.proc file_mkdir
	jsr fat32_mkdir
	rts
	.endproc


.export file_rmdir
.proc file_rmdir
	jsr fat32_rmdir
	rts
	.endproc


.export file_rename
.proc file_rename
	jsr fat32_rename
	rts
	.endproc


.export file_set_attribute
.proc file_set_attribute
	jsr fat32_set_attribute
	rts
	.endproc


.export file_delete
.proc file_delete
	jsr fat32_delete
	rts
	.endproc

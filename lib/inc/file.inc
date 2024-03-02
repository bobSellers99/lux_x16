;Copyright 2024 by Robert Sellers under the 2 clause BSD License.

.ifndef _FILE_ASM_

.macro fileOpen fname
	.ifnblank fname
	    memSet_16_16 fname, fat32_ptr 
	.endif
	jsr file_open
    .endmacro


.macro fileCreate fname
	.ifnblank fname
	    memSet_16_16 fname, fat32_ptr 
	.endif
    jsr file_create
    .endmacro


.macro fileSeek offset
    memSet_16_16 offset, fat32_size 
    jsr file_seek
    .endmacro


.macro fileRead dest, vram_flag
	.ifnblank dest
	    memSet_16_16 dest, fat32_ptr 
	    lda vram_flag
	    sta kernal_ptr
	.endif
    jsr file_read
    .endmacro


.macro fileWrite source, vram_flag
    memSet_16_16 source, fat32_ptr 
    lda vram_flag
    sta kernal_ptr
    jsr file_write
    .endmacro


.macro fileClose context
    lda context
    jsr file_close
    .endmacro


.macro fileLoad filename, loc, offset, vram_flag
	fileOpen filename
    bcc :+
	pha	; Hold context id for closing.
	fileSeek offset
	jsr file_get_remaining
	fileRead loc, vram_flag
	pla
;    bcc :+
	jsr file_close
	:
	.endmacro


.macro fileSave filename, loc, length, vram_flag
	fileCreate filename
    bcc :+
	pha	; Hold context id for closing.
	memSet_16_16 length, fat32_size
	fileWrite loc, vram_flag
	pla
;    bcc :+
	jsr file_close
	:
	.endmacro


.macro fileFindDirent fname, file_type
    memSet_16_16 fname, fat32_ptr
    lda file_type
    sta r0H
    jsr file_find_dirent
    .endmacro


.endif
;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02

.ifndef _META_ASM_

meta_show_clock			= $9c80
meta_load_screen		= $9c83
meta_save_screen		= $9c86
meta_copy_screen		= $9c89
meta_restore_screen		= $9c8c
	
	
.macro metaShowClock loc_x, loc_y
	lda loc_x
	sta r0L
	lda loc_y
	sta r0H
	jsr meta_show_clock
	.endmacro


.macro metaLoadScreen vram_loc, filename
	memSet_IMM_24 vram_loc, ZP24_R0
	memSet_16_16 filename, fat32_ptr
	jsr meta_load_screen
	.endmacro


.macro metaSaveScreen vram_loc, filename, size
	memSet_IMM_24 vram_loc, ZP24_R0
	memSet_16_16 filename, fat32_ptr
	memSet_16_16 size, r1
	jsr meta_save_screen
	.endmacro


.macro metaCopyScreen vram_loc, ram_bank, size
	memSet_IMM_24 vram_loc, ZP24_R0
	lda ram_bank
	sta r0L
	memSet_16_16 size, r1
	jsr meta_copy_screen
	.endmacro


.macro metaRestoreScreen vram_loc, ram_bank, size
	memSet_IMM_24 vram_loc, ZP24_R0
	lda ram_bank
	sta r0L
	memSet_16_16 size, r1
	jsr meta_restore_screen
	.endmacro

.endif				
;Copyright 2024 by Robert Sellers under the 2 clause BSD License.

.ifndef _FILE_ASM_


.import file_open
.import file_create
.import file_seek
.import file_size
.import file_get_remaining
.import file_read
.import file_write
.import file_close
.import file_find_dirent
.import file_open_dir
.import file_read_dirent
.import file_open_tree
.import file_walk_tree
.import file_chdir
.import file_mkdir
.import file_rmdir
.import file_rename
.import file_set_attribute
.import file_delete


.macro memSet_16_16 source, dest
	.if (.match (.left (1, {source}), #))
   	    lda #<(.right (.tcount ({source})-1, {source}))
   	    sta dest
   	    lda #>(.right (.tcount ({source})-1, {source}))
   	    sta dest+1
   	.else
   	    lda source
   	    sta dest
   	    lda source+1
   	    sta dest+1
	.endif		
	.endmacro	


.macro fileOpen fname
    memSet_16_16 fname, fat32_ptr 
	jsr file_open
    .endmacro


.macro fileCreate fname
    memSet_16_16 fname, fat32_ptr 
    jsr file_create
    .endmacro


.macro fileRead dest, vram_flag
    bcc :+
    memSet_16_16 dest, fat32_ptr 
    lda vram_flag
    sta kernal_ptr
    jsr file_read
    :
    .endmacro


.macro fileWrite source, vram_flag
    bcc :+
    memSet_16_16 source, fat32_ptr 
    lda vram_flag
    sta kernal_ptr
    jsr file_write
    :
    .endmacro


.macro fileClose context
    bcc :+
    lda context
    jsr file_close
    :
    .endmacro


.endif
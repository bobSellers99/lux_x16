;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

.ifndef _SPRITE_ASM_

sprite_set_palette	= $9d00
sprite_set			= $9d03
sprite_init			= $9d06
sprite_flip  		= $9d09
sprite_reset  		= $9d0c


.macro sprite_set_palette id, z_order, pal_page
	lda id
	sta r0L	
	lda z_order
	sta r0H
	lda pal_page
	sta r1L
	jsr sprite_set_palette
	.endmacro


.macro sprite_set id, z_order, loc_x, loc_y
	lda id
	sta r0L
	lda z_order
	sta r0H
	memSet_16_16 loc_x, r1
	memSet_16_16 loc_y, r2 
	jsr sprite_set
	.endmacro


.macro sprite_init id, bpp, height, width, palette_offset
	lda id
	sta r0L
	lda bpp
	sta r0H
	lda height
	sta r1L
	lda width
	sta r1H
	lda palette_offset
	sta r2L
	jsr sprite_init
	.endmacro


.macro sprite_flip id, flip
	memSet_8_16 id, r0
	lda flip
	sta r1L
	jsr sprite_flip
	.endmacro

.endif

;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

SZ_EDIT_MAX		= 0
SZ_EDIT_LEN		= 1
SZ_EDIT_X		= 2
SZ_EDIT_Y		= 3
SZ_EDIT_TEXT	= 4


.macro szEditGetParam source, param, dest
	memSet_16_16 source, zp_ind2
	phy
	ldy param ; Position of param in meta.
	lda (zp_ind2),y
	.ifnblank dest
	sta dest
	.endif
	ply
	.endmacro


.macro szEditSetParam source, param
	memSet_16_16 source, zp_ind2
	phy
	ldy param ; Position of param in meta.
	sta (zp_ind2),y
	ply
	.endmacro


.macro szEditIncParam source, param
	memSet_16_16 source, zp_ind2
	phy
	ldy param ; Position of param in meta.
	lda (zp_ind2),y
	inc
	sta (zp_ind2),y
	ply
	.endmacro


.macro szEditDecParam source, param
	memSet_16_16 source, zp_ind2
	phy
	ldy param ; Position of param in meta.
	lda (zp_ind2),y
	dec
	sta (zp_ind2),y
	ply
	.endmacro


.macro szEditGetAddr source, dest
    memSet_16_16 source, dest
    math_ADD_8_16 #SZ_EDIT_TEXT, dest
    .endmacro

.ifndef _SZ_ASM_

sz_length			= $9e80
sz_copy				= $9e83
sz_cat				= $9e86
sz_get_param		= $9e89
sz_get_num_params	= $9e8c
sz_conv_to_bcd_8	= $9e8f
sz_conv_to_bcd_16	= $9e92
sz_conv_to_bcd_24	= $9e95
sz_edit_init		= $9e98
sz_char_to_bin		= $9e9b
sz_edit_set_bcd_8	= $9e9e
sz_edit_set_bcd_16	= $9ea1


.macro szLength source
    memSet_16_16 source, zp_ind
	jsr sz_length 
    .endmacro


.macro szCopy to_add, dest
    memSet_16_16 to_add, zp_ind
    memSet_16_16 dest, zp_ind2
	jsr sz_copy 
    .endmacro


.macro szCat to_add, dest
    memSet_16_16 to_add, zp_ind
    memSet_16_16 dest, zp_ind2
	jsr sz_cat 
    .endmacro


.macro szGetParam source, dest, index, token
    memSet_16_16 source, zp_ind
    memSet_16_16 dest, zp_ind2
    lda index
    sta r0L
    lda token
    sta r0H
	jsr sz_get_param 
    .endmacro


.macro szGetNumParams source, token
    memSet_16_16 source, zp_ind
    lda token
    sta r0L
	jsr sz_get_num_params 
    .endmacro


.macro szConvToBcd_A source
    memSet_16_16 source, zp_ind
	jsr sz_conv_to_bcd_8 
	; returns the output in A.
    .endmacro


.macro szConvToBcd_8 source
    memSet_16_16 source, zp_ind
	jsr sz_conv_to_bcd_8 
	; returns the output in A.
    .endmacro


.macro szConvToBcd_16 source
    memSet_16_16 source, zp_ind
	jsr sz_conv_to_bcd_16 
	; returns digits 3 and 4 in A.
	; returns the full number in zp_result (16 bit)
    .endmacro


.macro szConvToBcd_24 source
    memSet_16_16 source, zp_ind
	jsr sz_conv_to_bcd_24 
	; returns digits 5 and 6 in A.
	; returns the full number in zp_result (24 bit)
    .endmacro


.macro szEditInit source, max, len, char_x, char_y, default
	memSet_16_16 source, zp_ind
	lda max
	sta r0L
	lda len
	sta r0H
	lda char_x
	sta r1L
	lda char_y
	sta r1H
	.ifnblank default
		memSet_16_16 default, zp_ind2
	.else
		memSet_8_16 #0, zp_ind2
	.endif
	jsr sz_edit_init
	.endmacro


.macro szCharToBin
	jsr sz_char_to_bin 
    .endmacro


.macro szEditSetBcd_8 source, num_chars
	memSet_16_16 source, zp_ind
	lda num_chars
	sta r0L
	jsr sz_edit_set_bcd_8 
    .endmacro

.macro szEditSetBcd_16 source, num_chars
	memSet_16_16 source, zp_ind
	lda num_chars
	sta r0L
	jsr sz_edit_set_bcd_16 
    .endmacro


.endif

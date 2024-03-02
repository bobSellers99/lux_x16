;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

.ifndef _TEXT_ASM_

text_char			= $9e00
text_hex_8			= $9e03
text_string			= $9e06
text_blank  		= $9e09
text_set_color		= $9e0c
text_command_line	= $9e0f
text_bcd_8			= $9e12
text_bcd_16			= $9e15
text_init			= $9e18
text_string_edit	= $9e1b


.macro textChar char_x, char_y ,character ,color
	lda char_x
	sta r0L
	lda char_y
	sta r0H
	lda character
	sta r1L
	lda color
	sta r1H
	jsr text_char 
	.endmacro


.macro textHex_8 char_x, char_y ,character ,color
	lda char_x
	sta r0L
	lda char_y
	sta r0H
	lda character
	sta r1L
	lda color
	sta r1H
	jsr text_hex_8 
	.endmacro


.macro textString char_x, char_y ,string_addr ,color
	lda char_x
	sta r0L
	lda char_y
	sta r0H
	memSet_16_16 string_addr, zp_ind	
	lda color
	sta r1H
	jsr text_string 
	.endmacro


.macro textBlank char_x, char_y, num_chars, color
	lda char_x
	sta r0L
	lda char_y
	sta r0H
	lda num_chars
	sta r1L
	lda color
	sta r1H
	jsr text_blank 
	.endmacro


.macro textSetColor char_x, char_y, num_chars, color
	lda char_x
	sta r0L
	lda char_y
	sta r0H
	lda num_chars
	sta r1L
	lda color
	sta r1H
	jsr text_set_color 
	.endmacro


; Prints a multi line string.
.macro textCommandLine char_x, char_y ,string_addr ,color
	lda char_x
	sta r0L
	lda char_y
	sta r0H
	memSet_16_16 string_addr, zp_ind	
	lda color
	sta r1H
	jsr text_command_line 
	.endmacro


.macro textBcd_8 char_x, char_y, num_chars, color
	lda char_x
	sta r0L
	lda char_y
	sta r0H
	lda num_chars
	sta r1L
	lda color
	sta r1H
	jsr text_bcd_8 
	.endmacro	


.macro textBcd_16 char_x, char_y, num_chars, color
	lda char_x
	sta r0L
	lda char_y
	sta r0H
	lda num_chars
	sta r1L
	lda color
	sta r1H
	jsr text_bcd_16 
	.endmacro	


.macro textStringEdit source_sze, color
	memSet_16_16 source_sze, zp_ind
	lda color
	sta r1H
	jsr text_string_edit
	.endmacro

.endif


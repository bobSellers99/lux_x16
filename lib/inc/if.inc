;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.pc02

; Depreciated, don't use.
.macro if_funct_rts action, function
	cmp action
	bne :+
	jsr function
	rts
	:
	.endmacro	


; Depreciated, don't use.
.macro if_funct_else action, function
	cmp action
	bne :+
	jsr function
	:
	.endmacro	


; NOTE: if_case and if_case_else are the same,
; and they are equivelent to if_A_eq_IMM  
.macro if_case_else value
	cmp value
	bne :+
	.endmacro	


.macro if_case value
	cmp value
	bne :+
	.endmacro	

;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

_FIND_ASM_:
.include "../inc/shell.inc"

find_bin_str:		.byte "/bin/",0
find_bin_dir_str:	.byte "/",0

.export find_search_str 
find_search_str:	.res 256
find_search_path:	.res 256


.export find_bin 
.proc find_bin
		@context	= r0L
		@file_type	= r0H

	stz @context
	; Find the file in the /bin directory.
	szCopy #find_bin_str, #find_search_str
	szCat #term_cmd_word, #find_search_str

	lda #$80	; Find files only
	sta @file_type
	fileFindDirent #find_search_str, @file_type
;	bcc @return
;	fileClose @context

;	@return:
	rts	
	.endproc


.export find_bin_dir 
.proc find_bin_dir
		@context	= r0L
		@file_type	= r0H

	stz @context
	; Find the file in the /bin directory.
	szCopy #find_bin_str, #find_search_str
	szCat #term_cmd_word, #find_search_str

	lda #$00	; Find directories only
	sta @file_type
	fileFindDirent #find_search_str, @file_type
;	bcc @return
;	fileClose @context

;	@return:
	rts	
	.endproc


.export find_local 
.proc find_local
		@context	= r0L
		@file_type	= r0H

	stz @context
	; Find the file in the local directory.
	szCopy #term_cmd_word, #find_search_str

	lda #$80	; Find files only
	sta @file_type
	fileFindDirent #find_search_str, @file_type
;	bcc @return
;	fileClose @context

;	@return:
	rts	
	.endproc

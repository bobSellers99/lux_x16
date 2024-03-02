;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.include "../../../lib/inc/zeropage.inc"

.import ctl_process
.import ctl_set_state
.import ctl_delete
.import ctl_create
.import ctl_init
.import ctl_jump_abs_ind
.import ctl_debug

.import ctl_edit_process
.import ctl_edit_begin

.import meta_show_clock
.import meta_load_screen
.import meta_save_screen
.import meta_copy_screen
.import meta_restore_screen

.import sprite_set_palette
.import sprite_set
.import sprite_init
.import sprite_flip
.import sprite_reset

.import math_shift_down_A
.import math_shift_down_16
.import math_shift_down_24
.import math_shift_up_A
.import math_shift_up_16
.import math_mult_8_8
.import math_mult_16_16
.import math_bcd_8_to_bin_8
.import math_bcd_16_to_bin_16
.import math_bcd_24_to_bin_16
.import math_bcd_32_to_bin_24
.import math_bcd_48_to_bin_32
.import math_bin_to_bcd_8
.import math_bin_to_bcd_16

.import sz_length
.import sz_copy
.import sz_cat
.import sz_get_param
.import sz_get_num_params
.import sz_conv_to_bcd_8
.import sz_conv_to_bcd_16
.import sz_conv_to_bcd_24
.import sz_edit_init
.import sz_char_to_bin
.import sz_edit_set_bcd_8
.import sz_edit_set_bcd_16

.import text_char
.import text_hex_8
.import text_string
.import text_blank
.import text_set_color
.import text_command_line
.import text_bcd_8
.import text_bcd_16
.import text_init
.import text_string_edit

; Start the segments where library 1's functions are linked.

.segment "LINKS_6"
jmp ctl_process				;$9c00
jmp ctl_set_state			;$9c03
jmp ctl_delete				;$9c06
jmp ctl_create				;$9c09
jmp ctl_init				;$9c0c
jmp ctl_jump_abs_ind		;$9c0f
jmp ctl_debug				;$9c02

.segment "LINKS_5"
jmp ctl_edit_process		;$9c40
jmp ctl_edit_begin			;$9c43

.segment "LINKS_7" ;Meta library
jmp meta_show_clock			;$9c80
jmp meta_load_screen		;$9c83
jmp meta_save_screen		;$9c86
jmp meta_copy_screen		;$9c89
jmp meta_restore_screen		;$9c8c

.segment "LINKS_4"
jmp sprite_set_palette   	;$9d00
jmp sprite_set  			;$9d03
jmp sprite_init 		 	;$9d06
jmp sprite_flip			    ;$9d09
jmp sprite_reset		    ;$9d0c

.segment "LINKS_3"
jmp math_shift_down_A   	;$9d80
jmp math_shift_down_16  	;$9d83
jmp math_shift_down_24  	;$9d86
jmp math_shift_up_A		    ;$9d89
jmp math_shift_up_16	    ;$9d8c
jmp math_mult_8_8		    ;$9d8f
jmp math_mult_16_16			;$9d92
jmp math_bcd_8_to_bin_8		;$9d95
jmp math_bcd_16_to_bin_16	;$9d98
jmp math_bcd_24_to_bin_16	;$9d9b
jmp math_bcd_32_to_bin_24	;$9d9e
jmp math_bcd_48_to_bin_32	;$9da1
jmp math_bin_to_bcd_8 		;$9da4
jmp math_bin_to_bcd_16		;$9da7

.segment "LINKS_2"
jmp text_char				;$9e00
jmp text_hex_8  			;$9e03
jmp text_string				;$9e06
jmp text_blank  			;$9e09
jmp text_set_color			;$9e0c
jmp text_command_line		;$9e0f
jmp text_bcd_8  			;$9e12
jmp text_bcd_16 			;$9e15
jmp text_init				;$9e18
jmp text_string_edit		;$9e1b

.segment "LINKS_1"
jmp sz_length				;$9e80
jmp sz_copy					;$9e83
jmp sz_cat					;$9e86
jmp sz_get_param			;$9e89
jmp sz_get_num_params		;$9e8c
jmp sz_conv_to_bcd_8		;$9e8f
jmp sz_conv_to_bcd_16		;$9e92
jmp sz_conv_to_bcd_24		;$9e95
jmp sz_edit_init			;$9e98
jmp sz_char_to_bin			;$9e9b
jmp sz_edit_set_bcd_8		;$9e9e
jmp sz_edit_set_bcd_16		;$9ea1

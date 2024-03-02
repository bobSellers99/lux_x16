;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

; Zero Page
; Zero page scratch registers. $00 to $1f
;ram_bank            = $00
;rom_bank			= $01
;R0					= $02
;R1					= $04
;R2					= $06
;R3					= $08
;R4					= $0a
;R5					= $0c
;R6					= $0e
;R7					= $10
;R8					= $12
;R9					= $14
;R10					= $16
;R11					= $18
;R12					= $1a
;; regs.inc overlaps to $21
;zp_ind				= $22;$23
;zp_ind2				= $24;$25
;ZP24_R0				= $26;$27;$28
;ZP24_R1				= $29;$2a;$2b

; System uses $e0 to $ff
;ctl_focus		    = $d0
;ctl_state		    = $d1
;ctl_addr		    = $d2;$e3		
;ctl_index		    = $d4

; System uses $e0 to $ff
;kernal_ptr 			= $e0;e1
;fat32_ptr			= $e7;e8
;fat32_size			= $e9;ea

;fat32_param32       = $f0 ;$f1;$f2;$f3
;fat32_offset        = $f4 ;$f5
;sys_rotor           = $f6
;sys_ticks           = $f7
;scan_code           = $f8
;kyb_ascii           = $f9
;kyb_modifiers       = $fa
;mouse_btns          = $fb
;mouse_x		    	= $fc;$7d
;mouse_y		    	= $fe;$7f

;day_of_week			= $21

cbdos_flags         = $0268

; TODO pass this through zero page.
fat32_time_year		= $b000
fat32_time_month	= $b001
fat32_time_day		= $b002
fat32_time_weekday	= $b003
fat32_time_hours	= $b004
fat32_time_minutes	= $b005
fat32_time_seconds	= $b006

fat32_size			= $b3e7	; 32 bit size param for calls.

; VRAM memory map is in the local include file.

; System calls to BIOS_BANK.
file_open       	= $ff00
file_create 	    = $ff03
file_seek			= $ff06
file_size			= $ff09
file_get_remaining	= $ff0c
file_read			= $ff0f
file_write			= $ff12
file_close  		= $ff15

file_find_dirent	= $ff18
file_open_dir		= $ff1b
file_read_dirent	= $ff1e
file_open_tree		= $ff21
file_walk_tree		= $ff24
file_chdir			= $ff27
file_mkdir      	= $ff2a
file_rmdir  		= $ff2d
file_rename			= $ff30
file_set_attribute	= $ff33
file_delete			= $ff36

sys_release   		= $ff39
sys_launch			= $ff3c
sys_reset			= $ff3f
sys_set_event		= $ff42
sys_update_clock	= $ff45
sys_update_mouse	= $ff48
sys_update_key		= $ff4b
sys_translate_key	= $ff4e
sys_power_off		= $ff51

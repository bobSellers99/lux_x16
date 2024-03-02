;Copyright 2024 by Robert Sellers under the 2 clause BSD License.

; Zero Page memory references.

; Bank control registers.
ram_bank			= $00   ; Current RAM bank.
rom_bank			= $01   ; Current ROM bank.

; Zero page scratch registers. $00 to $1f
r0					= $02;$03
r0L					= $02
r0H					= $03
r1					= $04;$05
r1L					= $04
r1H					= $05
r2					= $06;$07
r2L					= $06
r2H					= $07
r3					= $08;$09
r3L					= $08
r3H					= $09
r4					= $0a;$0b
r4L					= $0a
r4H					= $0b
r5					= $0c;$0d
r5L					= $0c
r5H					= $0d
r6					= $0e;$0f
r6L					= $0e
r6H					= $0f
r7					= $10;$11
r7L					= $10
r7H					= $11
zp_ind				= $12;$13
zp_ind2				= $14;$15
ZP24_R0				= $16;$17;$18
ZP24_R1				= $19;$1a;$1b
zp_oper1			= $1c;$1d;
zp_oper2			= $1e;$1f;
zp_result			= $20;$21;$22;$23
zp_temp32			= $24;$25;$26;$27

; Application space from $30 to $cf


; System uses $d0 to $ff
ctl_focus			= $d0
ctl_state			= $d1
ctl_addr		    = $d2;$d3		
ctl_index		    = $d4
ctl_loop		    = $d5;$d6		

kernal_ptr 			= $e0;$e1
bank_save			= $e2		; Depreciated, use "orig_bank" below.
fat32_bufptr		= $e3;$e4
fat32_lfn_bufptr	= $e5;$e6
fat32_ptr			= $e7;$e8
fat32_ptr2			= $e9;$ea
tmp2				= $eb
;orig_bank			= $ec
;dest_bank			= $ed

fat32_param32		= $f0 ;$f1;$f2;$f3
fat32_offset		= $f4 ;$f5
sys_rotor			= $f6
sys_ticks			= $f7
scan_code			= $f8
kyb_ascii			= $f9
kyb_modifiers		= $fa
mouse_btns			= $fb
mouse_x				= $fc;$fd
mouse_y				= $fe;$ff

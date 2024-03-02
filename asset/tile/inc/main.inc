;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02
.include "../../../lib/inc/lib.inc"

; Application specific includes.
;.include "../inc/main.inc"
.include "../inc/suspend.inc"
.include "../inc/vera.inc"
.include "../inc/loop.inc"
.include "../inc/menu1.inc"
.include "../inc/area.inc"
.include "../inc/edit.inc"
.include "../inc/data.inc"
.include "../inc/palette.inc"

; TODO Using a word is error prone, should use a text string or the file name.
; Or perhaps... a unique integer from fat32
application_key		= $01 ; Unique application key.

.ifndef _MAIN_ASM_

.import data_start
.import data_crc
.import data_key

.import main_run
.import main_txt_title

.endif

; VERA VRAM memory map.
VRAM_spritemap		= $1fc00 ; Fixed address range.	
VRAM_palette		= $1fa00 ; Fixed address range.
VRAM_psg			= $1f9c0 ; Fixed address range.
VRAM_mouse			= $1f400 ; ($1f800) (1K) System sprites	
VRAM_textdata		= $1e000 ; ($1efff) tile base (Where tiles are stored.)
VRAM_textmap    	= $1c000 ; Map base (Where the 2 byte links are stored.)
VRAM_tilemap		= $18000 ; ($1bfff) (16K) 128x64 at 2 bytes per entry.    
VRAM_tiledata		= $17800 ; ($17bff) (1K) 128 tiles at 8x8 at 1bpp
VRAM_borders		= $13000 ; ($16fff) (16K) Border sprites for editor. 	

VRAM_areadata       = $00000 ; ($12fff) (77K)

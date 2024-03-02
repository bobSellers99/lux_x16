;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

.include "../../../lib/inc/lib.inc"

;.include "../inc/main.inc"
.include "../inc/vera.inc"
.include "../inc/edit.inc"
.include "../inc/find.inc"
.include "../inc/term.inc"
.include "../inc/history.inc"

.ifndef _MAIN_ASM_

.import lux_drive_id
.import lux_cmd_str
.import lux_path_str
.import main_run

.endif

; VERA VRAM memory map.
VRAM_spritemap		= $1fc00
VRAM_palette		= $1fa00
VRAM_psg			= $1f9c0
VRAM_mouse			= $1f400
VRAM_textdata		= $1e000 ; tile base (Where tiles are stored.)
VRAM_textmap		= $1c000 ; Map base (Where the 2 byte links are stored.)
VRAM_history		= $1b000 ; Command history. 4K

;VSYNC_BIT			= $01
;VSYNC_LINE_BIT		= $03
;BIOS_BANK			= 0
;FAT32_BANK  		= 1


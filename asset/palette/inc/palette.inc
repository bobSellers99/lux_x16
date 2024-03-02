;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

.include "../../../lib/inc/lib.inc"

; Application specific includes.
.include "../inc/main.inc"
.include "../inc/vera.inc"
.include "../inc/loop.inc"
.include "../inc/menu1.inc"
.include "../inc/area.inc"
.include "../inc/edit.inc"

; VERA VRAM memory map.
VRAM_spritemap		= $1fc00
VRAM_palette		= $1fa00
VRAM_psg			= $1f9c0
VRAM_mouse			= $1f400
VRAM_textdata		= $1e000 ; tile base (Where tiles are stored.)
VRAM_textmap    	= $1c000 ; Map base (Where the 2 byte links are stored.)
;VRAM_spritedata 	= $1b000 ; ($1bfff) (4K)

VRAM_tilemap		= $02000 ; ($02fff) (4K) (64x32 at 2 bytes per entry.)    
VRAM_tiledata		= $00000 ; ($01fff) (8K) (256 tiles at 16x16 at 1bpp)

; Tile mode and text.
; VRAM_xxxxdata is where the body of the text/tile data is stored. For tile
; mode, this can be huge, as 1024 tiles are supported with a maximum size 
; of 
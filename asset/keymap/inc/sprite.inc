;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

.include "../../../lib/inc/lib.inc"

; Application specific includes.
.include "../inc/main.inc"
.include "../inc/vera.inc"
.include "../inc/loop.inc"
.include "../inc/menu1.inc"
.include "../inc/data.inc"


; VERA VRAM memory map.
VRAM_spritemap		= $1fc00
VRAM_palette		= $1fa00
VRAM_psg			= $1f9c0
VRAM_mouse			= $1f400
VRAM_textdata		= $1e000 ; tile base (Where tiles are stored.)
VRAM_textmap    	= $1c000 ; Map base (Where the 2 byte links are stored.)
;VRAM_spritedata 	= $1b000 ; ($1bfff) (4K)
;Blank space        = $18c00

    ; room data +$400+$320  = $12720
    ; trim map +$320        = $12320
    ; room map  +0          = $12000
VRAM_areadata       = $12000 ; ($1afff) (36K) (12000 to 18BFF)
VRAM_tilemap		= $10000 ; ($11fff) (8K) (64x64 at 2 bytes per entry.)    
VRAM_tiledata		= $00000 ; ($0ffff) (64K) (1024 tiles at 16x16 at 4bpp)


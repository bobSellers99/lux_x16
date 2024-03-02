;-----------------------------------------------------------------------------
; text_input.s
; Copyright (C) 2020 Frank van den Hoef
;-----------------------------------------------------------------------------
MACHINE_X16=1

	.include "../inc/text_input.inc"
	.pc02			

	.code

;-----------------------------------------------------------------------------
; to_lower
;-----------------------------------------------------------------------------
to_lower:
	; Lower case character?
	cmp #'A'
	bcc @done
	cmp #'Z'+1
	bcs @done

	; Make lowercase
	ora #$20
@done:	rts

.export end_of_dos_rom
end_of_dos_rom:
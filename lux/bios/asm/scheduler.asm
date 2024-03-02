;Copyright 2024 by Robert Sellers under the 2 clause BSD License.
.pc02
.include "../../../lib/inc/zeropage.inc"
.include "../inc/rtc.inc"

_SCHEDULER_ASM_:


.export sys_user_loop
sys_user_loop:
	jmp scheduler


; TODO This will eventually be the scheduler. For now, all it does
; is call the user's main loop once per frame.
; TODO add profile code into the scheduler as well.
.export scheduler
.proc scheduler
	lda sys_rotor
	cmp #1
	beq @user0_loop
	jmp scheduler

	@user0_loop:
	stz sys_rotor
;	jsr sys_update_clock
	; User level once per tick execution.
	jmp ($020a)
    .endproc
;Copyright 2023 by Robert Sellers under the 2 clause BSD License.
.pc02

.ifndef _CTL_EDIT_ASM_

ctl_edit_process		= $9c40
ctl_edit_begin			= $9c43


.macro ctlEditBegin addr_sze
	memSet_16_16 addr_sze, zp_ind
	jsr ctl_edit_begin
	.endmacro

.endif				
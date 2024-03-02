;Copyright 2024 by Robert Sellers under the 2 clause BSD License.

key_shift			= $bf00
key_shift_lock		= $bf01	; TODO Not implemented.
key_ctl				= $bf02
key_alt				= $bf03


.ifndef _PS2_KEYBOARD_ASM_

.import sys_translate_key

.endif
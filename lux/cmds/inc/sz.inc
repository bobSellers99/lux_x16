;Copyright 2023 by Robert Sellers under the 2 clause BSD License.

.ifndef _SZ_ASM_

.import sz_length
.import sz_copy
.import sz_cat
.import sz_get_param


.macro sz_length source
    mem_SET_IMM_16 source, sz_length+2
    jsr sz_length
    .endmacro


.macro sz_copy source, dest
    mem_SET_IMM_16 source, sz_copy+2
    mem_SET_IMM_16 dest, sz_copy+4
    jsr sz_copy
    .endmacro


.macro sz_cat to_add, dest
    mem_SET_IMM_16 to_add, sz_cat+2
    mem_SET_IMM_16 dest, sz_cat+4
    jsr sz_cat
    .endmacro


.macro sz_get_param source, dest, index, token
    mem_SET_IMM_16 source, sz_get_param+2
    mem_SET_IMM_16 dest, sz_get_param+4

    lda index
    sta sz_get_param+6
    lda token
    sta sz_get_param+7
    jsr sz_get_param
    .endmacro

.endif

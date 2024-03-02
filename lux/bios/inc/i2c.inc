;Copyright 2024 by Robert Sellers under the 2 clause BSD License.


I2C_ADDRESS = $42
I2C_GET_SCANCODE_OFFSET = $07
I2C_GET_MOUSE_MOVEMENT_OFFSET = $21

.ifndef _I2C_ASM_

.import i2c_read_byte
.import i2c_write_byte
.import i2c_read_first_byte
.import i2c_read_next_byte
.import i2c_read_stop
.import i2c_write_first_byte
.import i2c_write_next_byte
.import i2c_write_stop

.endif

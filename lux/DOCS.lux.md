The Lux system is currently designed to operate in a single 64K bank under the 65c02 microprocessor. Ultimately, new hardware will be designed to utilize the memory banking features of the 65c816 microprocessor. at which time the system will be redesigned to reflect that. As such, the current design is a "proof of concept" that will then expand into the larger space available with the 65c816.

65c02 memory map:
FFFA-FFFF	NMI, RESET, and IRQ vectors.
FF00-FFF9	BIOS entry point JMP table.
C000-FEFF	BIOS code in ROM
A000-BFFF	BIOS RAM
9F00-9FFF	I/O mapped
7000-9EFF	Built in User Application Library.
2000-6FFF	Command Shell Programs
0300-1FFF	Command Shell Application

0100-01FF	Stack
0000-00FF	Zero Page memory.

Applications written to run in Command Shell Program space operate concurrently with the Command Shell Application and are referred to as "Console Applications." They use the Command Shell's text layer for interaction with the user. In addition, these programs can use the unused layer 1 as well. Only one Console Application can be run at a time.

User Applications are run from the Command Shell by entering their file name while in the User Application's main directory.

User Applications replace the Command Shell itself and will also have the Command Shell Program space as well. The User Application Library will still be available if the User Application doesn't overwrite that memory.

If the User Application does not need the User Application Library, and wishes to provide all of it's own code, it can use all of the space up to the I/O mapped area.

When a User Application closes, the BIOS reloads the Command Shell Application and User Application Library.

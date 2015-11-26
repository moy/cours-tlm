set FLASH_FILE             "/home/ensiens.imag.fr/moy/sle-tlm/TPs/squelette/tp3/a.raw" ;# Image file to program the flash with
set FLASH_BASEADDR         0x20100000              ;# Base address of flash device
set FLASH_PROG_OFFSET      0x00000000              ;# Offset at which the image should be programmed within flash
set FLASH_BUSWIDTH         32                      ;# Device bus width of all flash parts combined
set SCRATCH_BASEADDR       0x00000000              ;# Base address of scratch memory
set SCRATCH_LEN            0x00001fff              ;# Length of scratch memory
set EXTRA_COMPILER_FLAGS   "-mno-xl-soft-mul"      ;# Extra Compiler Flags for MicroBlaze
set XMD_CONNECT            "connect mb sim"        ;# Target Command to connect to XMD
set TARGET_TYPE            "MICROBLAZE"            ;# Target processor type
set PROC_INSTANCE          "microblaze_0"          ;# Processor Instance name


/* Linker script to configure memory regions. 
 * Need modifying for a specific board. 
 *   FLASH.ORIGIN: starting address of flash
 *   FLASH.LENGTH: length of flash
 *   RAM.ORIGIN: starting address of RAM bank 0
 *   RAM.LENGTH: length of RAM bank 0
 */
MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 64K
    APPCODE (rx) : ORIGIN = 0x00010000, LENGTH = 192K
    RAM (rwx)  : ORIGIN = 0x20001000, LENGTH = 60K
}

/* application address */
application_main = 0x00010401;

FlashHeader = 0x20000000;

FlashDriverRam = 0x20000000;

knl_system_stack_size = 4096;

ENTRY(reset_handler)

SECTIONS
{
	.text :
	{
		KEEP(*(.isr_vector))
		*(.startup*)
		*(.text*)
		*(.rodata*)
	} > FLASH

	__etext = .;
		
	.data : AT (__etext)
	{
		. = ALIGN(4);
		__data_start__ = .;
		*(.data*)
		__data_end__ = .;
	} > RAM

	.bss :
	{
		. = ALIGN(4);
		__bss_start__ = .;
		*(.bss*)
		*(COMMON)
		. = ALIGN(4);
		__bss_end__ = .;
	} > RAM
	
	.init_stack ALIGN(16) (NOLOAD) : 
	{	
	   knl_system_stack    = .; 
	   . = . + knl_system_stack_size; 	
	   knl_system_stack_top = .;
	} > RAM
	
	INCLUDE .app_s19.c.lds
}

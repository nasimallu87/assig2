@ 
@ Assembler program print out "Hello World"
@ using the Pico SDK.
@
@ R0 - first parameter to printf
@ R1 - second parameter to printer
@ R7 - index counter
@

.thumb_func		    @ Necessary because sdk uses BLX
.global main	            @ Provide program starting address to linker

main:
	MOV	R7, #100		@ initialize counter to 0
	BL	stdio_init_all	@ activates uart or usb
loop:
	LDR	R0, =helloworld	@ loads address of helloworld string
			
	MOV	R1, R7		@ move the counter to second parameter
	BL	printf		@ call pico_printf, cfunktion
	sub R7, R7, #1 @decreases counter R7 with -1
	CMP R7, #0    @ compares R7 if its större eller mindre än 0
	BGE continue_loop  @jumps to continue loop if R7 bigger or = to 0 (med andra ord fortsätt räkna neråt)
	MOV R7, #100  @ om R7 < 0 så laddas 100 o räknar börjar från 100 igen
continue_loop: # märke för fortsättning av loopen, den hoppar hit om R7 större eller lika med 0
	B loop # hoppa tillbaka till loop alltid
	 		
		
.data
	       .align  4	@ necessary alignment
helloworld: .asciz   "Hello World %d\n"  @ skapar text

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
	MOV	R7, #100		@ initialize counter to 100
	BL	stdio_init_all	@ activates uart or usb
loop:
	LDR	R0, =helloworld	@ loads address of helloworld string
			
	MOV	R1, R7		@ move the counter to second parameter
	BL	printf		@ call pico_printf, cfunktion
	sub R7, R7, #1 @decreases counter R7 with -1
	CMP R7, #0    @ compares R7 if its större eller mindre än 0
	BGE continue_loop 
	MOV R7, #100  
continue_loop: 
	B loop 
	 		
		
.data
	       .align  4	@ necessary alignment
helloworld: .asciz   "Hello World %d\n"

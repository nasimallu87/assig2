@ ---------------------------------------------
@ 7-Segment Display Counter – Raspberry Pi Pico
@ ---------------------------------------------
@ R0 – used for function parameters (pin number or delay time)
@ R1 – used for function parameters (ON/OFF value for segments)
@ R3 – temporary register (mask = 1)
@ R4 – holds current 7-segment pattern (bits for segments A–G)
@ R5 – direction flag (0 = up, 1 = down)
@ R6 – current digit (0–9)
@ R7 – segment/pin index (0–6)
@ ---------------------------------------------

	.syntax unified
	.cpu cortex-m0plus
	.thumb
	.global main
	.thumb_func

@functions
	.extern gpio_init
	.extern sleep_ms
	.extern link_gpio_set_dir 		@ set their direction
	.extern link_gpio_put  			@ send output signals
	.equ GPIO_OUT, 1          @ output = 1
	.text
main:
    MOVS    R4, #0		@ R4 = 0 (start with pin 0)
1:  MOVS    R0, R4		@ R0 = pin number		            
    BL      gpio_init	@ call gpio_init(pin)	
    MOVS    R0, R4      @ R0 = pin number again
    MOVS    R1, #GPIO_OUT 		@ R1 = output
    BL      link_gpio_set_dir	@ set pin as output
    ADDS    R4, R4, #1		@ R4 = R4 + 1 (next pin)		
    CMP     R4, #7			@ compare R4 with 7
    BCC     1b				@ if R4 < 7, go back to "1"

   
    MOVS    R6, #0		 @ start counting from 0
    MOVS    R5, #0		 @ start by counting UP (later changes to 1 to go DOWN)

loop_main:
    
    LDR     R0, =digits		@ load address of digits table (the list of 0–9 bit patterns)
    ADDS    R0, R0, R6		@ choose which number (index) to show
    LDRB    R4, [R0]		@ get which LEDs to turn on for this number		          

    MOVS    R7, #0            
2:  MOVS    R1, R4            
    MOVS    R3, #1           
    ANDS    R1, R3           
    MOVS    R0, R7            
    BL      link_gpio_put     
    LSRS    R4, R4, #1        
    
	ADDS    R7, R7, #1		  @ next pin
    CMP     R7, #7		      @ compare with 7
    BCC     2b				  @ if < 7, loop again

    LDR     R0, =1000 		@ R0 = 1000 (delay time)
    BL      sleep_ms		 @ wait 1000 ms

    CMP     R5, #0		
    BNE     dir_down  @R5=0 ⇒ no jump

    CMP     R6, #9		 R6==9 ⇒ no jump to inc_ok.  (vid r5=0)
    BNE     inc_ok		
    MOVS    R5, #1            @  change direction to down
    SUBS    R6, R6, #1        
    B       loop_main
inc_ok:
    ADDS    R6, R6, #1		@ digit = digit + 1
    B       loop_main

@ same as there up but this time to see if its 0 so it count up 
dir_down:
    CMP     R6, #0		
    BNE     dec_ok		
    MOVS    R5, #0            
    ADDS    R6, R6, #1        
    B       loop_main
dec_ok:
    SUBS    R6, R6, #1		@ digit = digit - 1
    B       loop_main


	.data
	.align 1
digits:
    .byte 0x3F    @digit  0
    .byte 0x06    @ digit 1
    .byte 0x5B    @ digit 2
    .byte 0x4F    @ digit 3
    .byte 0x66    @ digit 4
    .byte 0x6D    @ digit 5
    .byte 0x7D    @ digit 6
    .byte 0x07    @ digit 7
    .byte 0x7F    @digit  8
    .byte 0x6F    @digit  9

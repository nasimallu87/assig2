@
@ Assembler program to flash three LEDs connected to the
@ Raspberry Pi Pico GPIO port using the Pico SDK.
@

	.EQU	LED_PIN1, 0 @gpo0
	.EQU	LED_PIN2, 1 @gpo1
	.EQU	LED_PIN3, 2 @gpo2
	.EQU	GPIO_OUT, 1 @ out
	.EQU	sleep_time, 1000 @1 sek

.thumb_func	@ Necessary because sdk uses BLX
.global main    @ Provide program starting address

main:
	MOV	R0, #LED_PIN1 @ ledpin1 is R0, this 5 rows is initiating gp0 as output 
	BL	gpio_init	@ c function
	MOV	R0, #LED_PIN1	
	MOV	R1, #GPIO_OUT	
	BL	link_gpio_set_dir
	
	MOV	R0, #LED_PIN2 @ same as before byt for ledpin2, this 5 rows is initiating gp1 as output 
	BL	gpio_init
	MOV	R0, #LED_PIN2
	MOV	R1, #GPIO_OUT
	BL	link_gpio_set_dir
	
	MOV	R0, #LED_PIN3 @ same as before byt for ledpin3, this 5 rows is initiating gp2 as output 
	BL	gpio_init	
	MOV	R0, #LED_PIN3	
	MOV	R1, #GPIO_OUT
	BL	link_gpio_set_dir
	
	MOV R7, #0 @counter, makes it 0
	MOV R6, #0 @direction, makes it 0
	
	
loop:
	
	MOV R3, #7 
	AND R7, R7, R3 @limits r7 to 3 bits 0-7, if r7 bigger then masks down

	@led1 0bit in r7
	MOV R2, R7 @ copy r7 to r2
	MOV R3, #1 @ mask 1
	AND R2, R2, R3 @ take 0bit from r7
	MOV R1, R2 @take result 1 or 0 in r1
	MOV R0, #LED_PIN1 @ pin 0
	BL link_gpio_put @turn or shutoff pin1

	@led2 bit1 in r7
	MOV R2, R7 @ copy r7
	LSR R2, R2, #1 @ shift 1 step right, bit1 moves to LSB
	MOV R3, #1
	AND R2, R2, R3 @isolate bit1
	MOV R1, R2 @ 0/1 in r1
	MOV R0, #LED_PIN2 @ select pin1
	BL link_gpio_put @turn off and on power on led2

	@led3 bit2 in r7, same as before but for bit2 and shift 2 steps instead of 1 
	MOV R2, R7
	LSR R2, R2, #2
	MOV R3, #1
	AND R2, R2, R3
	MOV R1, R2
	MOV R0, #LED_PIN3
	BL link_gpio_put
	
	LDR R0, =sleep_time @load delay
	BL sleep_ms 
	CMP R6, #0 @compare diretction r6
	BNE down @ if not 0 go go down

up: @count up
	CMP R7, #7 @if counter at 7 
	BNE up_notmax @if not max then jump to normal up
	MOV R6, #1 @ if max then set direction down
	SUB R7, R7, #1 @ decrease r7 by 1 
	
	CMP R6, #6 @extra compare (not needed but whatever)
	BNE down @ jump down to down


up_notmax:
	ADD R7, R7, #1 @ increase counter by 1 
	B loop @jump back to loop
	
down: @counting down 
	CMP R7, #0 @ is counter 0 
	BNE down_notmin @ if not 0 then decrease
	MOV R6, #0 @if min then set direction back up
	ADD R7, R7, #1 @ increase 1 
	B loop @back to loop

down_notmin:
	SUB R7, R7, #1 @ decrease counter by 1
	B loop @back to loop
	


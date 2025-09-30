	.syntax unified
	.cpu cortex-m0plus
	.thumb

	.global main
	.thumb_func

	/* Externa C-funktioner (SDK + dina wrappers) */
	.extern gpio_init
	.extern sleep_ms
	.extern link_gpio_set_dir
	.extern link_gpio_put

	.equ GPIO_OUT, 1          @ output

	.text
main:
    /* Initiera GP0..GP6 som OUTPUT enligt L4/L6 */
    MOVS    R4, #0
1:  MOVS    R0, R4            @ gpio_init(pin)
    BL      gpio_init
    MOVS    R0, R4            @ gpio_set_dir(pin, 1)
    MOVS    R1, #GPIO_OUT
    BL      link_gpio_set_dir
    ADDS    R4, R4, #1
    CMP     R4, #7
    BCC     1b

    /* start: count (R6) = 0, dir (R5)=upp(0) */
    MOVS    R6, #0
    MOVS    R5, #0

loop_main:
    /* Hämta bitmönster (CC: A..G = bit0..bit6, 1=tänd) i R4 (callee-saved) */
    LDR     R0, =digits
    ADDS    R0, R0, R6
    LDRB    R4, [R0]          @ R4 = pattern

    /* Skriv ut GP0..GP6.
       - R4 håller pattern och skiftas höger ett steg efter varje segment.
       - R7 = pin-index (callee-saved).
       - R3 används bara temporärt som mask=1 (caller-saved, ok om den ändras). */
    MOVS    R7, #0            @ pin = 0
2:  MOVS    R1, R4            @ R1 = pattern
    MOVS    R3, #1            @ mask = 1 (Thumb-1 kräver reg-reg AND)
    ANDS    R1, R3            @ R1 = (pattern & 1)
    MOVS    R0, R7            @ R0 = pin
    BL      link_gpio_put     @ C-kall får ändra R0-R3, men ej R4/R7
    LSRS    R4, R4, #1        @ pattern >>= 1 (i R4 som bevaras av C)
    ADDS    R7, R7, #1
    CMP     R7, #7
    BCC     2b

    /* 1 s delay enligt uppgift */
    LDR     R0, =1000
    BL      sleep_ms

    /* Upp/Ned: 0→9→0 */
    CMP     R5, #0
    BNE     dir_down

    /* --- UPP --- */
    CMP     R6, #9
    BNE     inc_ok
    MOVS    R5, #1            @ vänd till nedåt
    SUBS    R6, R6, #1        @ nästa 8
    B       loop_main
inc_ok:
    ADDS    R6, R6, #1
    B       loop_main

dir_down:
    /* --- NED --- */
    CMP     R6, #0
    BNE     dec_ok
    MOVS    R5, #0            @ vänd till uppåt
    ADDS    R6, R6, #1        @ nästa 1
    B       loop_main
dec_ok:
    SUBS    R6, R6, #1
    B       loop_main

	/* -------- DATA -------- */
	.data
	.align 1
digits:
    .byte 0x3F    @ 0
    .byte 0x06    @ 1
    .byte 0x5B    @ 2
    .byte 0x4F    @ 3
    .byte 0x66    @ 4
    .byte 0x6D    @ 5
    .byte 0x7D    @ 6
    .byte 0x07    @ 7
    .byte 0x7F    @ 8
    .byte 0x6F    @ 9

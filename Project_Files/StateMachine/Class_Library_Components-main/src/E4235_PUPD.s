@ mmap part taken from by https://bob.cs.sonoma.edu/IntroCompOrg-RPi/sec-gpio-mem.html

@ this code is sourced from github user mathis-m at https://gist.github.com/mathis-m/facd241fe1f324c7b22338484f60338f


	@ GPOIO Related
	.equ    GPIO_PUP_PDN_REG0, 0xe4    @ pull up pull down register 0, for pins 0-15
	.equ    GPIO_PUP_PDN_REG1, 0xe8    @ pull up pull down register 1, for pins 16-31

	@ Args for mmap
	.equ    OFFSET_FILE_DESCRP, 0   @ file descriptor
	.equ    mem_fd_open, 3
	.equ    BLOCK_SIZE, 4096        @ Raspbian memory page
	.equ    ADDRESS_ARG, 3          @ device address


	@ Misc
	.equ    BIT_2_MASK, 0b11   @ Mask for 3 bits

	@ The following are defined in /usr/include/asm-gezneric/mman-common.h:
	.equ    MAP_SHARED,1    @ share changes with other processes
	.equ    PROT_RDWR,0x3   @ PROT_READ(0x1)|PROT_WRITE(0x2)

	.section .rodata
device:
	    .asciz  "/dev/gpiomem"
PinErrorMsg:     
	    .asciz  "GPIO number not valid,please provide a valid GPIO number\n"	@ pin error message
ValErrorMsg:     
	.asciz  "Value not valid,please provide a valid value\n"		@ value error message

.text
	.global E4235_PUPD
E4235_PUPD:
	PIN	.req  r11		@ pin number
	VALUE	.req  r12		@ value to send to pin, 1: high, 0:low
	PUSH {r2-r12,LR}
	mov PIN, r0		@ saving inputs to write function to PIN and VALUE
	mov VALUE, r1
	mov r9, VALUE  		@saving for later
	
	cmp PIN,#0		@ these conditionals ensure the provided GPIO value is valid; 0-29
	blt PIN_INVALID
	cmp PIN,#29
	bgt PIN_INVALID

	cmp VALUE, #0		@ these conditionals ensure the VALUE provided is valid; 0 or 1
	BEQ VALID_INPUT	
	cmp VALUE, #1
	BEQ VALID_INPUT
	
VAL_INVALID:			@ if VALUE is invalid, print a value error message and exit program
	ldr r0, valErrorMsgAddr
	bl printf
	POP {r2-r12, LR}
	BX LR

	
PIN_INVALID:			@if PIN is invalid, print a pin error message and exit program
	ldr r0, pinErrorMsgAddr
	bl printf
	POP {r2-r12, LR}
	BX LR



VALID_INPUT:	
    @ Open /dev/gpiomem for read/write and syncing
    mov r6, VALUE
    ldr     r1, O_RDWR_O_SYNC   @ flags for accessing device
    ldr     r0, mem_fd          @ address of /dev/gpiomem
    bl      open     
    mov     r4, r0              @ use r4 for file descriptor
	
@ Map the GPIO registers to a main memory location so we can access them
@ mmap(addr[r0], length[r1], protection[r2], flags[r3], fd[r4])
    str     r4, [sp, #OFFSET_FILE_DESCRP]   @ r4=/dev/gpiomem file descriptor
    mov     r1, #BLOCK_SIZE                 @ r1=get 1 page of memory
    mov     r2, #PROT_RDWR		    @ r2=read/write this memory
    mov     r3, #MAP_SHARED                 @ r3=share with other processes
    mov     r0, #mem_fd_open                @ address of /dev/gpiomem
    ldr     r0, GPIO_BASE                   @ address of GPIO
    str     r0, [sp, #ADDRESS_ARG]          @ r0=location of GPIO
    bl      mmap
	mov     r5, r0           @ save the virtual memory address in r5
	mov VALUE, r9
	


	PUPD_MASK .req r6
	PUPD_VALUE .req r7
	PUPD_REG .req r8

	cmp VALUE,#1
	mov PUPD_VALUE, #2
	moveq PUPD_VALUE, #01


	cmp PIN, #15
	mov r1,#0		@ PIN less than 16
	mov PUPD_REG,#GPIO_PUP_PDN_REG0
	movgt PUPD_REG, #GPIO_PUP_PDN_REG1
	movgt r1, #16		@ PIN 16 or greater
	sub r1,PIN,r1		@ scale pin value to always be between 0-15
	mov r3,r1
	add r1,r3,r1		@ multiply r1 by 2, 2 bits for each pin
	
	mov PUPD_MASK, #BIT_2_MASK		@ bit mask for resetting bit in register corresponding to GPIO
	lsl PUPD_MASK, PUPD_MASK, r1		@ shift mask to position
	lsl PUPD_VALUE, PUPD_VALUE, r1

	mov r2, #0
	add r0,r5,PUPD_REG
	ldr r2,[r0]
	bic r2,r2,PUPD_MASK
	orr r2,r2,PUPD_VALUE
	str r2,[r0]

	POP {r2-r12, LR}
	bx lr







GPIO_BASE:
    .word   0xfe200000  @GPIO Base address Raspberry pi 4
mem_fd:
    .word   device
O_RDWR_O_SYNC:
	.word   2|256       @ O_RDWR (2)|O_SYNC (256).
pinErrorMsgAddr:
	.word PinErrorMsg	@ pin error message
valErrorMsgAddr:
	.word ValErrorMsg	@ value error message

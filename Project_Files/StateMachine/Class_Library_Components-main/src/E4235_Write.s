@ mmap part taken from by https://bob.cs.sonoma.edu/IntroCompOrg-RPi/sec-gpio-mem.html

@ this code is sourced from github user mathis-m at https://gist.github.com/mathis-m/facd241fe1f324c7b22338484f60338f


@ GPOIO Related
.equ    GPCLR0, 0x28    @ clear register offset
.equ    GPSET0, 0x1c    @ set register offset

@ Args for mmap
.equ    OFFSET_FILE_DESCRP, 0   @ file descriptor
.equ    mem_fd_open, 3
.equ    BLOCK_SIZE, 4096        @ Raspbian memory page
.equ    ADDRESS_ARG, 3          @ device address

@ The following are defined in /usr/include/asm-gezneric/mman-common.h:
.equ    MAP_SHARED,1    @ share changes with other processes
.equ    PROT_RDWR,0x3   @ PROT_READ(0x1)|PROT_WRITE(0x2)

@ Constant program data
    .section .rodata
device:
    .asciz  "/dev/gpiomem"
PinErrorMsg:     
    .asciz  "GPIO number not valid,please provide a valid GPIO number\n"	@ pin error message
ValErrorMsg:     
	.asciz  "Value not valid,please provide a valid value\n"		@ value error message

@ The program
    .text
	.global E4235_Write

E4235_Write:
 PIN	.req  r11		@ pin number
 VALUE	.req  r12		@ value to send to pin, 1: high, 0:low
	PUSH {r2-r12,LR}
	mov PIN, r0		@ saving inputs to write function to PIN and VALUE
	mov VALUE, r1
	
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
    mov VALUE, r6
debug:	
@ Alias some registers that will be prepopulated and used later on
    
    GPSET_OFFSET          .req r7     @ Will hold offset to GPCLRn register for GPIO_NUM
    GPCLR_OFFSET          .req r8     @ Will hold offset to GPSETn register for GPIO_NUM
    


	mov GPSET_OFFSET, #0x1c		@ GPSET_OFFSET value is always 0x1c for gpios 0-29
	mov GPCLR_OFFSET, #0x28		@ GPCLR_OFFSET value is always 0x28 for gpios 0-29


	



debug1:	
    cmp VALUE,#0		@ logic to check if program is turning on or turning off gpio
    beq off
	
@ Turn on
on: add     r0, r5, GPSET_OFFSET  @ calc GPSETn address
	ldr r2,[r0]
    mov    r3, #1              @ turn on bit
    lsl     r3, r3, r11         @ shift bit to pin position corresponding to the selected gpio value
    orr     r2, r2, r3          @ set bit
	str     r2, [r0]                @ update register
	mov r0,r5
	mov r1,#BLOCK_SIZE
	bl munmap

	mov r0,r4
	bl close
    POP {r2-r12,LR}
    BX LR
	

off:	
	add     r0, r5, GPCLR_OFFSET  @ calc GPSETn address
	ldr r2,[r0]

    mov     r3, #1              @ turn on bit
    lsl     r3, r3, r11         @ shift bit to pin position
    orr     r2, r2, r3          @ set bit
	str     r2, [r0]                @ update register
	mov r0,r5
	mov r1,#BLOCK_SIZE
	bl munmap

	mov r0,r4
	bl close
    POP {r2-r12,LR}
    BX LR
	



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

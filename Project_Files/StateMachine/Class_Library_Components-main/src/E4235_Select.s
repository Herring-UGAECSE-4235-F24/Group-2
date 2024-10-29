@ Args for mmap
.equ    OFFSET_FILE_DESCRP, 0   @ file descriptor
.equ    mem_fd_open, 3
.equ    BLOCK_SIZE, 4096        @ Raspbian memory page
.equ    ADDRESS_ARG, 3          @ device address


@ Misc
.equ    BIT_3_MASK, 0b111   @ Mask for 3 bits

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
	.global E4235_Select

E4235_Select:
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
    GPFSEL_OFFSET         .req r6     @ Will hold offset to GPFSELn register for GPIO_NUM
    GPSET_OFFSET          .req r7     @ Will hold offset to GPCLRn register for GPIO_NUM
    GPCLR_OFFSET          .req r8     @ Will hold offset to GPSETn register for GPIO_NUM
    GPFSEL_MASK             .req r9     @ Mask for setting function for GPIO_NUM
    GPFSEL_MAKE_OUTPUT_VAL  .req r10     @ Value for bitwise or to make PIN an output

	@ Calculate GPIO register offsets and util values]
 	
	@ GPIO 0-9 = sel0
	@ GPIO 10-19 = sel1 
	@ GPIO 20-29 = sel2

	cmp PIN, #9		@ these conditionals determine what the GPFSEL_OFFSET value will be depending on the value of PIN
	bgt greater
	movle GPFSEL_OFFSET, #0x00	
	b skip

greater:
	cmp PIN, #20
	movge GPFSEL_OFFSET, #0x08
	movlt GPFSEL_OFFSET, #0x04
skip:	
	@ these conditional moves ensure the proper offset is being applied to the GPFSEL_MASK
	cmp GPFSEL_OFFSET, #0x4
	movgt r1, #20		@if GPFSEL_OFFSET = 0x08, subtract 20 from PIN below so the offset if from 0-9
	moveq r1, #10 		@if GPFSEL_OFFSET = 0x04, subtract 10 from PIN below so the offset if from 0-9	
	movlt r1, #0
	
    sub     r1, PIN, r1     @     for GPFSEL pin => nth pin in GPFSELn register
	
    mov     r3, r1                      
    add     r1, r1, r3, lsl #1          @   multiply r1 by 3 (each pin has 3 bits in GPFSELn). r3->lsl #1 = r3 * 2; r3 + r1 = 3 * r1

    mov     GPFSEL_MASK, #BIT_3_MASK      @ 3 bit high mask, this is used to block off the three bits for the specific GPIO in GPFSEL
    lsl     GPFSEL_MASK, GPFSEL_MASK, r1  @ shift mask to pin position (shift= 3 * pin num)

	cmp VALUE, #1
	mov GPFSEL_MAKE_OUTPUT_VAL, #0
	moveq GPFSEL_MAKE_OUTPUT_VAL, #1  @ make output bit, to make the gpio output, the 3 bits corresponding to that gpio need to be 001, this is the 1 bit. 
    lsl     GPFSEL_MAKE_OUTPUT_VAL, GPFSEL_MAKE_OUTPUT_VAL, r1  @ shift that bit to pin position[0] (shift= 3 * pin num)

    @ Set up the GPIO pin funtion register in programming memory
    mov     r2, #0
    add     r0, r5, GPFSEL_OFFSET         @ calculate address for GPFSELn, r0 = virtual address from mmap + GPFSEL_OFFSET
    ldr     r2, [r0]                        @ get current GPFSELn register
    bic     r2, r2, GPFSEL_MASK             @ clear the current 3 bits of the selected gpio in the GPFSEL register
    orr     r2, r2, GPFSEL_MAKE_OUTPUT_VAL  @ set the 1 bit in the corresponding position of the selected gpio so its function is 001.
	str     r2, [r0]@ update register

	mov r0,r5
	mov r1,#BLOCK_SIZE
	bl munmap

	mov r0,r4
	bl close
	
	POP {r2-r12, LR}
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

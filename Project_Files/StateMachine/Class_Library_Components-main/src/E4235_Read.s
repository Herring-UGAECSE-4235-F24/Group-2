@The following is the code for the read() function which determines the
@ level of a given GPIO pin

@ Args for mmap
	
.equ    OFFSET_FILE_DESCRP, 0   @ file descriptor
.equ    mem_fd_open, 3
.equ    BLOCK_SIZE, 4096        @ Raspbian memory page
.equ    ADDRESS_ARG, 3          @ device address

	@ The following are defined in /usr/include/asm-generic/mman-common.h:
.equ    MAP_SHARED,1    @ share changes with other processes
.equ    PROT_RDWR,0x3   @ PROT_READ(0x1)|PROT_WRITE(0x2)

	.section .rodata
device:
	.asciz  "/dev/gpiomem"
PinErrorMsg:
	.asciz "GPIO number not valid,please provide a valid GPIO number.\n"
.text
	
.global E4235_Read

E4235_Read:
 PIN      .req r6
 PUSH {r2-r12, LR} @ push registers to use in read
	mov PIN, r0 @loads value of pin given by user into r6
		
	cmp PIN,#0
	blt PIN_INVALID
	cmp PIN,#29
	bgt PIN_INVALID
	b skip

PIN_INVALID:
	ldr r0, PinErrorMsgAddr
	bl printf
	mov r0,#-1
	POP {r2-r12, LR}
	BX LR


skip:	
    @ Open /dev/gpiomem for read/write and syncing
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

read:	
	ldr r8, [r5, #0x34] @shift base address by value of LEV0 offset
	lsr r8, r8, PIN @shift r8 by PIN value to get pin val to read on the LSB
	and r0, r8, #1 @store the LSB (pin to be checked) as the LSB and clear all other bits this val will be returned
	mov r2,r0 @ saving r0 in r2

 
 	mov r0,r5
	mov r1,#BLOCK_SIZE
	bl munmap

	mov r0,r4
	bl close
 
 	mov r0,r2	@restoring value in r0
  
	POP {r2-r12,LR}
	bx lr @ return to C main

GPIO_BASE:
    .word   0xfe200000  @GPIO Base address Raspberry pi 4
mem_fd:
    .word   device
O_RDWR_O_SYNC:
	.word   2|256       @ O_RDWR (2)|O_SYNC (256).
PinErrorMsgAddr:
	.word PinErrorMsg
	
